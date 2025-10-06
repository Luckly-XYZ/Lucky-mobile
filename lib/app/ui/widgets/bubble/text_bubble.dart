import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../models/message_receive.dart';

class MessageBubble extends StatefulWidget {
  final IMessage message;
  final bool isMe;
  final String name;
  final String avatar;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.name,
    required this.avatar,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  // 管理所有 link recognizers，以便在 dispose 时释放（避免内存泄漏）
  final List<TapGestureRecognizer> _recognizers = [];

  static final _textStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: 1.25,
  );

  static final _linkStyle = const TextStyle(
    fontSize: 16,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  // 更通用的 URL 正则（支持可选 scheme、可选 www、匹配二级及以上域名和端口与路径）
  // 说明：
  //  - 支持形如: https://example.com/path?x=1
  //  - 支持形如: www.example.com 或 example.com/path
  //  - 不会捕获包含空白的字符串
  static final RegExp _urlRegex = RegExp(
    r'((?:https?:\/\/)?(?:www\.)?[A-Za-z0-9\-._~%]+\.[A-Za-z]{2,}(?::\d{1,5})?(?:[\/?#][^\s]*)?)',
    caseSensitive: false,
  );

  @override
  void dispose() {
    // 释放所有 recognizers
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildNameRow(),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: _buildMessageContent(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    final nameStyle = TextStyle(
      fontSize: 12,
      color: widget.isMe ? Colors.grey[600] : Colors.grey[500],
      fontWeight: FontWeight.w500,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.isMe) ...[
          Text(widget.name, style: nameStyle),
          const SizedBox(width: 8),
        ],
        if (widget.isMe) ...[
          const SizedBox(width: 8),
          Text(widget.name, style: nameStyle),
        ],
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final text =
        TextMessageBody.fromMessageBody(widget.message.messageBody)?.text ?? '';

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    // 优先使用快速判断（性能优化）
    if (!containsUrl(text)) {
      return Text(text, style: _textStyle);
    }

    // 否则拆分并构造 RichText spans
    final spans = _parseTextToSpans(text);
    return RichText(
      text: TextSpan(children: spans, style: _textStyle),
    );
  }

  /// -------------------------
  /// URL 相关独立方法（入口/工具）
  /// -------------------------

  /// 快速判断文本中是否含有 URL（基于正则）
  static bool containsUrl(String text) {
    if (text.isEmpty) return false;
    return _urlRegex.hasMatch(text);
  }

  /// 提取文本中所有可能的 URL（未归一化）
  /// - 会去掉 URL 前后的常见包裹符或标点，例如 "(example.com)," -> "example.com"
  /// - 返回按出现顺序的字符串列表
  static List<String> extractUrls(String text) {
    final List<String> urls = [];
    if (text.isEmpty) return urls;

    final matches = _urlRegex.allMatches(text);
    for (final match in matches) {
      var raw = match.group(0) ?? '';
      if (raw.isEmpty) continue;

      // 清理前导和尾随常见符号，例如括号、句号、逗号、分号、冒号、感叹号、问号
      raw = _trimEnclosingPunctuation(raw);

      if (raw.isNotEmpty) {
        urls.add(raw);
      }
    }
    return urls;
  }

  /// 归一化 URL：若缺少 scheme，则自动补 https://
  /// - 输入: "example.com/path" -> 输出: "https://example.com/path"
  /// - 若已含 http/https 则保持不变
  static String normalizeUrl(String url) {
    if (url.isEmpty) return url;
    final trimmed = url.trim();

    // 如果已有 scheme
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      return trimmed;
    }

    // 否则补 https://
    return 'https://$trimmed';
  }

  /// 辅助：去掉前后的包裹符与尾部常见句末标点
  static String _trimEnclosingPunctuation(String s) {
    var t = s.trim();

    // 去掉前导左括号或引号
    while (t.isNotEmpty &&
        (t.codeUnitAt(0) == '('.codeUnitAt(0) ||
            t.codeUnitAt(0) == '"'.codeUnitAt(0) ||
            t.codeUnitAt(0) == '\''.codeUnitAt(0))) {
      t = t.substring(1).trim();
    }

    // 去掉尾部常见的标点 ) . , ; : ! ? " '
    while (t.isNotEmpty && _isTrailingPunctuation(t.codeUnitAt(t.length - 1))) {
      t = t.substring(0, t.length - 1).trim();
    }

    return t;
  }

  static bool _isTrailingPunctuation(int codeUnit) {
    const trailing = [
      41, // )
      46, // .
      44, // ,
      59, // ;
      58, // :
      33, // !
      63, // ?
      34, // "
      39, // '
    ];
    return trailing.contains(codeUnit);
  }

  /// -------------------------
  /// 文本 -> InlineSpan 解析
  /// -------------------------
  List<InlineSpan> _parseTextToSpans(String text) {
    // 释放旧 recognizers（如果有）并清空
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final List<InlineSpan> spans = [];

    // 使用正则匹配到所有 URL，循环拼接文本片段
    final matches = _urlRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      // 防护：若正则没匹配到，直接返回整段文本
      spans.add(TextSpan(text: text));
      return spans;
    }

    int lastEnd = 0;
    for (final match in matches) {
      final start = match.start;
      final end = match.end;

      // 前半段普通文本
      if (start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, start)));
      }

      // raw url 可能包含末尾标点或前导括号，清理后再使用
      var rawUrl = match.group(0) ?? '';
      final cleaned = _trimEnclosingPunctuation(rawUrl);

      // 基本校验：Uri.tryParse 且含点（确保不是孤立的单词）
      final candidate = cleaned;
      final uri = Uri.tryParse(candidate);
      final hasDot = candidate.contains('.');
      final isValid =
          candidate.isNotEmpty && uri != null && (uri.hasScheme || hasDot);

      if (isValid) {
        // 点击打开：先 normalize，再跳转到 WebView 页面（你也可以直接 launch 外部浏览器）
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            final link = normalizeUrl(candidate);
            // 使用 Get 跳转到 WebView 页面，传入归一化链接
            Get.toNamed(Routes.WEB_VIEW, arguments: {'url': link});
          };
        _recognizers.add(recognizer);

        spans.add(TextSpan(
            text: candidate, style: _linkStyle, recognizer: recognizer));
      } else {
        // 非合法 URL，作为普通文本渲染
        spans.add(TextSpan(text: rawUrl));
      }

      lastEnd = end;
    }

    // 尾部普通文本
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () {
        if (!widget.isMe) {
          Get.toNamed("${Routes.HOME}${Routes.FRIEND_PROFILE}",
              arguments: {'userId': widget.message.fromId});
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.avatar,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 出错时显示一个简单的占位
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: Icon(Icons.person, color: Colors.grey.shade600, size: 20),
            );
          },
        ),
      ),
    );
  }
}
