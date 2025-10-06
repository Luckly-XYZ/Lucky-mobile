import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                24.0, MediaQuery.of(context).size.height * 0.15, 24.0, 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(context),
                const SizedBox(height: 40),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: controller.tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildLoginForm(context, true),
                      _buildLoginForm(context, false),
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

  Widget _buildLogo(BuildContext context) {
    // 统一大小与圆角
    const double avatarSize = 80;
    const double borderRadius = 12;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.asset(
            'assets/logo/app_icon.png',
            width: avatarSize,
            height: avatarSize,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '欢迎登录',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
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
          style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isPasswordMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              labelStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
              prefixIcon: Icon(
                isPasswordMode ? Icons.person_outline : Icons.phone_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFf5f7fa),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType:
                isPasswordMode ? TextInputType.text : TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: isPasswordMode
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ]
                : null,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.credentialsController,
            decoration: InputDecoration(
              labelText: isPasswordMode ? '密码' : '验证码',
              labelStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
              prefixIcon: Icon(
                isPasswordMode ? Icons.lock_outline : Icons.security_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFf5f7fa),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: !isPasswordMode
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Obx(() => TextButton(
                            onPressed: controller.canSendCode.value
                                ? controller.sendVerificationCode
                                : null,
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 30),
                            ),
                            child: Text(
                              controller.canSendCode.value
                                  ? '发送验证码'
                                  : '${controller.countDown}s',
                              style: TextStyle(
                                fontSize: 13,
                                color: controller.canSendCode.value
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFcccccc),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Obx(() => Checkbox(
                      value: controller.rememberCredentials.value,
                      onChanged: (value) {
                        controller.rememberCredentials.value = value ?? false;
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                    )),
                GestureDetector(
                  onTap: () {
                    controller.rememberCredentials.value =
                        !controller.rememberCredentials.value;
                  },
                  child: const Text(
                    '记住密码',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFa0cfff),
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
                            fontWeight: FontWeight.w500,
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
