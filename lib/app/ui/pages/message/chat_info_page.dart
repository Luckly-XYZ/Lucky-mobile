import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String avatarUrl = args['avatar'] ?? '';
    final String name = args['name'] ?? '未知用户';

    return Scaffold(
      appBar: AppBar(
        title: Text('$name 的聊天信息'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户头像
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: 50,
                    height: 50,
                    child: avatarUrl.isNotEmpty
                        ? Image.network(avatarUrl, fit: BoxFit.cover)
                        : const Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 聊天记录
            Text(
              '聊天记录',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            // 这里可以添加聊天记录的显示逻辑
            const SizedBox(height: 20),
            // 消息免打扰
            SwitchListTile(
              title: const Text('消息免打扰'),
              value: false, // 这里可以根据实际状态设置
              onChanged: (value) {
                // 处理免打扰逻辑
              },
            ),
          ],
        ),
      ),
    );
  }
}
