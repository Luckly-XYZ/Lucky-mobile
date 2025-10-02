import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../constants/app_message.dart';
import '../../../controller/chat_controller.dart';
import '../../widgets/emoji/emoji_picker.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController textController;
  final ChatController controller;

  const MessageInput({
    Key? key,
    required this.textController,
    required this.controller,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _showEmojiPicker = false;
  bool _hasText = false;

  late TextEditingController _richTextController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _richTextController = TextEditingController();
    _richTextController.addListener(_onTextChanged);
    _richTextController.addListener(_checkForMentionTrigger);
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void dispose() {
    _richTextController.removeListener(_onTextChanged);
    _richTextController.removeListener(_checkForMentionTrigger);
    _richTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 监听文本变化
  void _onTextChanged() {
    final hasText = _richTextController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  /// 检查是否触发@功能
  void _checkForMentionTrigger() {
    final text = _richTextController.text;
    final selection = _richTextController.selection;

    if (selection.baseOffset > 0 && selection.baseOffset == text.length) {
      // 检查@符号前是否有空格
      if (text.endsWith('@') &&
          (text.length == 1 || text[text.length - 2] == ' ')) {
        // 判断当前聊天类型是否为群聊
        if (widget.controller.currentChat.value?.chatType ==
            MessageType.groupMessage.code) {
          // 如果是群聊，则显示@用户列表抽屉
          _showMentionDrawer();
        }
      }
    }
  }

  /// 显示@用户列表抽屉
  void _showMentionDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许抽屉占据更多空间
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          // 初始高度为屏幕的一半
          minChildSize: 0.3,
          // 最小高度
          maxChildSize: 0.9,
          // 最大高度
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '选择要@的用户',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 20, // 这里替换为实际的用户列表长度
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text('用户 $index'),
                          onTap: () {
                            _insertMention('用户$index');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 插入@用户
  void _insertMention(String username) {
    final text = _richTextController.text;
    final selection = _richTextController.selection;

    // 使用正则表达式检查是否已经@过该用户
    final mentionPattern = '@$username\\b';
    if (RegExp(mentionPattern).hasMatch(text)) {
      Get.snackbar(
        '提示',
        '已经@过该用户了',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      // 删除触发@的符号
      final newText = text.substring(0, selection.baseOffset - 1) +
          '@$username ' +
          text.substring(selection.baseOffset);

      final newCursorPosition =
          selection.baseOffset - 1 + username.length + 2; // +2 for @ and space

      _richTextController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
      Navigator.pop(context);
    }
  }

  /// 插入表情
  void _insertEmoji(String emoji) {
    final text = _richTextController.text;
    final newText = text + emoji;
    _richTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }

  /// 获取富文本
  String _getRichText() {
    return _richTextController.text;
  }

  /// 切换表情选择器
  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        _focusNode.unfocus(); // 取消键盘焦点，防止键盘弹出
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          _focusNode.requestFocus(); // 重新获取焦点
        });
      }
    });
  }

  // 添加键盘事件处理
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Backspace') {
      return _handleBackspace()
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  // 处理退格键
  bool _handleBackspace() {
    final text = _richTextController.text;
    final selection = _richTextController.selection;

    // 如果没有选中文本且光标不在文本开始位置
    if (!selection.isValid ||
        selection.isCollapsed && selection.baseOffset > 0) {
      // 查找光标前的文本
      final textBeforeCursor = text.substring(0, selection.baseOffset);

      // 使用正则表达式匹配最后一个@用户名
      final match = RegExp(r'(^|\s)@\S+\s*$').firstMatch(textBeforeCursor);

      if (match != null) {
        // 找到@用户名，删除整个@用户名
        final newText =
            text.replaceRange(match.start, selection.baseOffset, '');
        _richTextController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: match.start),
        );
        return true;
      }
    }
    return false;
  }

  /// 构建输入框
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 8,
            top: 4,
            bottom: 4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color.fromARGB(255, 222, 217, 217),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _richTextController,
                    focusNode: _focusNode,
                    onTap: () {
                      if (_showEmojiPicker) {
                        setState(() {
                          _showEmojiPicker = false;
                        });
                      }
                    },
                    onChanged: (value) {
                      // 文本变化时的处理保持不变
                    },
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    enableInteractiveSelection: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Visibility(
                    visible: !_hasText,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          child: IconButton(
                            onPressed: _toggleEmojiPicker,
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey[600],
                              size: 30,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 36,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 36,
                          child: IconButton(
                            onPressed: () {
                              // TODO: 实现加号按钮功能
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Colors.grey[600],
                              size: 30,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _hasText,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: SizedBox(
                      width: 74,
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          final text = _getRichText().trim();
                          if (text.isNotEmpty) {
                            widget.controller.sendMessage(text);
                            _richTextController.clear();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          '发送',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (emoji) {
                // 选择表情
                _insertEmoji(emoji);
              },
              onDelete: () {
                // 回退
                final text = _richTextController.text;
                if (text.isEmpty) return;

                // 获取最后一个字符的位置
                final lastCharIndex = text.characters.length - 1;
                if (lastCharIndex < 0) return;

                // 使用 characters 来正确处理表情符号
                _richTextController.text =
                    text.characters.take(lastCharIndex).toString();
                _richTextController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _richTextController.text.length),
                );
              },
            ),
          ),
      ],
    );
  }
}
