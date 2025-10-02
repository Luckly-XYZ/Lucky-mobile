import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // 使用 Rx 变量来响应式更新 UI
  final _currentIndex = 0.obs;

  // getter 方法获取当前索引
  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    // 设置强制竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // 切换底部导航栏方法
  void changeTabIndex(int index) {
    _currentIndex.value = index;
  }

  void toggleLanguage() {
    if (Get.locale == const Locale('zh', 'CN')) {
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      Get.updateLocale(const Locale('zh', 'CN'));
    }
  }
}
