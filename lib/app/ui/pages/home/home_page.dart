import 'package:flutter/material.dart';
import 'package:flutter_im/app/ui/pages/chat/chat_page.dart';
import 'package:flutter_im/app/ui/pages/contacts/contacts_page.dart';
import 'package:flutter_im/app/ui/pages/my/my_page.dart';
import 'package:get/get.dart';

import '../../../controller/chat_controller.dart';
import '../../../controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatList = Get.find<ChatController>().chatList;

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex,
            children: const [
              ChatPage(), // 会话
              ContactsPage(), // 通讯录
              MyPage(), // 我的
            ],
          )),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex,
          onTap: controller.changeTabIndex,
          items: [
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.message),
                  if (chatList.any((chat) => chat.unread > 0)) // 检查是否有未读消息
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '${chatList.where((chat) => chat.unread > 0).length > 99 ? '99+' : chatList.where((chat) => chat.unread > 0).length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: '消息',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: '通讯录',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
