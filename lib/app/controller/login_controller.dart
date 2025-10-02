import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import 'user_controller.dart';

enum AuthType {
  password, // 密码登录
  verifyCode // 验证码登录
}

class LoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static const String KEY_SAVED_USERNAME = 'saved_username';
  static const String KEY_SAVED_PASSWORD = 'saved_password';

  //final storage = GetStorage();
  final secureStorage = const FlutterSecureStorage();

  // 用户
  UserController userController = Get.find<UserController>();

  late TabController tabController;
  final principalController = TextEditingController();
  final credentialsController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool rememberCredentials = false.obs;
  final RxBool canSendCode = true.obs;
  final RxInt countDown = 60.obs;
  Timer? _timer;

  AuthType get currentAuthType =>
      tabController.index == 0 ? AuthType.password : AuthType.verifyCode;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabChange);
    loadPublicKey();
    loadSavedCredentials();
  }

  @override
  void onClose() {
    _timer?.cancel();
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    principalController.dispose();
    credentialsController.dispose();
    super.onClose();
  }

  void _handleTabChange() {
    if (tabController.indexIsChanging) {
      principalController.clear();
      credentialsController.clear();
    }
  }

  Future<void> handleLogin() async {
    if (isLoading.value) return;

    if (principalController.text.isEmpty ||
        credentialsController.text.isEmpty) {
      String message =
          currentAuthType == AuthType.password ? '请输入账号和密码' : '请输入手机号和验证码';
      Get.snackbar('提示', message);
      return;
    }

    if (currentAuthType == AuthType.verifyCode) {
      final phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
      if (!phoneRegExp.hasMatch(principalController.text)) {
        Get.snackbar('提示', '请输入正确的手机号格式');
        return;
      }
    }

    isLoading.value = true;

    try {
      String authType = currentAuthType == AuthType.password ? 'form' : 'sms';
      bool loginRes = await userController.login(
        principalController.text,
        credentialsController.text,
        authType,
      );

      if (loginRes) {
        if (currentAuthType == AuthType.password) {
          if (rememberCredentials.value) {
            await saveCredentials(
              principalController.text,
              credentialsController.text,
            );
          } else {
            await clearSavedCredentials();
          }
        }

        try {
          await userController.getUserInfo();
          Get.offNamed(Routes.HOME);
        } catch (e) {
          Get.snackbar('错误', '获取用户信息失败，请重新登录');
        }
      }
    } catch (e) {
      Get.snackbar('错误', '登录失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void startCountDown() {
    canSendCode.value = false;
    countDown.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countDown.value == 0) {
        timer.cancel();
        canSendCode.value = true;
      } else {
        countDown.value--;
      }
    });
  }

  Future<void> sendVerificationCode() async {
    if (!canSendCode.value) return;

    if (principalController.text.isEmpty) {
      Get.snackbar('提示', '请输入手机号');
      return;
    }

    final phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegExp.hasMatch(principalController.text)) {
      Get.snackbar('提示', '请输入正确的手机号格式');
      return;
    }

    try {
      await userController.sendVerificationCode(principalController.text);
      Get.snackbar('提示', '验证码已发送');
      startCountDown();
    } catch (e) {
      Get.snackbar('错误', '发送验证码失败: ${e.toString()}');
    }
  }

  Future<void> loadPublicKey() async {
    userController.getPublicKey();
  }

  Future<void> loadSavedCredentials() async {
    try {
      final savedCredentials = await getSavedCredentials();
      if (savedCredentials != null) {
        principalController.text = savedCredentials['username']!;
        credentialsController.text = savedCredentials['password']!;
        rememberCredentials.value = true;
        if (tabController.index != 0) {
          tabController.animateTo(0);
        }
      }
    } catch (e) {
      Get.log('加载保存的凭证失败: $e');
    }
  }

  Future<void> saveCredentials(String username, String password) async {
    await secureStorage.write(key: KEY_SAVED_USERNAME, value: username);
    await secureStorage.write(key: KEY_SAVED_PASSWORD, value: password);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final username = await secureStorage.read(key: KEY_SAVED_USERNAME);
    final password = await secureStorage.read(key: KEY_SAVED_PASSWORD);

    if (username != null && password != null) {
      return {
        'username': username,
        'password': password,
      };
    }
    return null;
  }

  Future<void> clearSavedCredentials() async {
    await secureStorage.delete(key: KEY_SAVED_USERNAME);
    await secureStorage.delete(key: KEY_SAVED_PASSWORD);
  }
}
