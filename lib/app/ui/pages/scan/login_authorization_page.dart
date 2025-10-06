import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../routes/app_routes.dart';
import '../../../controller/home_controller.dart';
import '../../../controller/user_controller.dart';

/// 登录授权页面，确认用户通过二维码扫描登录设备
/// 特性：
/// - 显示用户头像和授权确认提示。
/// - 提供“取消”和“确认登录”按钮，执行相应操作。
/// - 支持头像加载和错误处理，提升用户体验。
class AuthorizationPage extends StatelessWidget {
  // 常量定义
  static const _avatarSize = 120.0; // 头像容器尺寸
  static const _avatarBorderRadius = 6.0; // 头像圆角
  static const _avatarPlaceholderColor = Colors.grey; // 头像占位颜色
  static const _avatarBackgroundOpacity = 0.1; // 头像背景透明度
  static const _padding = EdgeInsets.all(24); // 页面边距
  static const _titleStyle =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold); // 标题样式
  static const _subtitleStyle =
      TextStyle(fontSize: 16, color: Colors.grey); // 副标题样式
  static const _buttonPadding =
      EdgeInsets.symmetric(horizontal: kSize32, vertical: kSize12); // 按钮内边距
  static const _buttonBorderRadius = 8.0; // 按钮圆角
  static const _buttonTextStyle =
      TextStyle(fontSize: kSize16, fontWeight: FontWeight.w500); // 按钮文本样式
  static const _defaultAvatar = ''; // 默认头像 URL

  final String code; // 二维码数据

  const AuthorizationPage({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('登录授权'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: Get.back, // 使用 Get.back 替代 Navigator.pop
        ),
      ),
      body: GetBuilder<UserController>(
        builder: (controller) => Container(
          padding: _padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 用户头像
              _buildAvatar(controller.userInfo, context),
              const SizedBox(height: kSize32),

              /// 标题
              Text(
                '授权确认',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ??
                    _titleStyle,
              ),
              const SizedBox(height: kSize16),

              /// 副标题
              Text(
                '是否确认授权登录该设备？',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ) ??
                    _subtitleStyle,
              ),
              const SizedBox(height: kSize40),

              /// 按钮区域
              _buildButtons(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI 构建方法 ---

  /// 构建用户头像区域
  Widget _buildAvatar(Map<dynamic, dynamic> userInfo, BuildContext context) {
    final avatarUrl = userInfo['avatar'] as String? ?? _defaultAvatar;

    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .primaryColor
            .withOpacity(_avatarBackgroundOpacity),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_avatarBorderRadius),
          child: SizedBox(
            width: kSize35,
            height: kSize35,
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('加载头像失败: $error');
                      return Container(
                        color: _avatarPlaceholderColor[300],
                        child: const Icon(Icons.person,
                            size: kSize35, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    color: _avatarPlaceholderColor[300],
                    child: const Icon(Icons.person,
                        size: kSize35, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  /// 构建取消和确认按钮
  Widget _buildButtons(BuildContext context, UserController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// 取消按钮
        OutlinedButton(
          onPressed: Get.back,
          style: OutlinedButton.styleFrom(
            padding: _buttonPadding,
            side: BorderSide(color: Theme.of(context).primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
            ),
          ),
          child: Text(
            '取消',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: kSize16,
            ),
          ),
        ),
        const SizedBox(width: kSize20),

        /// 确认登录按钮
        ElevatedButton(
          onPressed: () async {
            final success = await controller.scanQrCode(code);
            if (success) {
              Get.offAllNamed(Routes.HOME);
              Get.find<HomeController>().changeTabIndex(0);
            } else {
              // TODO: 显示授权失败提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('授权失败，请重试')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: _buttonPadding,
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
            ),
          ),
          child: Text(
            '确认登录',
            style: _buttonTextStyle.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
