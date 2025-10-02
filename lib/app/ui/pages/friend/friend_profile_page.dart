import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_im/app/controller/chat_controller.dart';
import 'package:flutter_im/app/models/friend.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../api/api_service.dart';
import '../../../controller/contact_controller.dart';
import '../../../routes/app_routes.dart';

class FriendProfilePage extends StatelessWidget {
  const FriendProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String KEY_USER_ID = 'userId';
    final friendId =
        Get.parameters[KEY_USER_ID] ?? Get.arguments?[KEY_USER_ID] ?? '';

    final storage = GetStorage();

    final userId = storage.read(KEY_USER_ID);

    return Scaffold(
      appBar: AppBar(
        //title: const Text('个人信息'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Friend>(
        future: _getFriendInfo(userId, friendId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          final friend = snapshot.data ?? Friend(userId: userId);

          return SingleChildScrollView(
            child: Column(
              children: [
                // 头像和基本信息部分
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 矩形头像
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: friend.avatar ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.error,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 用户信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.name ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (friend.flag == 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ID: ${friend.userId ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  friend.location ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                    height: 1, color: Color.fromARGB(255, 238, 236, 236)),

                // 按钮区域
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: friend.flag == 1
                          ? [
                              // 好友操作按钮
                              _buildActionButton(
                                '发消息',
                                Icons.message,
                                () => _handleMessage(context, friend),
                              ),
                              const SizedBox(height: 12),
                              _buildActionButton(
                                '音视频通话',
                                Icons.video_call,
                                () => _handleVideoCall(context, userId, friend),
                              ),
                            ]
                          : [
                              // 非好友操作按钮
                              _buildActionButton(
                                '添加到通讯录',
                                Icons.person_add,
                                () => _handleAddFriend(context, friend),
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 50,
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Future<Friend> _getFriendInfo(String userId, String friendId) async {
    // TODO: 实现获取好友信息功能

    final ApiService _apiService = Get.find<ApiService>();

    final response =
        await _apiService.getFriendInfo({'fromId': userId, 'toId': friendId});

    if (response != null && response['status'] == 200) {
      return Friend.fromJson(response['data']);
    }

    return Friend(userId: userId);
  }

  // 按钮点击处理方法
  void _handleMessage(BuildContext context, Friend friend) {
    final ChatController chatController = Get.find<ChatController>();
    chatController.setCurrentChatByFriend(friend).then((isSuccess) {
      if (isSuccess) {
        Get.toNamed("${Routes.HOME}${Routes.MESSAGE}");
      }
    });
  }

  void _handleVideoCall(BuildContext context, String userId, Friend friend) {
    final ChatController chatController = Get.find<ChatController>();

    // 请求视频通话, 如果成功则跳转视频通话页面
    chatController.handleCallVideo(friend).then((isSuccess) {
      if (isSuccess) {
        Get.toNamed("${Routes.HOME}${Routes.VIDEO_CALL}",
            arguments: {'userId': userId, 'friend': friend});
      }
    });
  }

  void _handleAddFriend(BuildContext context, Friend friend) {
    // TODO: 实现添加好友功能
    final ContactController contactController = Get.find<ContactController>();
    contactController.handleFriendRequest(friend.userId ?? "");

    // 添加好友成功后，刷新好友列表
    // _refreshFriendList();
  }
}
