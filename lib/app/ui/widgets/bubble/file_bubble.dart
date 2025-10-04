import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/message_receive.dart';
import '../../../routes/app_routes.dart';
import '../icon/icon_font.dart';

/// 文件消息气泡组件，显示聊天中的文件消息
/// 特性：
/// - 显示文件图标、名称、大小，支持打开和下载操作。
/// - 根据 [isMe] 调整气泡样式（左右对齐、颜色）。
/// - 显示用户头像和名称，支持点击头像跳转到好友资料页面。
/// - 使用 [Iconfont] 组件加载文件类型图标。
class FileBubble extends StatelessWidget {
  // 常量定义
  static const _padding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8); // 气泡外边距
  static const _bubblePadding = EdgeInsets.all(12); // 气泡内边距
  static const _avatarSize = 40.0; // 头像尺寸
  static const _avatarBorderRadius = 8.0; // 头像圆角
  static const _iconSize = 32.0; // 文件图标尺寸
  static const _nameStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500); // 文件名样式
  static const _sizeStyle =
      TextStyle(fontSize: 12, color: Colors.grey); // 文件大小样式
  static const _nameTextStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500); // 用户名样式
  static const _spacing = 8.0; // 水平间距
  static const _verticalSpacing = 4.0; // 垂直间距

  final IMessage message; // 消息对象
  final bool isMe; // 是否为当前用户发送
  final String name; // 用户名称
  final String avatar; // 用户头像 URL

  const FileBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.name,
    required this.avatar,
  });

  FileMessageBody? get fileBody =>
      FileMessageBody.fromMessageBody(message.messageBody);

  @override
  Widget build(BuildContext context) {
    final fileBody = this.fileBody;
    if (fileBody == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: _padding,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            _buildAvatar(context),
            const SizedBox(width: _spacing)
          ],
          Flexible(child: _buildBubbleContent(context, fileBody)),
          if (isMe) ...[const SizedBox(width: _spacing), _buildAvatar(context)],
        ],
      ),
    );
  }

  // --- UI 构建方法 ---

  /// 构建头像
  Widget _buildAvatar(BuildContext context) {
    return GestureDetector(
      onTap: isMe
          ? null
          : () => Get.toNamed('${Routes.HOME}${Routes.FRIEND_PROFILE}',
              arguments: {'userId': message.fromId}),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_avatarBorderRadius),
        child: CachedNetworkImage(
          imageUrl: avatar,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Iconfont.buildIcon(
                icon: Iconfont.person, size: 24, color: Colors.grey),
          ),
          errorWidget: (context, url, error) {
            debugPrint('加载头像失败: $error');
            return Container(
              color: Colors.grey[200],
              child: Iconfont.buildIcon(
                  icon: Iconfont.person, size: 24, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  /// 构建气泡内容（用户名、文件信息、操作按钮）
  Widget _buildBubbleContent(BuildContext context, FileMessageBody fileBody) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        /// 用户名
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ) ??
              _nameTextStyle,
        ),
        const SizedBox(height: _verticalSpacing),

        /// 文件气泡
        GestureDetector(
          onTap: () => _handleFileAction(context, fileBody, _FileAction.open),
          child: Container(
            padding: _bubblePadding,
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 文件图标
                Iconfont.buildIcon(
                  icon: _getFileIcon(fileBody.suffix ?? ''),
                  size: _iconSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: _spacing),

                /// 文件信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileBody.name ?? '未知文件',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500) ??
                            _nameStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(fileBody.size ?? 0),
                        style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey) ??
                            _sizeStyle,
                      ),
                    ],
                  ),
                ),

                /// 下载按钮
                // IconButton(
                //   icon: Iconfont.buildIcon(icon: Iconfont.download, size: 20),
                //   onPressed: () => _handleFileAction(context, fileBody, _FileAction.download),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 逻辑处理方法 ---

  /// 获取文件图标（基于文件扩展名）
  IconData _getFileIcon(String suffix) {
    return Iconfont.fromFileExtension(suffix.toLowerCase());
  }

  /// 格式化文件大小
  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024)
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 处理文件操作（打开或下载）
  Future<void> _handleFileAction(BuildContext context, FileMessageBody fileBody,
      _FileAction action) async {
    // if (fileBody.path != null && action == _FileAction.open) {
    //   final file = File(fileBody.path!);
    //   if (await file.exists()) {
    //     // TODO: 使用 open_file 插件打开文件
    //     Get.snackbar('提示', '正在打开文件: ${fileBody.name}');
    //   } else {
    //     Get.snackbar('提示', '文件不存在，将开始下载');
    //     await _downloadFile(context, fileBody);
    //   }
    // } else {
    //   await _downloadFile(context, fileBody);
    // }
  }

  /// 下载文件
  Future<void> _downloadFile(
      BuildContext context, FileMessageBody fileBody) async {
    // TODO: 实现文件下载逻辑
    try {
      // 假设使用 ApiService 下载文件
      Get.snackbar('提示', '开始下载: ${fileBody.name}');
      // final apiService = Get.find<ApiService>();
      // final path = await apiService.downloadFile(fileBody.url);
      // fileBody.path = path;
    } catch (e) {
      Get.snackbar('错误', '下载失败: $e');
    }
  }
}

/// 文件操作类型
enum _FileAction { open, download }
