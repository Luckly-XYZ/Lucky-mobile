import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoCallSnackbar {
  static void show({
    required String avatar,
    required String username,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: _buildSnackbarContent(
        avatar: avatar,
        username: username,
        onAccept: onAccept,
        onReject: onReject,
      ),
      duration: const Duration(seconds: 30),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15).withOpacity(0.6),
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.all(8),
      snackPosition: SnackPosition.TOP,
    );
  }

  static Widget _buildSnackbarContent({
    required String avatar,
    required String username,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    return Row(
      children: [
        // 头像
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(avatar),
        ),
        const SizedBox(width: 16),
        // 用户名和通话请求文本
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '视频通话请求',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        // 接通按钮
        IconButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            onAccept();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.all(5),
          ),
          icon: const Icon(
            Icons.videocam_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        // 拒绝按钮
        IconButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            onReject();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.all(5),
          ),
          icon: const Icon(
            Icons.call_end_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}
