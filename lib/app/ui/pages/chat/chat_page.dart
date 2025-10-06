import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../routes/app_routes.dart';
import '../../../controller/chat_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../models/chats.dart';
import '../../widgets/chat/chat_item.dart';
import '../../widgets/icon/icon_font.dart';

/// 聊天页面，显示会话列表并支持跳转到聊天详情
/// 特性：
/// - 显示用户头像、用户名及 WebSocket 连接状态。
/// - 支持搜索、创建群聊、扫一扫和添加好友功能。
/// - 使用 [ChatItem] 显示会话，支持点击进入聊天详情。
/// - 使用 [PopupMenuButton] 实现带箭头的弹出菜单。
class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  // 常量定义
  static const _avatarSize = kSize36; // 头像尺寸
  static const _avatarBorderRadius = 6.0; // 头像圆角
  static const _appBarHeight = kToolbarHeight; // AppBar 高度
  static const _chatItemPadding =
      EdgeInsets.symmetric(horizontal: kSize10, vertical: kSize6); // 聊天项外边距
  static const _menuWidth = 150.0; // 弹出菜单宽度
  static const _emptyText = '暂无聊天记录'; // 空状态提示

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildChatList(context, controller.chatList)),
    );
  }

  // --- UI 构建方法 ---

  /// 构建 AppBar，包含头像、用户名和操作按钮
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: GetX<UserController>(
        builder: (controller) {
          final userInfo = controller.userInfo;
          final username = userInfo['name'] ?? '未登录';
          final avatarUrl = userInfo['avatar'] ?? '';

          return Row(
            children: [
              _buildAvatar(context, username, avatarUrl),
              _buildUserInfo(context, username),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: Iconfont.buildIcon(icon: Iconfont.search, size: 26),
          onPressed: () => Get.toNamed('${Routes.HOME}${Routes.SEARCH}'),
          tooltip: '搜索',
        ),
        _buildPopupMenuButton(context),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 构建头像
  Widget _buildAvatar(BuildContext context, String username, String avatarUrl) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_avatarBorderRadius),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: Iconfont.buildIcon(
                icon: Iconfont.person, size: 24, color: Colors.grey),
          ),
          errorWidget: (context, url, error) {
            debugPrint('加载头像失败: $error');
            return Container(
              color: Colors.grey[300],
              child: Iconfont.buildIcon(
                  icon: Iconfont.person, size: 24, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  /// 构建用户名和连接状态
  Widget _buildUserInfo(BuildContext context, String username) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(
          username,
          style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: kSize20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 构建弹出菜单按钮
  Widget _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Iconfont.buildIcon(icon: Iconfont.add, size: 28),
      tooltip: '更多操作',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      offset: const Offset(0, kToolbarHeight),
      itemBuilder: (context) => _buildMenuItems(),
      onSelected: (value) => _handleMenuSelection(context, value),
    );
  }

  /// 构建弹出菜单项
  List<PopupMenuItem<String>> _buildMenuItems() {
    return [
      PopupMenuItem<String>(
        value: 'create_group',
        child: Row(
          children: [
            Iconfont.buildIcon(
                icon: Iconfont.add, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            const Text('创建群聊'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'scan',
        child: Row(
          children: [
            Iconfont.buildIcon(
                icon: Iconfont.scan, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            const Text('扫一扫'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'add_friend',
        child: Row(
          children: [
            Iconfont.buildIcon(
                icon: Iconfont.addFriend, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            const Text('加好友/群'),
          ],
        ),
      ),
    ];
  }

  /// 处理菜单选择
  void _handleMenuSelection(BuildContext context, String value) {
    if (!context.mounted) return;
    switch (value) {
      case 'create_group':
        Get.snackbar('提示', '创建群聊功能待实现'); // TODO: 实现创建群聊
        break;
      case 'scan':
        Get.toNamed('${Routes.HOME}${Routes.SCAN}');
        break;
      case 'add_friend':
        Get.toNamed('${Routes.HOME}${Routes.ADD_FRIEND}');
        break;
    }
  }

  /// 构建聊天列表
  Widget _buildChatList(BuildContext context, List<Chats> chatList) {
    if (chatList.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      cacheExtent: 1000, // 缓存 1000 像素，优化滚动性能
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chat = chatList[index];
        return GestureDetector(
          onTap: () => _navigateToChatScreen(context, chat),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: _chatItemPadding,
              child: ChatItem(chats: chat),
            ),
          ),
        );
      },
    );
  }

  /// 构建空状态提示
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        _emptyText,
        style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.black54) ??
            const TextStyle(fontSize: kSize16, color: Colors.black54),
      ),
    );
  }

  /// 跳转到聊天详情页面
  void _navigateToChatScreen(BuildContext context, Chats chat) {
    controller.setCurrentChat(chat);
    Get.toNamed('${Routes.HOME}${Routes.MESSAGE}');
  }
}
