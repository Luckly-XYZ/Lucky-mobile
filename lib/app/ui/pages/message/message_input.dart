import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../constants/app_message.dart';
import '../../../controller/chat_controller.dart';
import '../../widgets/emoji/emoji_picker.dart';

/// 消息输入框组件，提供文本输入、@用户、表情选择和发送功能
/// 特性：
/// - 支持群聊中的@用户功能，显示用户选择抽屉。
/// - 集成表情选择器，支持插入和删除表情。
/// - 根据输入内容动态切换表情/发送按钮。
/// - 点击表情按钮聚焦输入框但不唤起输入法，点击输入框唤起输入法。
class MessageInput extends StatefulWidget {
  final TextEditingController textController; // 外部传入的文本控制器
  final ChatController controller; // 聊天控制器

  const MessageInput({
    super.key,
    required this.textController,
    required this.controller,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  // 常量定义
  static const _inputHeight = 36.0; // 输入框高度
  static const _inputBorderRadius = 6.0; // 输入框圆角
  static const _emojiPickerHeight = 250.0; // 表情选择器高度
  static const _buttonWidth = 36.0; // 图标按钮宽度
  static const _sendButtonWidth = 74.0; // 发送按钮宽度
  static const _iconSize = 30.0; // 图标大小
  static const _hintText = '输入消息...'; // 输入框提示文本
  static const _mentionTrigger = '@'; // 触发@的字符
  static const _animationDuration = Duration(milliseconds: 200); // 按钮切换动画时长

  // 状态变量
  bool _showEmojiPicker = false; // 是否显示表情选择器
  bool _hasText = false; // 输入框是否有内容

  // 控制器
  late final TextEditingController _richTextController; // 富文本控制器
  final FocusNode _focusNode = FocusNode(); // 输入框焦点

  @override
  void initState() {
    super.initState();

    /// 初始化控制器和监听器
    _richTextController = widget.textController;
    _richTextController.addListener(_onTextChanged);
    _richTextController.addListener(_checkForMentionTrigger);
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void dispose() {
    /// 释放资源
    _richTextController.removeListener(_onTextChanged);
    _richTextController.removeListener(_checkForMentionTrigger);
    _richTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- 数据处理方法 ---

  /// 监听文本变化，更新按钮显示状态
  void _onTextChanged() {
    final hasText = _richTextController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  /// 检查@触发逻辑，显示用户选择抽屉
  void _checkForMentionTrigger() {
    final text = _richTextController.text;
    final selection = _richTextController.selection;

    if (selection.baseOffset > 0 &&
        selection.baseOffset == text.length &&
        text.endsWith(_mentionTrigger) &&
        (text.length == 1 || text[text.length - 2] == ' ')) {
      if (widget.controller.currentChat.value?.chatType ==
          IMessageType.groupMessage.code) {
        _showMentionDrawer();
      }
    }
  }

  /// 插入@用户
  void _insertMention(String username) {
    final text = _richTextController.text;
    final selection = _richTextController.selection;

    if (username.isEmpty) {
      Get.snackbar('提示', '用户名不能为空');
      return;
    }

    final mentionPattern = '@$username\\b';
    if (RegExp(mentionPattern).hasMatch(text)) {
      Get.snackbar(
        '提示',
        '已经@过该用户',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final newText = text.substring(0, selection.baseOffset - 1) +
        '@$username ' +
        text.substring(selection.baseOffset);
    final newCursorPosition = selection.baseOffset - 1 + username.length + 2;

    _richTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
    Navigator.pop(context);
  }

  /// 插入表情
  void _insertEmoji(String emoji) {
    final text = _richTextController.text;
    final selection = _richTextController.selection;
    final newText = text.substring(0, selection.baseOffset) +
        emoji +
        text.substring(selection.baseOffset);
    final newCursorPosition = selection.baseOffset + emoji.length;

    _richTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  /// 处理键盘退格键，删除整个@用户名
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      return _handleBackspace()
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  /// 处理退格键逻辑，删除整个@用户名
  bool _handleBackspace() {
    final text = _richTextController.text;
    final selection = _richTextController.selection;

    if (!selection.isValid ||
        !selection.isCollapsed ||
        selection.baseOffset <= 0) {
      return false;
    }

    final textBeforeCursor = text.substring(0, selection.baseOffset);
    final match = RegExp(r'(^|\s)@\S+\s*$').firstMatch(textBeforeCursor);

    if (match != null) {
      final newText = text.replaceRange(match.start, selection.baseOffset, '');
      _richTextController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: match.start),
      );
      return true;
    }
    return false;
  }

  /// 管理焦点和输入法
  void _manageFocus({required bool showKeyboard}) {
    try {
      FocusScope.of(context).requestFocus(_focusNode);
      if (showKeyboard) {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      } else {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    } catch (e) {
      debugPrint('管理焦点失败: $e');
    }
  }

  // --- UI 构建方法 ---

  /// 构建@用户抽屉
  void _showMentionDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择要@的用户',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 20, // TODO: 替换为实际用户列表
                  itemBuilder: (context, index) {
                    final username = '用户 $index';
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(username),
                      onTap: () => _insertMention(username),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 切换表情选择器显示
  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      _manageFocus(showKeyboard: false); // 聚焦输入框但不唤起输入法
    });
  }

  /// 构建输入框
  Widget _buildInputField() {
    return Container(
      height: _inputHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        border:
            Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
      ),
      child: TextField(
        controller: _richTextController,
        focusNode: _focusNode,
        onTap: () => _manageFocus(showKeyboard: true),
        // 点击输入框唤起输入法
        decoration: InputDecoration(
          hintText: _hintText,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[400]),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey[600]),
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        enableInteractiveSelection: true,
      ),
    );
  }

  /// 构建按钮区域（表情/加号或发送）
  Widget _buildButtons() {
    return AnimatedCrossFade(
      firstChild: Row(
        key: const ValueKey('icons'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _buttonWidth,
            child: IconButton(
              onPressed: _toggleEmojiPicker,
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: _iconSize,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: _buttonWidth,
            child: IconButton(
              onPressed: () {
                // TODO: 实现加号按钮功能（如发送图片、视频）
                Get.snackbar('提示', '加号功能待实现');
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: _iconSize,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
            ),
          ),
        ],
      ),
      secondChild: SizedBox(
        key: const ValueKey('send'),
        width: _sendButtonWidth,
        height: _inputHeight,
        child: TextButton(
          onPressed: () {
            final text = _richTextController.text.trim();
            if (text.isNotEmpty) {
              widget.controller.sendMessage(text);
              _richTextController.clear();
              _manageFocus(showKeyboard: false); // 发送后隐藏输入法
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_inputBorderRadius),
            ),
          ),
          child: Text(
            '发送',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
      ),
      crossFadeState:
          _hasText ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: _animationDuration,
    );
  }

  /// 构建表情选择器
  Widget _buildEmojiPicker() {
    return SizedBox(
      height: _emojiPickerHeight,
      child: EmojiPicker(
        onEmojiSelected: (emoji) {
          _insertEmoji(emoji);
          _manageFocus(showKeyboard: false); // 插入表情后保持焦点但不唤起输入法
        },
        onDelete: () {
          final text = _richTextController.text;
          if (text.isEmpty) return;

          final lastCharIndex = text.characters.length - 1;
          if (lastCharIndex < 0) return;

          _richTextController.text =
              text.characters.take(lastCharIndex).toString();
          _richTextController.selection = TextSelection.fromPosition(
            TextPosition(offset: _richTextController.text.length),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Theme.of(context).colorScheme.background,
          child: Row(
            children: [
              Expanded(child: _buildInputField()),
              const SizedBox(width: 8),
              _buildButtons(),
            ],
          ),
        ),
        if (_showEmojiPicker) _buildEmojiPicker(),
      ],
    );
  }
}
