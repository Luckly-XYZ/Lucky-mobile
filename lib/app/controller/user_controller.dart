import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_im/app/api/api_service.dart';
import 'package:flutter_im/app/models/message_receive.dart';
import 'package:flutter_im/utils/objects.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_message.dart';
import '../../utils/rsa.dart';
import '../api/websocket_service.dart';
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
  String publicKey = ''; // RSA 公钥

  // --- 生命周期管理 ---

  @override
  void onInit() {
    super.onInit();

    /// 初始化存储数据和监听器
    _loadStoredData();
    _setupTokenListener();
    _setupUserIdListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    /// 清理资源
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// 监听应用生命周期状态
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        Get.log('📌 应用进入非活动状态');
        break;
      case AppLifecycleState.paused:
        Get.log('⏸️ 应用进入后台');
        _wsService.closeSocket();
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

  /// 从存储中加载用户数据
  Future<void> _loadStoredData() async {
    try {
      final storedToken = await _secureStorage.read(key: _keyToken);
      final storedUserId = _storage.read(_keyUserId);

      if (storedToken != null) token.value = storedToken;
      if (storedUserId != null) userId.value = storedUserId;
    } catch (e) {
      _logError('加载存储数据失败: $e');
    }
  }

  /// 保存用户ID
  void _saveUserId() {
    if (userId.value.isEmpty) {
      _storage.remove(_keyUserId);
    } else {
      _storage.write(_keyUserId, userId.value);
    }
  }

  /// 保存认证令牌
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

  /// 设置用户ID和令牌监听器
  void _setupTokenListener() => ever(token, (_) => checkAuth());

  void _setupUserIdListener() => ever(userId, (_) => _saveUserId());

  // --- 认证管理 ---

  /// 检查用户认证状态
  void checkAuth() {
    if (token.value.isEmpty) {
      Get.log('用户未认证');
    }
  }

  /// 用户登录
  /// @param username 用户名或手机号
  /// @param password 密码或验证码
  /// @param authType 认证类型（form 或 sms）
  /// @return 登录是否成功
  Future<bool> login(String username, String password, String authType) async {
    try {
      await logout(); // 清除现有认证状态
      if (publicKey.isEmpty) await getPublicKey();

      final encryptedPassword = await RSAService.encrypt(password, publicKey);
      Get.log('🔑 加密后的密码: $encryptedPassword');

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
    } catch (e, stackTrace) {
      _logError('登录异常: $e\n$stackTrace');
      return false;
    }
  }

  /// 用户登出
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

  /// 初始化 WebSocket 连接并同步聊天数据
  Future<void> startConnect() async {
    connectWebSocket();
    await _chatController.loadChats(userId.value);
    _chatController.syncChatsAndMessages();
  }

  // --- WebSocket 管理 ---

  /// 连接 WebSocket
  void connectWebSocket() {
    if (token.value.isEmpty || userId.value.isEmpty) return;

    if (!_wsService.isConnected) {
      _wsService.initWebSocket(
        onOpen: () {
          Get.log('WebSocket 连接成功，开始注册');
          _wsService.register(token.value);
        },
        onMessage: _handleWebSocketMessage,
        onError: (error) => Get.log('WebSocket 错误: $error'),
        uid: userId.value,
        token: token.value,
      );
    }
  }

  /// 重新连接 WebSocket
  Future<void> reconnectWebSocket() async {
    await Future.delayed(const Duration(seconds: 2));
    connectWebSocket();
    await _chatController.syncChatsAndMessages();
  }

  /// 处理 WebSocket 消息
  void _handleWebSocketMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String);
      final contentType = IMessageType.fromCode(message['code'] ?? 1);

      switch (contentType) {
        case IMessageType.login:
          Get.log('WebSocket 注册响应: $message');
          break;
        case IMessageType.heartBeat:
          Get.log('WebSocket 心跳响应: $message');
          break;
        case IMessageType.singleMessage:
        case IMessageType.groupMessage:
          IMessage parsedMessage = IMessage.fromJson(message['data']);
          var id = message.messageType == IMessageType.singleMessage.code
              ? (IMessage.toSingleMessage(message, userId.value)).fromId ==
              userId.value
              ? message.toId
              : message.fromId
              : (IMessage.toGroupMessage(message, userId.value)).groupId;
          _chatController.handleCreateOrUpdateChat(parsedMessage, id!, false);
          Get.log(
              'WebSocket ${contentType == IMessageType.singleMessage ? '单聊' : '群聊'}消息接收: $message');
          break;
        case IMessageType.videoMessage:
          final parsedMessage = MessageVideoCallDto.fromJson(message['data']);
          _chatController.handleCallMessage(parsedMessage);
          Get.log('WebSocket 视频消息接收: $message');
          break;
        default:
          Get.log('未知的 WebSocket 消息类型: ${message['code']}');
      }
    } catch (e) {
      _logError('处理 WebSocket 消息出错: $e');
    }
  }

  // --- API 调用 ---

  /// 发送验证码
  /// @param phone 手机号
  Future<void> sendVerificationCode(String phone) async {
    try {
      final response = await _apiService.sendSms({'phone': phone});
      _handleApiResponse(response, onSuccess: (_) {}, errorMessage: '发送验证码失败');
    } catch (e) {
      _logError('发送验证码失败: $e');
      rethrow;
    }
  }

  /// 获取 RSA 公钥
  Future<void> getPublicKey() async {
    try {
      final response = await _apiService.getPublicKey();
      _handleApiResponse(response, onSuccess: (data) {
        publicKey = data['publicKey'] ?? '';
        Get.log('✅ 获取公钥成功: $publicKey');
      }, errorMessage: '获取公钥失败');
    } catch (e) {
      _logError('获取公钥失败: $e');
    }
  }

  /// 获取用户信息
  Future<void> getUserInfo() async {
    try {
      final response = await _apiService.getUserInfo({'userId': userId.value});
      _handleApiResponse(response, onSuccess: (data) {
        userInfo.value = data;
        Get.log('✅ 获取用户信息成功: $data');
      }, errorMessage: '获取用户信息失败');
    } catch (e) {
      _logError('获取用户信息失败: $e');
      rethrow;
    }
  }

  /// 扫描二维码
  /// @param qrCodeContent 二维码内容
  /// @return 扫描是否成功
  Future<bool> scanQrCode(String qrCodeContent) async {
    try {
      final response = await _apiService.scanQRCode({
        'qrCode': qrCodeContent,
        'userId': userId.value,
      });
      return _handleApiResponse(response, onSuccess: (data) {
        return data['status'] == _qrAuthorizedCode;
      }, errorMessage: '扫描二维码失败');
    } catch (e, stackTrace) {
      _logError('扫描二维码异常: $e\n$stackTrace');
      return false;
    }
  }

  // --- 辅助方法 ---

  /// 统一处理 API 响应
  /// @param response API 响应数据
  /// @param onSuccess 成功回调
  /// @param errorMessage 错误提示
  /// @return 成功时返回处理结果，失败时抛出异常
  T _handleApiResponse<T>(
    Map<String, dynamic>? response, {
    required T Function(dynamic) onSuccess,
    required String errorMessage,
  }) {
    if (response != null && response['code'] == _successCode) {
      return onSuccess(response['data']);
    }
    throw Exception(response?['message'] ?? errorMessage);
  }

  /// 记录错误日志
  void _logError(String message) {
    Get.log(message);
  }
}
