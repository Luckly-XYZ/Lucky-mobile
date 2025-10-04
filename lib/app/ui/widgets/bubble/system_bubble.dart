import 'package:flutter/material.dart';

import '../../../../utils/date.dart';
import '../../../models/message_receive.dart';

/// 系统消息气泡组件，展示系统通知的时间和内容
/// 特性：
/// - 显示格式化的消息时间和系统消息文本。
/// - 使用灰色背景和圆角容器，视觉上与聊天消息区分。
class SystemMessageBubble extends StatelessWidget {
  // 常量定义
  static const _padding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8); // 外边距
  static const _contentPadding = EdgeInsets.all(8); // 内容内边距
  static const _borderRadius = 8.0; // 圆角半径
  static const _timeStyle = TextStyle(fontSize: 12, color: Colors.grey); // 时间样式
  static const _messageStyle =
      TextStyle(fontSize: 12, color: Colors.grey); // 消息样式
  static const _backgroundColor = Colors.grey; // 背景颜色
  static const _defaultText = '无消息内容'; // 默认消息文本
  static const _timeFormat = 'yy/MM/dd'; // 时间格式
  static const _spacing = 4.0; // 时间与内容间距

  final IMessage message; // 系统消息数据

  const SystemMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 消息时间
          //_buildTimeLabel(),
          const SizedBox(height: _spacing),

          /// 消息内容
          _buildMessageContent(),
        ],
      ),
    );
  }

  // --- UI 构建方法 ---

  /// 构建时间标签
  Widget _buildTimeLabel() {
    return Text(
      getTimeToDisplay(message.messageTime ?? 0, _timeFormat, true),
      style: _timeStyle,
      textAlign: TextAlign.center,
    );
  }

  /// 构建消息内容容器
  Widget _buildMessageContent() {
    final systemMessageBody = message.messageBody as SystemMessageBody?;
    return Container(
      padding: _contentPadding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Text(
        systemMessageBody?.text ?? _defaultText,
        style: _messageStyle,
      ),
    );
  }
}
