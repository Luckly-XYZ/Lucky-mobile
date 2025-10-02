import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/date.dart';
import '../../../models/message_receive.dart';
import '../../../routes/app_routes.dart';

class MessageBubble extends StatelessWidget {
  final MessageReceiveDto message;

  final bool isMe;

  final String name;

  final String avatar;

  const MessageBubble(
      {Key? key,
      required this.message,
      required this.isMe,
      required this.name,
      required this.avatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMe) ...[
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      getTimeToDisplay(
                          message.messageTime ?? 0, "yy/MM/dd", true),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    TextMessageBody.fromMessageBody(message.messageBody)
                            ?.message ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () {
        if (!isMe) {
          Get.toNamed("${Routes.HOME}${Routes.FRIEND_PROFILE}",
              arguments: {'userId': message.fromId});
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(avatar),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}
