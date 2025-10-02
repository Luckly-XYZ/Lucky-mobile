import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/contact_controller.dart';
import '../../../models/friend_request.dart';

class FriendRequestsPage extends GetView<ContactController> {
  const FriendRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ContactController contactController = Get.find<ContactController>();
    contactController.fetchFriendRequests();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('新的朋友'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingRequests.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.friendRequests.isEmpty) {
                return const Center(child: Text('暂无好友申请'));
              }

              return ListView.builder(
                itemCount: controller.friendRequests.length,
                itemBuilder: (context, index) {
                  return _buildRequestItem(
                      context, controller.friendRequests[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(8),
        child: TextField(
          decoration: InputDecoration(
            hintText: '搜索',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon:
                Icon(Icons.search, color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, FriendRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(request.avatar),
        ),
        title: Text(
          request.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: TextButton(
          onPressed: () =>
              controller.handleFriendApprove(request.id, request.fromId),
          child: Text(
            _getButtonText(request.approveStatus),
            style: TextStyle(
              color: request.approveStatus == 0
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  String _getButtonText(int status) {
    switch (status) {
      case 0:
        return '接受';
      case 1:
        return '已添加';
      case 2:
        return '已拒绝';
      default:
        return '查看';
    }
  }
}
