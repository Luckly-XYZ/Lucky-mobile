import 'package:flutter/material.dart';
import 'package:flutter_im/app/models/chats.dart';
import 'package:flutter_im/constants/app_colors.dart';
import 'package:flutter_im/utils/date.dart';

import 'chat_avatar.dart';

class ChatItem extends StatelessWidget {
  final Chats chats;

  const ChatItem({required this.chats, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 整体内边距缩小
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 缩小头像尺寸：这里使用 SizedBox 控制大小（假设 ChatAvatar 默认尺寸较大）
          SizedBox(
            width: 50,
            height: 50,
            child: ChatAvatar(chats: chats),
          ),
          // 头像与聊天内容之间的间隔缩小
          const SizedBox(width: 8.0),
          // 聊天内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：名称和时间
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 聊天名称，字体略微缩小
                    Expanded(
                      child: Text(
                        chats.name,
                        style: const TextStyle(
                          color: kColor33,
                          fontSize: 16, // 字体缩小
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 消息时间，字体缩小
                    Text(
                      getTimeToDisplay(chats.messageTime, "yy/MM/dd", true),
                      style: const TextStyle(
                        color: kColor99,
                        fontSize: 12, // 字体缩小
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 4.0), // 行间距缩小
                // 第二行：消息内容
                Text(
                  chats.message,
                  style: const TextStyle(
                    color: kColor99,
                    fontSize: 14, // 字体缩小
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
