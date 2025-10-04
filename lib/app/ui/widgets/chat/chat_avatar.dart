import 'package:flutter/material.dart';

import '../../../../constants/app_sizes.dart';
import '../../../models/chats.dart';

/// 聊天头像组件，显示用户或群聊头像及未读消息徽章
/// 支持自定义头像形状、徽章样式及大小
class ChatAvatar extends StatelessWidget {
  // 常量定义
  static const _defaultBadgeSize = kSize20; // 默认徽章大小
  static const _defaultBadgeColor = Color(0xffff4d4f); // 默认徽章背景色
  static const _defaultBadgeFontColor = Colors.white; // 默认徽章文字颜色
  static const _defaultAvatarSize = kSize50; // 默认头像大小
  static const _defaultIconSize = kSize40; // 默认占位图标大小
  static const _defaultBorderRadius = 6.0; // 默认矩形头像圆角
  static const _defaultBadgeOffset = -4.0; // 默认徽章偏移量

  final Chats chats; // 聊天数据
  final double badgeSize; // 徽章大小
  final Color badgeColor; // 徽章背景颜色
  final Color badgeFontColor; // 徽章文字颜色
  final BoxShape badgeShape; // 徽章形状
  final BoxShape avatarShape; // 头像形状

  /// 构造函数
  const ChatAvatar({
    super.key,
    required this.chats,
    this.badgeSize = _defaultBadgeSize,
    this.badgeColor = _defaultBadgeColor,
    this.badgeFontColor = _defaultBadgeFontColor,
    this.badgeShape = BoxShape.circle,
    this.avatarShape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // 允许徽章溢出显示
      children: [
        /// 头像容器
        _buildAvatar(),

        /// 未读消息徽章
        if (chats.unread > 0) _buildBadge(),
      ],
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Container(
      width: _defaultAvatarSize,
      height: _defaultAvatarSize,
      decoration: BoxDecoration(
        color: Colors.grey[300], // 默认背景色
        shape: avatarShape,
        borderRadius: avatarShape == BoxShape.rectangle
            ? BorderRadius.circular(_defaultBorderRadius)
            : null,
        image: chats.avatar.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(chats.avatar),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // 头像加载失败时记录日志
                  debugPrint('头像加载失败: $exception');
                },
              )
            : null,
      ),
      child: chats.avatar.isEmpty
          ? Icon(
              Icons.person,
              size: _defaultIconSize,
              color: Colors.grey[700],
            )
          : null,
    );
  }

  /// 构建未读消息徽章
  Widget _buildBadge() {
    return Positioned(
      top: _defaultBadgeOffset,
      right: _defaultBadgeOffset,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: badgeShape,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          chats.unread >= 99 ? '99+' : chats.unread.toString(),
          style: TextStyle(
            color: badgeFontColor,
            fontSize: badgeSize * 0.5, // 动态调整字体大小
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
