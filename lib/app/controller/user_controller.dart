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

class UserController extends GetxController with WidgetsBindingObserver {
  static UserController get to => Get.find();

  // ================ 依赖注入 ================
  final storage = GetStorage();
  final secureStorage = const FlutterSecureStorage();
  final ApiService _apiService = Get.find<ApiService>();
  final WebSocketService _wsService = Get.find<WebSocketService>();
  final ChatController _chatController = Get.find<ChatController>();

  // ================ 存储键名常量 ================
  static const String KEY_USER_ID = 'userId';
  static const String KEY_TOKEN = 'token';

  // ================ 状态变量 ================
  var userId = ''.obs;
  var token = ''.obs;
  var userInfo = {}.obs;
  String publicKey = "";

  // ================ 生命周期方法 ================
  @override
  void onInit() {
    super.onInit();
    _loadStoredData();
    _setupTokenListener();
    _setupUserIdListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 监听应用生命周期状态
  /// https://juejin.cn/post/7175445675872616506
  ///
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // ⚠️ 应用处于非活动状态，但仍然可见
        // 可能的情况：
        // 📞 用户接听电话
        // 🔔 跳出系统弹窗（如权限请求）
        // 🔄 切换到其他应用的过渡状态
        Get.log('📌 应用进入非活动状态');
        break;

      case AppLifecycleState.paused:
        // 💤 应用进入后台，不再可见
        // 可能的情况：
        // ⏬ 用户按下 Home 键（最小化应用）
        // 🔒 设备锁屏
        Get.log('⏸️ 应用进入后台');
        _wsService.closeSocket(); // ❌ 断开 WebSocket 连接，避免后台被杀时异常

        //startBackgroundWebSocketConnection(); // 🔗 在后台启动 WebSocket 连接

        break;

      case AppLifecycleState.resumed:
        // 🔄 应用恢复前台并可交互
        // 可能的情况：
        // 🚀 用户重新打开应用
        // 🔓 设备解锁后恢复应用
        Get.log('✅ 应用恢复到前台');
        reconnectWebSocket(); // 🔗 重新连接 WebSocket，确保通信正常
        break;

      case AppLifecycleState.detached:
        // 🚫 应用仍在运行，但 UI 已分离
        // 可能的情况：
        // 📌 Android 设备长按 Home 键进入任务管理器
        // 🎛 iOS 设备上拉控制中心
        // 🔄 开发模式下热重载
        Get.log('🔌 应用 UI 已分离');
        break;

      case AppLifecycleState.hidden:
        // 👀 应用仍在内存中，但不可见（Flutter 3.13+）
        // 可能的情况：
        // 🖼 Android 设备进入画中画模式
        // 🏷 某些厂商的系统优化导致应用隐藏
        Get.log('👻 应用已隐藏');
        break;
    }
  }

  // ================ 数据持久化方法 ================
  /// 从存储中加载用户数据
  void _loadStoredData() async {
    final storedToken = await secureStorage.read(key: KEY_TOKEN);
    final storedUserId = storage.read(KEY_USER_ID);

    if (storedToken != null) token.value = storedToken;
    if (storedUserId != null) userId.value = storedUserId;
  }

  void _delToken() async {
    await secureStorage.delete(key: KEY_TOKEN);
  }

  /// 保存 token 到安全存储
  void _saveToken() async {
    if (token.value.isEmpty) {
      await secureStorage.delete(key: KEY_TOKEN);
    } else {
      await secureStorage.write(key: KEY_TOKEN, value: token.value);
    }
  }

  /// 保存用户 ID
  void _saveUserId() {
    if (userId.value.isEmpty) {
      storage.remove(KEY_USER_ID);
    } else {
      storage.write(KEY_USER_ID, userId.value);
    }
  }

  /// 设置 token 监听器
  void _setupTokenListener() {
    ever(token, (_) {
      checkAuth();
      _saveToken();
    });
  }

  /// 设置用户 ID 监听器
  void _setupUserIdListener() {
    ever(userId, (_) => _saveUserId());
  }

  // ================ 认证相关方法 ================
  /// 检查用户认证状态
  void checkAuth() {
    if (token.value.isEmpty) {
      Get.log("用户未认证");
    }
  }

  /// 用户登录
  ///
  /// [username] 用户名
  /// [password] 密码
  /// [authType] 认证类型
  ///
  /// 返回登录是否成功
  Future<bool> login(String username, String password, String authType) async {
    try {
      await logout();

      if (publicKey.isEmpty) await getPublicKey();

      String encryptedPassword = await RSAService.encrypt(password, publicKey);
      Get.log("🔑 加密后的密码: $encryptedPassword");

      Map<String, dynamic> loginData = {
        "principal": username,
        "credentials": encryptedPassword,
        "authType": authType
      };

      var response = await _apiService.login(loginData);
      Get.log("🔹 登录接口响应: $response");

      if (Objects.isNotEmpty(response) &&
          Objects.isNotEmpty(response?['data'])) {
        var data = response?['data'];
        if (  Objects.isNotBlank(data['accessToken'])  && Objects.isNotBlank(data['userId'])) {
          token.value = data['accessToken'];
          userId.value = data['userId'];
          startConnect();
          return true;
        }
      }
      return false;
    } catch (e, stackTrace) {
      Get.log("🚨 登录异常: $e\n$stackTrace");
      return false;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    _wsService.closeSocket();
    token.value = "";
    userId.value = "";
    userInfo.value = {};
    await secureStorage.delete(key: KEY_TOKEN);
    await storage.remove(KEY_USER_ID);
  }

  Future<void> startConnect() async {
    connectWebSocket();
    await _chatController.initializeChats(userId.value);
    await _chatController.syncChatsAndMessages();
  }

  // ================ WebSocket 相关方法 ================
  /// 连接 WebSocket
  void connectWebSocket() {
    if (token.value.isEmpty && userId.value.isEmpty) return;

    if (!_wsService.isConnected) {
      _wsService.initWebSocket(
          onOpen: () {
            Get.log('WebSocket 连接成功，开始注册');
            _wsService.register(token.value);
          },
          onMessage: (data) {
            //Get.log('收到 WebSocket 消息: $data');
            _handleWebSocketMessage(data);
          },
          onError: (error) {
            Get.log('WebSocket 错误: $error');
          },
          uid: userId.value,
          token: token.value);
    }
  }

  /// 重新连接 WebSocket
  void reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 2), () async {
      connectWebSocket();
      await _chatController.syncChatsAndMessages();
    });
  }

  /// 处理 WebSocket 消息
  void _handleWebSocketMessage(String data) {
    try {
      final message = jsonDecode(data);
      final contentType = MessageType.fromCode(message['code'] ?? 1);

      switch (contentType) {
        case MessageType.login:
          // 注册响应
          Get.log('WebSocket 注册响应: $message');
          break;
        case MessageType.heartBeat:
          // 心跳响应
          Get.log('WebSocket 心跳响应: $message');
          break;
        case MessageType.singleMessage:
          // 单聊消息接收
          final parsedMessage = MessageReceiveDto.fromJson(message['data']);
          _chatController.handleCreateOrUpdateChat(parsedMessage, false);
          Get.log('WebSocket 单聊消息接收: $message');
          break;
        case MessageType.groupMessage:
          // 群聊消息接收
          final parsedMessage = MessageReceiveDto.fromJson(message['data']);
          _chatController.handleCreateOrUpdateChat(parsedMessage, false);
          Get.log('WebSocket 群聊消息接收: $message');
          break;
        case MessageType.videoMessage:
          // 视频消息接收
          final parsedMessage = MessageVideoCallDto.fromJson(message['data']);
          _chatController.handleCallMessage(parsedMessage);
          Get.log('WebSocket 视频消息接收: $message');
          break;
        default:
          Get.log('未知的 WebSocket 消息类型: ${message['code']}');
          break;
      }
    } catch (e) {
      Get.log('处理 WebSocket 消息出错: $e');
    }
  }

  // ================ 用户相关 API 方法 ================
  /// 发送验证码
  Future<void> sendVerificationCode(String phone) async {
    await _apiService.sendSms({"phone": phone});
  }

  /// 获取 RSA 公钥
  Future<void> getPublicKey() async {
    var response = await _apiService.getPublicKey();
    if (response != null && response['data'] != null) {
      Get.log("✅ 获取公钥成功: $response");
      publicKey = response['data']['publicKey'];
    } else {
      Get.log("❌ 获取公钥失败");
    }
  }

  /// 获取用户信息
  Future<void> getUserInfo() async {
    try {
      final response = await _apiService.getUserInfo({"userId": userId});
      if (response != null && response['data'] != null) {
        Get.log("✅ 获取用户信息成功: $response");
        userInfo.value = response['data'];
      } else {
        Get.log("❌ 获取用户信息失败");
      }
    } catch (e) {
      Get.log('获取用户信息失败: $e');
      rethrow;
    }
  }

  /// 扫描二维码
  ///
  /// [qrCodeContent] 二维码内容
  /// 返回扫描是否成功
  Future<bool> scanQrCode(String qrCodeContent) async {
    try {
      final response = await _apiService.scanQRCode({
        "qrCode": qrCodeContent,
        "userId": userId.value,
      });

      return response != null &&
          response['code'] == 200 &&
          response['data']['status'] == "AUTHORIZED";
    } catch (error, stackTrace) {
      Get.log("扫描二维码异常: $error\n$stackTrace");
      return false;
    }
  }

// 新增方法：在后台启动 WebSocket 连接

// void startBackgroundWebSocketConnection() {

//   Workmanager().registerOneOffTask(

//       'websocket_connection',

//       'connectWebSocket',

//       initialDelay: Duration(seconds: 1), // 可根据需要调整延迟

//       inputData: {

//           'userId': userId.value,

//           'token': token.value,

//       },

//   );

// }
}
