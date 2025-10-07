import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../controller/contact_controller.dart';
import '../../../models/friend.dart';
import '../../widgets/contacts/user_avatar_name.dart';

class ContactsPage extends GetView<ContactController> {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 更新通讯录
    controller.fetchContacts();
    // 更新未处理请求
    controller.fetchFriendRequests();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('通讯录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // TODO: 实现添加联系人功能
              Get.toNamed("${Routes.HOME}${Routes.ADD_FRIEND}");
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildNewFriendItem(),
            Expanded(child: _buildFriendList(controller.contactsList)),
          ],
        );
      }),
    );
  }

  Widget _buildNewFriendItem() {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
        ),
      ),
      title: const Text('新的朋友'),
      trailing: Obx(() => controller.newFriendRequestCount.value > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${controller.newFriendRequestCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : const SizedBox()),
      onTap: () => {Get.toNamed("${Routes.HOME}${Routes.FRIEND_REQUESTS}")},
    );
  }

  Widget _buildFriendList(List<Friend> contactsList) {
    return ListView.builder(
      itemCount: contactsList.length,
      itemBuilder: (context, index) {
        final friend = contactsList[index];
        return UserAvatarName(
          avatar: friend.avatar,
          name: friend.name,
          onTap: () {
            Get.toNamed("${Routes.HOME}${Routes.FRIEND_PROFILE}",
                arguments: {'userId': friend.friendId});
          },
        );
      },
    );
  }
}
