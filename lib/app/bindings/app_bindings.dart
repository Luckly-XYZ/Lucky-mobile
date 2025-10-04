import 'package:flutter_im/app/api/api_service.dart';
import 'package:flutter_im/app/api/event_bus_service.dart';
import 'package:flutter_im/app/api/websocket_service.dart';
import 'package:flutter_im/app/controller/contact_controller.dart';
import 'package:flutter_im/app/controller/home_controller.dart';
import 'package:flutter_im/app/controller/login_controller.dart';
import 'package:flutter_im/app/controller/search_controller.dart';
import 'package:flutter_im/app/controller/user_controller.dart';
import 'package:get/get.dart';

import '../api/notification_service.dart';
import '../controller/chat_controller.dart';

class AppAllBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(EventBus()); // 注入事务总线
    Get.put(ApiService()); // ✅ 这里注入 HttpService
    Get.put(WebSocketService()); // ✅ 注入 websocket
    Get.put(LocalNotificationService());
    Get.put(ChatController(), permanent: true);
    Get.put(UserController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(ContactController(), permanent: true);
    Get.put(SearchsController());
    Get.put(LoginController());
  }
}
