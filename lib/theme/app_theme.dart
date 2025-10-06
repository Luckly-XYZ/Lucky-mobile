import 'package:flutter/material.dart';

class AppTheme {
  /// 主背景
  static const Color primaryBackground = Color(0xFFF4F6FA);

  /// 主文本
  static const Color primaryText = Color(0xFFFEFEFE);
  static const Color main = Color(0xFFFEFEFE);

  /// 主文本灰色
  static const Color primaryGreyText = Color(0xFF9B9B9B);

  /// 主文本灰色
  static const Color primaryGreyText1 = Color(0xFFE0DDF5);

  static const Color transparent = Color(0x00000000);

  static const Gradient bg_btn_gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [const Color(0xFF8BD5FF), const Color(0xFF3BDCB1)],
  );

  static const Color bg_page = Color(0xFFFFFFFF);
  static const Color bg_page_gray = Color(0xFFF3F4F6);
  static const Color bg_tran_block = Color(0xCC000000);
  static const Color bg_btn_block = Color(0xFF202020);
  static const Color bg_btn_cancel = Color(0xFF3D3D3D);
  static const Color bg_block_tran = Color(0x77000000);
  static const Color bg_white_tran = Color(0x33FFFFFF);
  static const Color bg_gray_tran = Color(0x33979797);
  static const Color bg_tab = Color(0xFF3D3D3D);
  static const Color bg_tab_active = Color(0xFFD3BB6E);

  static const Color bg_sheet = Color(0xFF3D3D3D);

  static const Color block = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFB4B4B4);
  static const Color block_line = Color(0xFF262626);

  // 黑底白字
  static const Color text_block_white = Color(0xFFFFFFFF);
  static const Color text_block_white_deep = Color(0xFFD9DFE6);
  static const Color text_block_gray_light = Color(0xFF545456);
  static const Color text_block_gray_deep = Color(0xFFCCCCCE);

  // 白底黑字
  static const Color text_white_block = Color(0xFF030304);
  static const Color text_white_gray_light = Color(0xFF7C7C80);
  static const Color text_white_gray_deep = Color(0xFF888888);

  static const Color green = Color(0xFF7DFBB3);
  static const Color red = Color(0xFFFF0000);
  static const Color pink = Color(0xFFFF6A83);
  static const Color golden = Color(0xFFD3BB6E);
  static const Color purple = Color(0xFF998AED);
}
