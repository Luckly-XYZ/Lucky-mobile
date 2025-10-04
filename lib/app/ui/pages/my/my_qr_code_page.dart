import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../constants/app_constant.dart';
import '../../../controller/user_controller.dart';

/// 我的二维码页面，展示用户二维码以便添加好友
/// 特性：
/// - 显示用户头像、用户名和二维码。
/// - 支持扫描二维码跳转到好友资料页面。
/// - 提供加载和错误处理，确保头像显示健壮。
class MyQRCodePage extends StatelessWidget {
  // 常量定义
  static const _qrSize = 240.0; // 二维码尺寸
  static const _containerPadding = 10.0; // 二维码容器内边距
  static const _containerWidth = _qrSize + (_containerPadding * 2); // 二维码容器宽度
  static const _avatarSize = 50.0; // 头像尺寸
  static const _avatarBorderRadius = 6.0; // 头像圆角
  static const _avatarPlaceholderColor = Colors.grey; // 头像占位颜色
  static const _usernameStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w500); // 用户名样式
  static const _hintStyle =
      TextStyle(fontSize: 14, color: Colors.grey); // 提示文本样式
  static const _padding =
      EdgeInsets.symmetric(horizontal: 40, vertical: 30); // 页面边距
  static const _spacing = 30.0; // 垂直间距
  static const _defaultUsername = '未登录'; // 默认用户名
  static const _defaultUserId = ''; // 默认用户 ID
  static const _defaultAvatar = ''; // 默认头像 URL

  const MyQRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的二维码'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: Get.back,
        ),
      ),
      body: GetX<UserController>(
        builder: (controller) => Container(
          width: double.infinity,
          padding: _padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: _spacing),

              /// 用户信息
              _buildUserInfo(controller.userInfo),
              const SizedBox(height: _spacing),

              /// 二维码
              _buildQRCode(controller.userInfo, context),
              const SizedBox(height: 16),

              /// 提示文字
              const Center(
                child: Text(
                  '扫一扫上面的二维码，加我为好友',
                  style: _hintStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI 构建方法 ---

  /// 构建用户信息区域（头像和用户名）
  Widget _buildUserInfo(Map<dynamic, dynamic> userInfo) {
    final username = userInfo['name'] as String? ?? _defaultUsername;
    final avatarUrl = userInfo['avatar'] as String? ?? _defaultAvatar;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// 头像
        ClipRRect(
          borderRadius: BorderRadius.circular(_avatarBorderRadius),
          child: SizedBox(
            width: _avatarSize,
            height: _avatarSize,
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
                            size: 40, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    color: _avatarPlaceholderColor[300],
                    child:
                        const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(width: 16),

        /// 用户名
        Expanded(
          child: Text(
            username,
            style: _usernameStyle,
          ),
        ),
      ],
    );
  }

  /// 构建二维码区域
  Widget _buildQRCode(Map<dynamic, dynamic> userInfo, BuildContext context) {
    final userId = userInfo['userId']?.toString() ?? _defaultUserId;
    final avatarUrl = userInfo['avatar'] as String? ?? _defaultAvatar;
    final qrData =
        Uri.encodeComponent('${AppConstants.FRIEND_PROFILE_PREFIX}$userId');

    return Center(
      child: Container(
        width: _containerWidth,
        padding: const EdgeInsets.all(_containerPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_avatarBorderRadius),
        ),
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: _qrSize,
          backgroundColor: Colors.white,
          embeddedImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          errorStateBuilder: (context, error) {
            debugPrint('二维码生成失败: $error');
            return const Center(
              child: Text(
                '二维码生成失败',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            );
          },
        ),
      ),
    );
  }
}
