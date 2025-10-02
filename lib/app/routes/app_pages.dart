import 'package:flutter/animation.dart';
import 'package:flutter_im/app/ui/pages/contacts/add_friend_page.dart';
import 'package:flutter_im/app/ui/pages/home/home_page.dart';
import 'package:flutter_im/app/ui/pages/login/login_page.dart';
import 'package:flutter_im/app/ui/pages/message/chat_info_page.dart';
import 'package:flutter_im/app/ui/pages/message/message_page.dart';
import 'package:flutter_im/app/ui/pages/my/my_qr_code_page.dart';
import 'package:flutter_im/app/ui/pages/scan/scan_page.dart';
import 'package:flutter_im/app/ui/pages/search/search_page.dart';
import 'package:flutter_im/app/ui/pages/unknow/unknown_page.dart';
import 'package:flutter_im/app/ui/pages/video/video_call_page.dart';
import 'package:flutter_im/app/ui/pages/webview/webview_page.dart';
import 'package:get/get.dart';

import '../ui/pages/contacts/friend_requests_page.dart';
import '../ui/pages/friend/friend_profile_page.dart';
import 'app_route_auth.dart';
import 'app_routes.dart';

/// 页面路由
class AppPages {
  // 默认路由
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN, // 登录
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.WEB_VIEW, // webview
      page: () => const WebViewPage(),
    ),
    GetPage(
      name: Routes.HOME, // 首页
      page: () => const HomePage(),
      middlewares: [
        RouteAuthMiddleware(), // 需要登录,如果未登录,则跳转到登录页面
      ],
      children: getHomeChildPages(),
    ),
  ];

  // 未知路由
  static final unknownRoute = GetPage(
    name: Routes.UNKNOWN,
    page: () => const UnknownView(),
  );
}

/// 首页子页面
List<GetPage> getHomeChildPages() {
  return [
    // GetPage(
    //   name: Routes.CHAT, // 会话
    //   page: () => const ChatPage(),
    // ),
    GetPage(
      name: Routes.MESSAGE, // 消息
      page: () => MessagePage(),
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.CHAT_INFO, // 聊天信息
      page: () => ChatInfoPage(),
    ),
    GetPage(
      name: Routes.ADD_FRIEND, //  添加好友
      page: () => AddFriendPage(),
    ),
    // GetPage(
    //   name: Routes.CONTACTS, // 通讯录
    //   page: () => const ContactsPage(),
    // ),
    GetPage(
      name: Routes.FRIEND_PROFILE, // 好友资料
      page: () => const FriendProfilePage(),
    ),

    GetPage(
      name: Routes.MY_QR_CODE, // 我的好友二维码
      page: () => const MyQRCodePage(),
    ),
    GetPage(
      name: Routes.FRIEND_REQUESTS,
      page: () => const FriendRequestsPage(),
    ),
    GetPage(
      name: Routes.SCAN, // 扫一扫
      page: () => const ScanPage(),
    ),
    GetPage(
        name: Routes.SEARCH, // 搜索
        page: () => const SearchPage()),
    GetPage(
      name: Routes.VIDEO_CALL, // 视频通话
      page: () => const VideoCallPage(),
    )
  ];
}
