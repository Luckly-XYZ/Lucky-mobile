import 'package:flutter/material.dart';

import '../../../models/message_receive.dart';

class ImageBubble extends StatelessWidget {
  final MessageReceiveDto message;
  final bool isMe;

  const ImageBubble({Key? key, required this.message, required this.isMe})
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
                _buildTimeAndName(),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // 点击查看大图
                  },
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      maxHeight: 200,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.messageBody.toString(),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
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

  Widget _buildTimeAndName() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMe) ...[
          Text(
            "用户名",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          _formatTime(message.messageTime ?? 0),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
