import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../routes/app_routes.dart';
import '../../../controller/user_controller.dart';
import '../../widgets/icon/icon_font.dart';

/// 个人中心页面，展示用户信息和功能入口
/// 特性：
/// - 显示用户头像、用户名、性别和个性签名。
/// - 提供扫一扫、设置、退出登录等功能入口。
/// - 支持二维码页面导航，展示用户二维码。
class MyPage extends StatelessWidget {
  // 常量定义
  static const _userInfoPadding =
      EdgeInsets.symmetric(vertical: 20, horizontal: 16); // 用户信息边距
  static const _avatarSize = 50.0; // 头像尺寸
  static const _avatarBorderRadius = 6.0; // 头像圆角
  static const _avatarPlaceholderColor = Colors.grey; // 头像占位颜色
  static const _usernameStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold); // 用户名样式
  static const _signatureStyle =
      TextStyle(fontSize: 14, color: Colors.grey); // 个性签名样式
  static const _listSpacing = 12.0; // 列表间距
  static const _defaultUsername = '未登录'; // 默认用户名
  static const _defaultSignature = '这个人很神秘...'; // 默认个性签名
  static const _defaultAvatar = ''; // 默认头像 URL

  /// 性别图标映射表
  static const _genderIcons = {
    '1': Icon(Icons.male, color: Colors.blue, size: 18),
    '0': Icon(Icons.female, color: Colors.pink, size: 18),
  };

  /// 列表项数据
  static final _listItems = [

    const _ListItemData(
      icon: Iconfont.search,
      title: '扫一扫',
      route: '${Routes.HOME}${Routes.SCAN}',
    ),
    const _ListItemData(
      icon: Iconfont.setting,
      title: '设置',
      route: null, // TODO: 实现设置页面路由
    ),
    const _ListItemData(
      icon: Icons.exit_to_app,
      title: '退出登录',
      action: _logout,
    ),
  ];

  const MyPage({super.key});

  /// 执行退出登录操作
  static void _logout() {
    Get.find<UserController>().logout();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            /// 用户信息
            _buildUserInfo(userController),
            const SizedBox(height: _listSpacing),

            /// 功能列表
            _buildListItems(),
          ],
        ),
      ),
    );
  }

  // --- UI 构建方法 ---

  /// 构建用户信息区域
  Widget _buildUserInfo(UserController controller) {
    return GetX<UserController>(
      builder: (controller) {
        final userInfo = controller.userInfo;
        final username = userInfo['name'] as String? ?? _defaultUsername;
        final signature =
            userInfo['selfSignature'] as String? ?? _defaultSignature;
        final avatarUrl = userInfo['avatar'] as String? ?? _defaultAvatar;
        final gender = userInfo['gender']?.toString();

        return Container(
          padding: _userInfoPadding,
          color: Colors.white,
          child: Row(
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
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('加载头像失败: $error');
                            return Container(
                              color: _avatarPlaceholderColor[300],
                              child: const Icon(Icons.person,
                                  size: 45, color: Colors.white),
                            );
                          },
                        )
                      : Container(
                          color: _avatarPlaceholderColor[300],
                          child: const Icon(Icons.person,
                              size: 45, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              /// 用户名和个性签名
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Get.toNamed('${Routes.HOME}${Routes.USER_PROFILE}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(username, style: _usernameStyle),
                          const SizedBox(width: 5),
                          if (_genderIcons.containsKey(gender))
                            _genderIcons[gender]!,
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(signature, style: _signatureStyle),
                    ],
                  ),
                ),
              ),

              /// 二维码按钮
              IconButton(
                icon: const Icon(Icons.qr_code, size: kSize22),
                onPressed: () =>
                    Get.toNamed('${Routes.HOME}${Routes.MY_QR_CODE}'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建功能列表项
  Widget _buildListItems() {
    return Container(
      color: Colors.white,
      child: Column(
        children: _listItems
            .map((item) => ListTile(
                  leading: Icon(item.icon, color: Colors.black87),
                  title: Text(item.title),
                  onTap: item.route != null
                      ? () => Get.toNamed(item.route!)
                      : item.action != null
                          ? item.action
                          : null,
                ))
            .toList(),
      ),
    );
  }
}

/// 列表项数据类
class _ListItemData {
  final IconData icon;
  final String title;
  final String? route;
  final VoidCallback? action;

  const _ListItemData({
    required this.icon,
    required this.title,
    this.route,
    this.action,
  });
}
