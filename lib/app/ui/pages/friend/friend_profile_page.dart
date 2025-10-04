import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../api/api_service.dart';
import '../../../controller/chat_controller.dart';
import '../../../controller/contact_controller.dart';
import '../../../models/friend.dart';
import '../../../routes/app_routes.dart';

/// 好友资料页面，展示好友或非好友的个人信息及操作按钮
/// 特性：
/// - 显示用户头像、名称、ID、所在地等信息。
/// - 根据好友状态（flag）显示不同操作按钮（发消息、音视频通话或添加好友）。
/// - 使用 FutureBuilder 异步加载好友信息，支持加载和错误状态。
class FriendProfilePage extends StatelessWidget {
  // 常量定义
  static const _avatarSize = 80.0; // 头像尺寸
  static const _avatarBorderRadius = 12.0; // 头像圆角
  static const _padding = EdgeInsets.all(16); // 内容边距
  static const _dividerColor = Color.fromARGB(255, 238, 236, 236); // 分割线颜色
  static const _nameStyle =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w600); // 名称样式
  static const _infoStyle = TextStyle(fontSize: 14, color: Colors.grey); // 信息样式
  static const _idBadgePadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 4); // ID 徽章边距
  static const _buttonHeight = 50.0; // 按钮高度
  static const _buttonSpacing = 12.0; // 按钮间距
  static const _errorStyle =
      TextStyle(fontSize: 16, color: Colors.grey); // 错误提示样式
  static const _keyUserId = 'userId'; // 存储用户 ID 的键

  const FriendProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final userId = storage.read(_keyUserId) ?? '';
    final friendId =
        (Get.arguments is Map ? Get.arguments[_keyUserId] as String? : null) ??
            Get.parameters[_keyUserId] ??
            '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: Get.back, // 使用 Get.back 替代 Navigator.pop
        ),
      ),
      body: FutureBuilder<Friend>(
        future: _getFriendInfo(userId, friendId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '加载失败: ${snapshot.error}',
                style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey) ??
                    _errorStyle,
              ),
            );
          }

          final friend = snapshot.data ?? Friend(userId: userId);
          return SingleChildScrollView(
            child: Column(
              children: [
                /// 用户信息头部
                _buildHeader(context, friend),
                const Divider(height: 1, color: _dividerColor),

                /// 操作按钮区域
                _buildActions(context, userId, friend),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI 构建方法 ---

  /// 构建用户信息头部（头像、名称、ID、所在地）
  Widget _buildHeader(BuildContext context, Friend friend) {
    return Container(
      padding: _padding,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 头像
          ClipRRect(
            borderRadius: BorderRadius.circular(_avatarBorderRadius),
            child: CachedNetworkImage(
              imageUrl: friend.avatar ?? '',
              width: _avatarSize,
              height: _avatarSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              errorWidget: (context, url, error) {
                debugPrint('加载头像失败: $error');
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          /// 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name ?? '未知用户',
                  style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600) ??
                      _nameStyle,
                ),
                const SizedBox(height: 8),
                if (friend.flag == 1)
                  Container(
                    padding: _idBadgePadding,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ID: ${friend.friendId ?? ''}',
                      style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]) ??
                          _infoStyle,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      friend.location ?? '未知地点',
                      style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]) ??
                          _infoStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActions(BuildContext context, String userId, Friend friend) {
    final buttons = friend.flag == 1
        ? [
            _ActionButtonData(
              text: '发消息',
              icon: Icons.message,
              onPressed: () => _handleMessage(context, friend),
            ),
            _ActionButtonData(
              text: '音视频通话',
              icon: Icons.video_call,
              onPressed: () => _handleVideoCall(context, userId, friend),
            ),
          ]
        : [
            _ActionButtonData(
              text: '添加到通讯录',
              icon: Icons.person_add,
              onPressed: () => _handleAddFriend(context, friend),
            ),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: buttons
              .asMap()
              .entries
              .map((entry) => Padding(
                    padding: EdgeInsets.only(
                        bottom: entry.key < buttons.length - 1
                            ? _buttonSpacing
                            : 0),
                    child: _buildActionButton(context, entry.value),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton(BuildContext context, _ActionButtonData data) {
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(data.icon, size: 20),
        label: Text(
          data.text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        onPressed: data.onPressed,
      ),
    );
  }

  // --- 逻辑处理方法 ---

  /// 获取好友信息
  Future<Friend> _getFriendInfo(String userId, String friendId) async {
    if (userId.isEmpty || friendId.isEmpty) {
      Get.snackbar('错误', '用户 ID 或好友 ID 为空');
      return Friend(userId: userId);
    }

    final apiService = Get.find<ApiService>();
    try {
      final response =
          await apiService.getFriendInfo({'fromId': userId, 'toId': friendId});
      if (response != null && response['code'] == 200) {
        return Friend.fromJson(response['data']);
      }
      Get.snackbar('提示', '无法获取好友信息');
      return Friend(userId: userId);
    } catch (e) {
      Get.snackbar('错误', '加载失败: $e');
      return Friend(userId: userId);
    }
  }

  /// 处理发送消息
  Future<void> _handleMessage(BuildContext context, Friend friend) async {
    final chatController = Get.find<ChatController>();
    final isSuccess = await chatController.setCurrentChatByFriend(friend);
    if (isSuccess) {
      Get.toNamed('${Routes.HOME}${Routes.MESSAGE}');
    } else {
      Get.snackbar('提示', '无法打开聊天');
    }
  }

  /// 处理音视频通话
  Future<void> _handleVideoCall(
      BuildContext context, String userId, Friend friend) async {
    final chatController = Get.find<ChatController>();
    final isSuccess = await chatController.handleCallVideo(friend);
    if (isSuccess) {
      Get.toNamed('${Routes.HOME}${Routes.VIDEO_CALL}',
          arguments: {'userId': userId, 'friend': friend});
    } else {
      Get.snackbar('提示', '无法发起通话');
    }
  }

  /// 处理添加好友
  Future<void> _handleAddFriend(BuildContext context, Friend friend) async {
    final contactController = Get.find<ContactController>();
    final friendId = friend.userId ?? '';
    if (friendId.isEmpty) {
      Get.snackbar('错误', '好友 ID 为空');
      return;
    }
    try {
      await contactController.sendFriendRequest(friendId);
      Get.snackbar('提示', '好友请求已发送');
    } catch (e) {
      Get.snackbar('错误', '添加好友失败: $e');
    }
  }
}

/// 按钮数据类
class _ActionButtonData {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButtonData({
    required this.text,
    required this.icon,
    required this.onPressed,
  });
}
