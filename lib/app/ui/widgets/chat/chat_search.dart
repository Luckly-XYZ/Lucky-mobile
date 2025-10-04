import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';

/// 聊天搜索栏装饰组件，提供统一的搜索框样式
/// 显示搜索图标和占位文本，支持主题化配置
class ChatSearchDecoration extends StatelessWidget {
  // 常量定义
  static const _containerHeight = kSize70; // 搜索栏高度
  static const _borderRadius = kSize35; // 搜索栏圆角
  static const _horizontalMargin = kSize36; // 水平边距
  static const _iconPaddingLeft = kSize20; // 图标左侧内边距
  static const _iconPaddingRight = kSize16; // 图标右侧内边距
  static const _backgroundColor = kColor33; // 背景颜色
  static const _iconColor = kColor99; // 图标和文字颜色
  static const _searchText = '搜索'; // 默认占位文本

  const ChatSearchDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _containerHeight,
      margin: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
      decoration: const BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 搜索图标
          Padding(
            padding: const EdgeInsets.only(
              left: _iconPaddingLeft,
              right: _iconPaddingRight,
            ),
            child: Icon(
              Icons.search,
              color: _iconColor,
              size: kSize24, // 使用标准图标尺寸
            ),
          ),

          /// 占位文本
          Expanded(
            child: Text(
              _searchText,
              style: TextStyle(
                color: _iconColor,
                fontSize: kSize16, // 使用标准字体大小
              ),
            ),
          ),
        ],
      ),
    );
  }
}
