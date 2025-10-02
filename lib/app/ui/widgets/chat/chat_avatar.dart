import 'package:flutter/material.dart';

import '../../../../constants/app_sizes.dart';
import '../../../models/chats.dart';

class ChatAvatar extends StatelessWidget {
  final Chats chats;

  // 徽章的大小，默认值为 24.0
  final double badgeSize;

  // 徽章的背景颜色，默认值为 #ff4d4f
  final Color badgeColor;

  // 徽章内文字的颜色，默认值为白色
  final Color badgeFontColor;

  // 徽章的形状，默认值为圆形
  final BoxShape badgeShape;

  // 头像的形状，默认值为圆形
  final BoxShape avatarShape;

  ChatAvatar(
      {super.key,
      required this.chats,
      this.badgeSize = kSize20,
      this.badgeColor = const Color(0xffff4d4f),
      this.badgeFontColor = Colors.white,
      this.badgeShape = BoxShape.circle,
      this.avatarShape = BoxShape.rectangle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // 允许徽章溢出显示
      children: [
        // 头像部分：使用圆形头像
        Container(
          width: kSize50,
          height: kSize50,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: avatarShape,
            borderRadius: avatarShape == BoxShape.rectangle
                ? BorderRadius.circular(6) // 矩形时添加圆角
                : null, // 圆形时不需要圆角
            image: (chats.avatar.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(chats.avatar),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          // 当没有头像时显示默认的占位图标
          child: (chats.avatar.isEmpty)
              ? Center(
                  child: Icon(
                    Icons.person,
                    size: kSize40,
                    color: Colors.grey[700],
                  ),
                )
              : null,
        ),
        // 徽章部分：显示未读消息数
        if (chats.unread > 0)
          Positioned(
            top: -4,
            right: -4,
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
                  fontSize: badgeSize * 0.5, // 根据徽章大小设置字体大小
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
