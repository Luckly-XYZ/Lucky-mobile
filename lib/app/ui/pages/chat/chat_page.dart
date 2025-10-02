import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_sizes.dart';
import '../../../controller/chat_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../models/chats.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/chat/chat_item.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() {
        return _buildChatList(controller.chatList);
      }),
    );
  }

  Widget _buildChatList(List<Chats> chatList) {
    if (chatList.isEmpty) {
      return const Center(
        child: Text(
          '暂无聊天记录',
          style: TextStyle(
            fontSize: kSize16,
            color: Colors.black54,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chat = chatList[index];
        return GestureDetector(
          onTap: () => _navigateToChatScreen(context, chat),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSize10,
                vertical: kSize6,
              ),
              child: ChatItem(chats: chat),
            ),
          ),
        );
      },
    );
  }

  void _navigateToChatScreen(BuildContext context, Chats chat) {
    controller.setCurrentChat(chat);
    Get.toNamed("${Routes.HOME}${Routes.MESSAGE}");
  }

  /// 构建AppBar，并在右侧添加加号按钮
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: GetX<UserController>(
        builder: (controller) {
          final userInfo = controller.userInfo;
          final username = userInfo['name'] ?? '未登录';
          final avatarUrl = userInfo['avatar'] ?? '';

          return Row(
            children: <Widget>[
              _buildAvatarButton(context, username, avatarUrl),
              _buildUserInfo(username),
            ],
          );
        },
      ),
      actions: [
        // 添加搜索按钮
        IconButton(
          icon: const Icon(Icons.search, size: 26),
          onPressed: () {
            Get.toNamed("${Routes.HOME}${Routes.SEARCH}");
          },
        ),
        // 使用 Builder 获取加号按钮的局部上下文
        Builder(
          builder: (buttonContext) {
            return IconButton(
              icon: const Icon(Icons.add, size: 28),
              onPressed: () {
                _showPopupMenu(buttonContext);
              },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 构建头像按钮
  Widget _buildAvatarButton(
      BuildContext context, String username, String avatarUrl) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        width: kSize36,
        height: kSize36,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6), // 矩形时添加圆角
          image: avatarUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
    );
  }

  /// 构建显示用户名的控件
  Widget _buildUserInfo(String username) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Text(
              username,
              style: const TextStyle(
                fontSize: kSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // const SizedBox(width: 4),
            // // 添加 WebSocket 连接状态
            // Obx(() {
            //   final webSocketService = Get.find<WebSocketService>();
            //   return Text(
            //     webSocketService.isConnected ? '(已连接)' : '(离线)',
            //     style: TextStyle(
            //       fontSize: kSize12,
            //       //color: webSocketService.isConnected ? Colors.green : Colors.grey,
            //     ),
            //   );
            // }),
            // const Spacer(), // 添加 Spacer 来推动前面的内容靠左
          ],
        ),
      ),
    );
  }

  /// 弹出菜单，显示在加号按钮正下方
  void _showPopupMenu(BuildContext buttonContext) async {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(buttonContext)
        .overlay!
        .context
        .findRenderObject() as RenderBox;
    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    const menuWidth = 150.0;
    // 计算箭头位置，使其位于按钮中心
    final double arrowOffset = menuWidth - buttonSize.width / 2 + 20; // 箭头位置偏右

    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx - menuWidth + buttonSize.width, // 菜单右对齐按钮
      buttonPosition.dy + buttonSize.height,
      buttonPosition.dx,
      buttonPosition.dy,
    );

    final String? selectedValue = await showMenu<String>(
      context: buttonContext,
      position: position,
      shape: ArrowMenuBorder(
        arrowOffset: Offset(arrowOffset, 0),
      ),
      elevation: 8,
      constraints: const BoxConstraints(minWidth: menuWidth),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'create_group',
          child: Row(
            children: [
              Icon(Icons.group_add, color: Colors.black87),
              SizedBox(width: 12),
              Text('创建群聊'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'scan',
          child: Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.black87),
              SizedBox(width: 12),
              Text('扫一扫'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'add_friend',
          child: Row(
            children: [
              Icon(Icons.person_add, color: Colors.black87),
              SizedBox(width: 12),
              Text('加好友/群'),
            ],
          ),
        ),
      ],
    );

    // 处理选中的菜单项
    if (selectedValue != null && buttonContext.mounted) {
      switch (selectedValue) {
        case 'create_group':
          // TODO: 实现创建群聊
          break;
        case 'scan':
          Get.toNamed("${Routes.HOME}${Routes.SCAN}");
          break;
        case 'add_friend':
          Get.toNamed("${Routes.HOME}${Routes.ADD_FRIEND}");
          // TODO: 实现加好友/群
          break;
      }
    }
  }
}

class ArrowMenuBorder extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;
  final Offset arrowOffset;

  const ArrowMenuBorder({
    this.arrowWidth = 12,
    this.arrowHeight = 8,
    this.borderRadius = 8,
    this.arrowOffset = const Offset(0, 0),
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(top: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
      rect.topLeft + Offset(0, arrowHeight),
      rect.bottomRight,
    );

    return Path()
      ..moveTo(rect.left + borderRadius, rect.top)
      // 绘制顶部箭头
      ..lineTo(rect.left + arrowOffset.dx - arrowWidth / 2, rect.top)
      ..lineTo(rect.left + arrowOffset.dx, rect.top - arrowHeight)
      ..lineTo(rect.left + arrowOffset.dx + arrowWidth / 2, rect.top)
      // 绘制圆角矩形
      ..lineTo(rect.right - borderRadius, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + borderRadius),
        radius: Radius.circular(borderRadius),
      )
      ..lineTo(rect.right, rect.bottom - borderRadius)
      ..arcToPoint(
        Offset(rect.right - borderRadius, rect.bottom),
        radius: Radius.circular(borderRadius),
      )
      ..lineTo(rect.left + borderRadius, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.bottom - borderRadius),
        radius: Radius.circular(borderRadius),
      )
      ..lineTo(rect.left, rect.top + borderRadius)
      ..arcToPoint(
        Offset(rect.left + borderRadius, rect.top),
        radius: Radius.circular(borderRadius),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
