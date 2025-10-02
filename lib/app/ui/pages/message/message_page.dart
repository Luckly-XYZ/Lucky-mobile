import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_message.dart';
import '../../../controller/chat_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/bubble/image_bubble.dart';
import '../../widgets/bubble/message_bubble.dart';
import '../../widgets/bubble/video_bubble.dart';
import 'message_input.dart';

class MessagePage extends GetView<ChatController> {
  final TextEditingController textController = TextEditingController();

  // 添加 ScrollController 用于自动滚动到最新消息
  final ScrollController scrollController = ScrollController();

  MessagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 从 UserController 获取用户信息
    Map<dynamic, dynamic> userInfo = Get.find<UserController>().userInfo;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.toNamed('${Routes.HOME}${Routes.MESSAGE}'),
        ),
        title: Obx(() => Column(
              children: [
                Text(
                  controller.currentChat.value?.name ?? '', // 会话用户名
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), // 三个点图标
            onPressed: () {
              // 跳转到聊天信息页面
              Get.toNamed('${Routes.HOME}${Routes.CHAT_INFO}', arguments: {
                'avatar': controller.currentChat.value?.avatar,
                'name': controller.currentChat.value?.name,
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // 检测是否滑动到顶部
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      !controller.isLoadingMore.value &&
                      controller.hasMoreMessages.value) {
                    // 加载更多消息
                    controller.handleSetMessageList(
                        controller.currentChat.value!,
                        loadMore: true);
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: controller.messageList.length + 1, // 增加1用于显示加载状态
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (index == controller.messageList.length) {
                      // 显示加载状态
                      return Obx(() {
                        if (controller.isLoadingMore.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (!controller.hasMoreMessages.value &&
                            controller.messageList.length >=
                                controller.pageSize) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                '没有更多消息了',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      });
                    }

                    // 原有的消息气泡渲染逻辑
                    final message = controller.messageList[index];
                    final isMe = message.fromId == controller.userId.value;
                    final name = message.fromId == controller.userId.value
                        ? userInfo['name']
                        : controller.currentChat.value?.name;
                    final avatar = message.fromId == controller.userId.value
                        ? userInfo['avatar']
                        : controller.currentChat.value?.avatar;

                    final contentType = MessageContentType.fromCode(
                        message.messageContentType ?? 1);
                    // 根据消息类型返回对应的气泡组件
                    switch (contentType) {
                      case MessageContentType.image:
                        return ImageBubble(
                          message: message,
                          isMe: isMe,
                        );
                      case MessageContentType.video:
                        return VideoBubble(
                          message: message,
                          isMe: isMe,
                        );
                      default:
                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          name: name,
                          avatar: avatar,
                        );
                    }
                  },
                ),
              );
            }),
          ),
          MessageInput(
            textController: textController, // 文本输入框
            controller: controller, // chatController
          ),
        ],
      ),
    );
  }
}


