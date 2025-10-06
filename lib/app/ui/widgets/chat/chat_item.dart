import 'package:flutter/material.dart';
import 'package:flutter_im/app/models/chats.dart';
import 'package:flutter_im/constants/app_colors.dart';
import 'package:flutter_im/utils/date.dart';

import 'chat_avatar.dart';

/// 聊天列表项组件，显示聊天头像、名称、最新消息和时间
/// 支持自定义样式，适配主题化显示
class ChatItem extends StatelessWidget {
  // 常量定义
  static const _avatarSize = 50.0; // 头像尺寸
  static const _avatarSpacing = 8.0; // 头像与内容的间距
  static const _verticalPadding = 4.0; // 垂直内边距
  static const _horizontalPadding = 4.0; // 水平内边距
  static const _contentSpacing = 4.0; // 内容行间距
  static const _nameStyle = TextStyle(
    color: kColor33,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  ); // 聊天名称样式
  static const _timeStyle = TextStyle(
    color: kColor99,
    fontSize: 12.0,
  ); // 时间样式
  static const _messageStyle = TextStyle(
    color: kColor99,
    fontSize: 14.0,
  ); // 消息内容样式
  static const _timeFormat = 'yy/MM/dd'; // 时间格式

  final Chats chats; // 聊天数据

  /// 构造函数
  const ChatItem({
    required this.chats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _verticalPadding,
        horizontal: _horizontalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 聊天头像
          _buildAvatar(),
          const SizedBox(width: _avatarSpacing),

          /// 聊天内容（名称、时间、消息）
          _buildContent(),
        ],
      ),
    );
  }

  /// 构建聊天头像
  Widget _buildAvatar() {
    return SizedBox(
      width: _avatarSize,
      height: _avatarSize,
      child: ChatAvatar(chats: chats),
    );
  }

  /// 构建聊天内容区域（名称、时间、最新消息）
  Widget _buildContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 名称和时间行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// 聊天名称
              Expanded(
                child: Text(
                  chats.name,
                  style: _nameStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              /// 消息时间
              Text(
                DateUtil.getTimeToDisplay(chats.messageTime, _timeFormat, true),
                style: _timeStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: _contentSpacing),

          /// 最新消息
          Text(
            chats.message ?? '',
            style: _messageStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
