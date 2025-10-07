import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_message.dart';
import '../../utils/objects.dart';
import '../../utils/rsa.dart';
import '../api/api_service.dart';
import '../api/websocket_service.dart';
import '../models/User.dart';
import '../models/message_receive.dart';
import 'chat_controller.dart';

/// 用户控制器，管理用户认证、WebSocket 连接和用户信息
class UserController extends GetxController with WidgetsBindingObserver {
  // 单例访问
  static UserController get to => Get.find();

  // 常量定义
  static const _keyUserId = 'userId';
  static const _keyToken = 'token';
  static const _successCode = 200;
  static const _qrAuthorizedCode = 'AUTHORIZED';
  static const _reconnectBaseDelay = Duration(seconds: 2);
  static const _maxReconnectAttempts = 6;

  // 依赖注入
  final _storage = GetStorage();
  final _secureStorage = const FlutterSecureStorage();
  final _apiService = Get.find<ApiService>();
  final _wsService = Get.find<WebSocketService>();
  final _chatController = Get.find<ChatController>();

  // 响应式状态
  final RxString userId = ''.obs; // 用户ID
  final RxString token = ''.obs; // 认证令牌
  final RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs; // 用户信息

  // 非响应式字段
  String publicKey = ''; // RSA 公钥
  bool _gettingPublicKey = false;
  bool _connecting = false;
  bool _reconnectLock = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  final RxBool isEditing = false.obs;

  // --- 生命周期管理 ---

  @override
  void onInit() {
    super.onInit();

    // 初始化：先加载本地存储，再设置监听器
    _loadStoredData();
    _setupListeners();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _reconnectTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        Get.log('📌 应用进入非活动状态');
        break;
      case AppLifecycleState.paused:
        Get.log('⏸️ 应用进入后台');
        _chatController.currentChat.value = null;
        break;
      case AppLifecycleState.resumed:
        Get.log('✅ 应用恢复到前台');
        reconnectWebSocket();
        break;
      case AppLifecycleState.detached:
        Get.log('🔌 应用 UI 已分离');
        break;
      case AppLifecycleState.hidden:
        Get.log('👻 应用已隐藏');
        break;
    }
  }

  // --- 数据持久化 ---

  Future<void> _loadStoredData() async {
    try {
      final storedToken = await _secureStorage.read(key: _keyToken);
      final storedUserId = _storage.read(_keyUserId);

      if (storedToken != null && storedToken.isNotEmpty)
        token.value = storedToken;
      if (storedUserId != null && storedUserId.toString().isNotEmpty) {
        userId.value = storedUserId.toString();
      }
    } catch (e, st) {
      _logError('加载存储数据失败: $e\n$st');
    }
  }

  void _saveUserId() {
    try {
      if (userId.value.isEmpty) {
        _storage.remove(_keyUserId);
      } else {
        _storage.write(_keyUserId, userId.value);
      }
    } catch (e) {
      _logError('保存 userId 失败: $e');
    }
  }

  Future<void> _saveToken() async {
    try {
      if (token.value.isEmpty) {
        await _secureStorage.delete(key: _keyToken);
      } else {
        await _secureStorage.write(key: _keyToken, value: token.value);
      }
    } catch (e) {
      _logError('保存令牌失败: $e');
    }
  }

  void _setupListeners() {
    // 当 token 变化时，既保存也检查认证状态
    ever(token, (_) {
      _onTokenChanged();
    });

    // 保存 userId
    ever(userId, (_) => _saveUserId());
  }

  Future<void> _onTokenChanged() async {
    try {
      await _saveToken();
      _checkAuth();
    } catch (e) {
      _logError('处理 token 变更失败: $e');
    }
  }

  // --- 认证管理 ---

  void _checkAuth() {
    if (token.value.isEmpty) {
      Get.log('用户未认证');
    } else {
      Get.log('用户已认证');
    }
  }

  /// 用户登录
  Future<bool> login(String username, String password, String authType) async {
    try {
      await logout(); // 清除现有认证状态
      await _ensurePublicKey();

      final encryptedPassword = await RSAService.encrypt(password, publicKey);
      Get.log('🔑 加密后的密码（已隐藏）');

      final loginData = {
        'principal': username,
        'credentials': encryptedPassword,
        'authType': authType,
      };

      final response = await _apiService.login(loginData);
      return _handleApiResponse(response, onSuccess: (data) {
        if (Objects.isNotBlank(data['accessToken']) &&
            Objects.isNotBlank(data['userId'])) {
          token.value = data['accessToken'];
          userId.value = data['userId'];
          startConnect();
          return true;
        }
        return false;
      }, errorMessage: '登录失败');
    } catch (e, st) {
      _logError('登录异常: $e\n$st');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _wsService.closeSocket();
      token.value = '';
      userId.value = '';
      userInfo.value = {};
      await _secureStorage.delete(key: _keyToken);
      await _storage.remove(_keyUserId);
    } catch (e) {
      _logError('登出失败: $e');
    }
  }

  Future<void> startConnect() async {
    connectWebSocket();
    await _chatController.loadChats(userId.value);
    _chatController.syncChatsAndMessages();
  }

  // --- WebSocket 管理 ---

  void connectWebSocket() {
    if (token.value.isEmpty || userId.value.isEmpty) return;

    if (_wsService.isConnected) {
      Get.log('WebSocket 已连接，跳过 connect');
      return;
    }

    if (_connecting) {
      Get.log('正在连接中，跳过重复连接');
      return;
    }

    _connecting = true;
    try {
      _wsService.initWebSocket(
        onOpen: () {
          Get.log('WebSocket 连接成功，开始注册');
          _wsService.register(token.value);
          _connecting = false;
          _reconnectAttempts = 0;
        },
        onMessage: _handleWebSocketMessage,
        onError: (error) {
          _logError('WebSocket 错误: $error');
          _connecting = false;
        },
        uid: userId.value,
        token: token.value,
      );
    } catch (e, st) {
      _connecting = false;
      _logError('connectWebSocket 发生异常: $e\n$st');
      // 触发重连策略
      reconnectWebSocket();
    }
  }

  Future<void> reconnectWebSocket() async {
    if (_reconnectLock) {
      Get.log('重连已在排队/进行中，跳过重复请求');
      return;
    }
    _reconnectLock = true;

    // 取消已有定时器（如果存在）
    _reconnectTimer?.cancel();

    // 指数退避
    final attempts = _reconnectAttempts.clamp(0, _maxReconnectAttempts);
    final delay = _reconnectBaseDelay * (1 << attempts); // 2s,4s,8s...
    _reconnectAttempts++;

    Get.log(
        '尝试重连 WebSocket，第 $_reconnectAttempts 次，将在 ${delay.inSeconds}s 后尝试');

    _reconnectTimer = Timer(delay, () async {
      try {
        connectWebSocket();
        await _chatController.syncChatsAndMessages();
      } catch (e, st) {
        _logError('重连尝试失败: $e\n$st');
      } finally {
        // 允许下一次重连（如果仍然需要）
        _reconnectLock = false;
      }
    });
  }

  void _handleWebSocketMessage(dynamic rawData) {
    try {
      final message = _safeDecodeJson(rawData);
      if (message == null) {
        _logError('无法解析的 WebSocket 消息: $rawData');
        return;
      }

      final code = message['code'] ?? 1;
      final contentType = IMessageType.fromCode(code);

      switch (contentType) {
        case IMessageType.login:
          Get.log('WebSocket 注册响应: $message');
          break;
        case IMessageType.heartBeat:
          Get.log('WebSocket 心跳响应: $message');
          break;
        case IMessageType.singleMessage:
        case IMessageType.groupMessage:
          _processChatMessage(message['data']);
          break;
        case IMessageType.videoMessage:
          _processVideoMessage(message['data']);
          break;
        default:
          Get.log('未知的 WebSocket 消息类型: $code');
      }
    } catch (e, st) {
      _logError('处理 WebSocket 消息出错: $e\n$st');
    }
  }

  // 处理单聊/群聊消息，抽成方法便于单测
  void _processChatMessage(dynamic data) {
    try {
      if (data == null) {
        _logError('_processChatMessage: data 为 null');
        return;
      }
      final IMessage parsedMessage = IMessage.fromJson(data);
      final String? chatId = _deriveChatIdFromMessage(parsedMessage);
      if (chatId == null) {
        _logError('无法从消息推断 chatId: ${parsedMessage.toJson()}');
        return;
      }

      _chatController.handleCreateOrUpdateChat(parsedMessage, chatId, false);
      Get.log(
          'WebSocket ${parsedMessage.messageType == IMessageType.singleMessage.code ? '单聊' : '群聊'}消息接收: ${parsedMessage.messageId ?? 'unknown id'}');
    } catch (e, st) {
      _logError('_processChatMessage 异常: $e\n$st');
    }
  }

  void _processVideoMessage(dynamic data) {
    try {
      if (data == null) {
        _logError('_processVideoMessage: data 为 null');
        return;
      }
      final parsedMessage = MessageVideoCallDto.fromJson(data);
      _chatController.handleCallMessage(parsedMessage);
      Get.log('WebSocket 视频消息接收: ${parsedMessage.fromId ?? 'unknown'}');
    } catch (e, st) {
      _logError('_processVideoMessage 异常: $e\n$st');
    }
  }

  // 从 IMessage 推断聊天 id（single -> 对端 id，group -> groupId）
  String? _deriveChatIdFromMessage(IMessage parsedMessage) {
    try {
      if (parsedMessage.messageType == IMessageType.singleMessage.code) {
        // single message: chatId 是另一方的 id（如果当前为发送方取 toId，否则取 fromId）
        final single = IMessage.toSingleMessage(parsedMessage, userId.value);
        if (single == null) return null;
        return single.fromId == userId.value
            ? parsedMessage.toId
            : parsedMessage.fromId;
      } else if (parsedMessage.messageType == IMessageType.groupMessage.code) {
        final group = IMessage.toGroupMessage(parsedMessage, userId.value);
        return group?.groupId;
      }
      return null;
    } catch (e) {
      _logError('推断 chatId 失败: $e');
      return null;
    }
  }

  // --- API 调用 ---

  Future<void> sendVerificationCode(String phone) async {
    try {
      final response = await _apiService.sendSms({'phone': phone});
      _handleApiResponse(response, onSuccess: (_) {}, errorMessage: '发送验证码失败');
    } catch (e, st) {
      _logError('发送验证码失败: $e\n$st');
      rethrow;
    }
  }

  Future<void> _ensurePublicKey() async {
    if (publicKey.isNotEmpty) return;
    if (_gettingPublicKey) {
      // 等待已有请求完成（最多等待 5s，避免无限等待）
      var waited = 0;
      while (_gettingPublicKey && waited < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waited++;
      }
      return;
    }
    await getPublicKey();
  }

  Future<void> getPublicKey() async {
    if (_gettingPublicKey) return;
    _gettingPublicKey = true;
    try {
      final response = await _apiService.getPublicKey();
      _handleApiResponse(response, onSuccess: (data) {
        publicKey = data['publicKey'] ?? '';
        Get.log('✅ 获取公钥成功: ${publicKey.isNotEmpty ? '[RECEIVED]' : '[EMPTY]'}');
      }, errorMessage: '获取公钥失败');
    } catch (e, st) {
      _logError('获取公钥失败: $e\n$st');
    } finally {
      _gettingPublicKey = false;
    }
  }

  Future<String?> uploadImage(File? img) async {
    try {
      if (img == null) {
        Get.log('图片为空');
        return null;
      }

      Get.log('图片大小: ${img.lengthSync()}');

      Get.log('图片格式: ${img.path.split('.').last}');

      Get.log('图片路径: ${img.path}');

      Get.log('图片名称: ${img.path.split('/').last}');

      // 使用 dio 的 FormData
      final formData = dio.FormData.fromMap({
        "file": await dio.MultipartFile.fromFile(img.path,
            filename: img.path.split('/').last),
      });

      final response = await _apiService.uploadImage(formData);
      return response?['path'] as String?;
    } catch (e, st) {
      _logError('上传图片失败: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateUserInfo(User user) async {
    try {
      final response = await _apiService.updateUserInfo(user.toJson());
      _handleApiResponse(response, onSuccess: (data) {
        Get.log('✅ 更新用户信息成功');
        getUserInfo();
        Get.snackbar('成功', '资料已更新', snackPosition: SnackPosition.TOP);
      }, errorMessage: '更新用户信息失败');
    } catch (e, st) {
      _logError('更新用户信息失败: $e\n$st');
      rethrow;
    }
  }

  Future<void> getUserInfo() async {
    try {
      final response = await _apiService.getUserInfo({'userId': userId.value});
      _handleApiResponse(response, onSuccess: (data) {
        userInfo.value = data;
        Get.log('✅ 获取用户信息成功');
      }, errorMessage: '获取用户信息失败');
    } catch (e, st) {
      _logError('获取用户信息失败: $e\n$st');
      rethrow;
    }
  }

  Future<bool> scanQrCode(String qrCodeContent) async {
    try {
      final response = await _apiService.scanQRCode({
        'qrCode': qrCodeContent,
        'userId': userId.value,
      });
      return _handleApiResponse(response, onSuccess: (data) {
        return data['status'] == _qrAuthorizedCode;
      }, errorMessage: '扫描二维码失败');
    } catch (e, st) {
      _logError('扫描二维码异常: $e\n$st');
      return false;
    }
  }

  // --- 辅助方法 ---

  T _handleApiResponse<T>(
    Map<String, dynamic>? response, {
    required T Function(dynamic) onSuccess,
    required String errorMessage,
  }) {
    if (response != null && response['code'] == _successCode) {
      return onSuccess(response['data']);
    }
    final msg = response?['message'] ?? errorMessage;
    throw Exception(msg);
  }

  Map<String, dynamic>? _safeDecodeJson(dynamic raw) {
    try {
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        // 如果不是 map，尝试转换
        return Map<String, dynamic>.from(decoded as Map);
      } else if (raw is Map<String, dynamic>) {
        return raw;
      } else if (raw != null) {
        return Map<String, dynamic>.from(raw as Map);
      }
    } catch (e) {
      _logError('JSON 解析失败: $e -- 原始: $raw');
    }
    return null;
  }

  void _logError(String message) {
    Get.log(message);
  }
}
