import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/contact_controller.dart';
import '../../../routes/app_routes.dart';

class AddFriendPage extends StatelessWidget {
  AddFriendPage({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();
  final ContactController controller = Get.find<ContactController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加好友'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          /// **优化搜索框样式**
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '输入用户ID或手机号搜索',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon:
                      Icon(Icons.search, color: Theme.of(context).primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500]),
                    onPressed: () => _searchController.clear(),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    controller.searchUser(value);
                  }
                },
              ),
            ),
          ),

          /// **搜索结果**
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return _buildSearchingWidget(context);
              }
              if (controller.searchResults.isEmpty) {
                return _buildEmptyResultWidget(context);
              }
              return _buildUserList();
            }),
          ),
        ],
      ),
    );
  }

  /// **加载中**
  Widget _buildSearchingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            '正在搜索...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// **未找到结果**
  Widget _buildEmptyResultWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            '没有找到相关用户',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// **用户列表**
  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final user = controller.searchResults[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Colors.white,
          //elevation: 2, // 轻微阴影
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(10),
          //   side: BorderSide(color: Colors.grey[200]!, width: 1),
          // ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar ?? ""),
            ),
            title: Text(user.name ?? "",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () {
              // TODO: 可添加查看详情逻辑
              Get.toNamed("${Routes.HOME}${Routes.FRIEND_PROFILE}",
                  arguments: {'userId': user.userId});
            },
          ),
        );
      },
    );
  }
}
