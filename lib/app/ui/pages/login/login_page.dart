import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                24.0, MediaQuery.of(context).size.height * 0.1, 24.0, 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 32),
                SizedBox(
                  height: 320, // 减小高度从380到320
                  child: TabBarView(
                    controller: controller.tabController,
                    physics: const NeverScrollableScrollPhysics(), // 禁止滑动切换
                    children: [
                      _buildLoginForm(context, true), // 密码登录
                      _buildLoginForm(context, false), // 验证码登录
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwitchAuthTypeRow(context),
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: Get.theme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '欢迎登录',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Get.theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchAuthTypeRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.currentAuthType == AuthType.password ? '还没有账号？' : '已有账号？',
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            controller.tabController.animateTo(
              controller.currentAuthType == AuthType.password ? 1 : 0,
            );
          },
          child: Text(
            controller.currentAuthType == AuthType.password
                ? '验证码登录'
                : '账号密码登录',
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isPasswordMode) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.principalController,
            decoration: InputDecoration(
              labelText: isPasswordMode ? '账号' : '手机号',
              labelStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
              ),
              prefixIcon: Icon(
                isPasswordMode ? Icons.person : Icons.phone,
                color: theme.primaryColor,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            keyboardType:
                isPasswordMode ? TextInputType.text : TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.credentialsController,
            decoration: InputDecoration(
              labelText: isPasswordMode ? '密码' : '验证码',
              labelStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
              ),
              prefixIcon: Icon(
                isPasswordMode ? Icons.lock : Icons.security,
                color: theme.primaryColor,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: !isPasswordMode
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Obx(() => TextButton(
                            onPressed: controller.canSendCode.value
                                ? controller.sendVerificationCode
                                : null,
                            style: TextButton.styleFrom(
                              foregroundColor: theme.primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Text(
                              controller.canSendCode.value
                                  ? '发送验证码'
                                  : '${controller.countDown}s',
                              style: TextStyle(
                                fontSize: 14,
                                color: controller.canSendCode.value
                                    ? theme.primaryColor
                                    : Colors.grey,
                              ),
                            ),
                          )),
                    )
                  : null,
            ),
            obscureText: isPasswordMode,
            keyboardType:
                isPasswordMode ? TextInputType.text : TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.handleLogin(),
          ),
          if (isPasswordMode) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Obx(() => Checkbox(
                      value: controller.rememberCredentials.value,
                      onChanged: (value) {
                        controller.rememberCredentials.value = value ?? false;
                      },
                      activeColor: theme.primaryColor,
                    )),
                GestureDetector(
                  onTap: () {
                    controller.rememberCredentials.value =
                        !controller.rememberCredentials.value;
                  },
                  child: Text(
                    '记住密码',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: theme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '登录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                )),
          ),
        ],
      ),
    );
  }
}
