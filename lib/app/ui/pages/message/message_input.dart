import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../constants/app_message.dart';
import '../../../controller/chat_controller.dart';
import '../../widgets/emoji/emoji_picker.dart';

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
  // 常量
  static const _inputHeight = 36.0;
  static const _inputBorderRadius = 6.0;
  static const _emojiPickerHeight = 250.0;
  static const _buttonWidth = 36.0;
  static const _sendButtonWidth = 74.0;
  static const _iconSize = 30.0;
  static const _hintText = '输入消息...';
  static const _mentionTrigger = '@';
  static const _animationDuration = Duration(milliseconds: 200);

  // 状态
  bool _showEmojiPicker = false;
  bool _hasText = false;
  bool _isReadOnly = false; // 当表情面板展示时设为 true，防止键盘弹出

  // 控制器/焦点
  late final TextEditingController _richTextController;
  final FocusNode _focusNode = FocusNode();

  // 保存上次 selection（用于在失去焦点时记住光标位置，并在恢复键盘时还原）
  TextSelection? _lastSelection;

  @override
  void initState() {
    super.initState();
    _richTextController = widget.textController;
    _richTextController.addListener(_onTextChanged);
    _richTextController.addListener(_checkForMentionTrigger);
    _focusNode.onKeyEvent = _handleKeyEvent;

    // 监听焦点变化：当输入框获得焦点且表情面板打开时，关闭表情面板
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
          _isReadOnly = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // 注意：textController 是外部传入的，不在这里 dispose
    _richTextController.removeListener(_onTextChanged);
    _richTextController.removeListener(_checkForMentionTrigger);
    _focusNode.dispose();
    super.dispose();
  }

  // --- 文本 & mention 逻辑 ---
  void _onTextChanged() {
    final hasText = _richTextController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

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

  // --- emoji 插入、回退光标等 ---
  void _insertEmoji(String emoji) {
    String text = _richTextController.text;
    TextSelection sel = _richTextController.selection;

    // 如果 selection 无效，尝试使用 _lastSelection 或追加到末尾
    if (!sel.isValid) {
      sel = _lastSelection ?? TextSelection.collapsed(offset: text.length);
    }

    final start = sel.baseOffset;
    final newText = text.substring(0, start) + emoji + text.substring(start);
    final newCursorPosition = start + emoji.length;

    _richTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    // 插入表情后确保键盘保持隐藏（我们使用表情面板）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _focusNode.unfocus();
      // 更新 lastSelection
      _lastSelection = _richTextController.selection;
    });
  }

  // 退格处理：删除整个@用户名
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      return _handleBackspace()
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

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

  // --- 焦点 / 键盘 / 表情面板 管理 ---

  /// 切换表情面板显示
  void _toggleEmojiPicker() {
    if (!_showEmojiPicker) {
      // 要显示表情面板：记录当前 selection，设置 readOnly，隐藏键盘并失去焦点
      _lastSelection = _richTextController.selection;
      setState(() {
        _showEmojiPicker = true;
        _isReadOnly = true;
      });
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _focusNode.unfocus();
    } else {
      // 隐藏表情面板并唤起键盘
      setState(() {
        _showEmojiPicker = false;
        _isReadOnly = false;
      });

      // 恢复焦点并还原 selection（异步执行以确保焦点生效）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
        // 还原 selection（如果有）
        _richTextController.selection =
            _lastSelection ?? TextSelection.collapsed(offset: _richTextController.text.length);
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  /// 当用户点击输入框时的行为
  void _onInputTap() {
    if (_showEmojiPicker) {
      // 用户点击输入框：关闭表情面板并显示键盘
      setState(() {
        _showEmojiPicker = false;
        _isReadOnly = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
        _richTextController.selection =
            _lastSelection ?? TextSelection.collapsed(offset: _richTextController.text.length);
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    } else {
      // 正常点击（保证焦点）
      FocusScope.of(context).requestFocus(_focusNode);
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }

  // --- UI 构建 ---
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

  Widget _buildInputField() {
    return Container(
      height: _inputHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
      ),
      child: TextField(
        controller: _richTextController,
        focusNode: _focusNode,
        readOnly: _isReadOnly,
        onTap: _onInputTap,
        decoration: InputDecoration(
          hintText: _hintText,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[400]),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildButtons() {
    return AnimatedSwitcher(
      duration: _animationDuration,
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: _hasText
          ? SizedBox(
        key: const ValueKey('send'),
        width: _sendButtonWidth,
        height: _inputHeight,
        child: TextButton(
          onPressed: () {
            final text = _richTextController.text.trim();
            if (text.isNotEmpty) {
              widget.controller.sendMessage(text);
              _richTextController.clear();
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              FocusScope.of(context).requestFocus(_focusNode);
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
      )
          : Row(
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
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: _emojiPickerHeight,
      child: EmojiPicker(
        onEmojiSelected: (emoji) {
          _insertEmoji(emoji);
          // 插入后保持表情面板和隐藏键盘
          setState(() {
            _showEmojiPicker = true;
            _isReadOnly = true;
          });
        },
        onDelete: () {
          final text = _richTextController.text;
          if (text.isEmpty) return;

          final lastCharIndex = text.characters.length - 1;
          if (lastCharIndex < 0) return;

          _richTextController.text = text.characters.take(lastCharIndex).toString();
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
