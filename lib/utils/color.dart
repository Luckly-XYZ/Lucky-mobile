import 'dart:math';

import 'package:flutter/material.dart';

class ColorUtil {
  // 将十六进制字符串转换为颜色
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // 添加透明度
    }
    return Color(int.parse(hex, radix: 16));
  }

  // 将颜色转换为十六进制字符串
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  // 生成随机颜色
  static Color getRandomColor() {
    return Color.fromARGB(
      255,
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
    );
  }

  // 调整颜色亮度
  static Color adjustBrightness(Color color, double factor) {
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).clamp(0, 255).toInt(),
      (color.green * factor).clamp(0, 255).toInt(),
      (color.blue * factor).clamp(0, 255).toInt(),
    );
  }
}
