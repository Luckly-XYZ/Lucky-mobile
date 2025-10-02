import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../config/app_config.dart';
import '../../../../utils/file.dart';
import '../../../models/expression_pack.dart';

/// EmojiPicker 组件
///
/// 使用 [DefaultTabController] 管理 TabController，并且根据 [_expressionPacks] 的数量动态设置 Tab 个数。
/// 第一个 Tab（即索引 0）中还会展示“最近使用”表情区域，其余 Tab 则只展示对应表情包的内容。
class EmojiPicker extends StatefulWidget {
  /// 当用户选中表情时的回调函数，返回表情对应的字符串
  final ValueChanged<String> onEmojiSelected;

  /// 当用户点击删除按钮时的回调函数
  final VoidCallback onDelete;

  const EmojiPicker({
    Key? key,
    required this.onEmojiSelected,
    required this.onDelete,
  }) : super(key: key);

  @override
  _EmojiPickerState createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  List<ExpressionPack> _expressionPacks = []; // 表情包列表
  List<Expression> _recentEmojis = []; // 最近使用的表情列表

  final String _recentKey = "recent_emojis"; // 存储最近使用表情的键
  final _storage = GetStorage(); // GetStorage 实例，用于数据持久化

  @override
  void initState() {
    super.initState();
    // 初始化数据，加载网络/资源表情包、本地表情包以及最近使用的表情数据
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    // 如果 _expressionPacks 为空，则先用一个默认长度为 1 的 DefaultTabController
    // 加载完成后，_expressionPacks 长度更新为实际的表情包数量，从而更新 Tab 个数
    // 确保 TabBar 至少有一个 tab
    final tabCount = _expressionPacks.isEmpty ? 1 : _expressionPacks.length;

    return DefaultTabController(
      length: tabCount,
      child: Stack(
        children: [
          Column(
            children: [
              _buildTabBar(), // 构建顶部的 TabBar 标签栏
              // 使用 Expanded 包裹 TabBarView，使其占满剩余空间
              Expanded(
                child: TabBarView(
                  children: _expressionPacks.isEmpty
                      ? [
                          // 空状态下显示一个加载页面
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("正在加载表情..."),
                            ),
                          )
                        ]
                      : _buildTabViews(),
                ),
              ),
            ],
          ),
          // 右下角的删除按钮，带有渐变背景效果
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, 0.7),
                  radius: 1.2,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
              child: Align(
                alignment: const Alignment(0.7, 0.7),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onDelete,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.backspace_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 根据加载的表情包数据构建 TabBarView 的每个页面
  ///
  /// 如果 [_expressionPacks] 为空，则返回一个加载提示页面；
  /// 否则，每个 Tab 对应一个表情包，索引 0 的 Tab 同时显示“最近使用”区域。
  List<Widget> _buildTabViews() {
    if (_expressionPacks.isEmpty) {
      // 表情包数据还未加载时，返回一个占位页面
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("正在加载表情..."),
          ),
        )
      ];
    }
    return List.generate(_expressionPacks.length, (index) {
      final pack = _expressionPacks[index];
      // 根据表情包类型选择不同的网格布局：emoji 或图片
      final grid = pack.type == ExpressionType.emoji
          ? _buildEmojiGrid(pack.expressions)
          : _buildImageGrid(pack.expressions);
      // 若当前为第一个 Tab，则在网格前显示“最近使用”区域
      if (index == 0) {
        return ListView(
          children: [
            _buildSectionHeader("最近使用"),
            _buildRecentEmojis(),
            _buildSectionHeader("全部表情"),
            grid,
          ],
        );
      } else {
        return ListView(
          children: [
            grid,
          ],
        );
      }
    });
  }

  /// 初始化数据：加载最近使用表情、网络/资源表情包和本地表情包
  Future<void> _initializeData() async {
    await Future.wait([
      _loadRecentEmojis(),
      _loadExpressionPacks(),
      _loadLocalExpressionPacks(),
    ]);
  }

  /// 加载网络或资源中的表情包
  Future<void> _loadExpressionPacks() async {
    try {
      final jsonString = await rootBundle.loadString(AppConfig.emojiPath);
      final jsonData = jsonDecode(jsonString);

      setState(() {
        _expressionPacks.add(ExpressionPack.fromJson(jsonData));
      });

      // 输出调试信息
      debugPrint('加载表情包数量: ${_expressionPacks.length}');
      for (var pack in _expressionPacks) {
        debugPrint('表情包 ${pack.packName}: ${pack.expressions.length} 个表情');
        debugPrint('第一个表情: ${pack.expressions.firstOrNull?.unicode}');
      }
    } catch (e, stackTrace) {
      debugPrint('加载表情包失败: $e');
      debugPrint('错误堆栈: $stackTrace');
    }
  }

  /// 加载本地存储的图片表情包
  Future<void> _loadLocalExpressionPacks() async {
    try {
      // 扫描指定路径下的 JSON 文件
      final files = await FileUtils.scanFilesWithExtension(
        AppConfig.pickerPath,
        ['json'],
      );

      // 遍历每个文件，解析表情包数据
      for (var file in files) {
        final jsonString = await File(file.filePath).readAsString();
        final jsonData = jsonDecode(jsonString);
        ExpressionPack expressionPack = ExpressionPack.fromJson(jsonData);
        if (expressionPack.type == ExpressionType.image) {
          // 拼接图片资源的完整路径
          for (var expression in expressionPack.expressions) {
            expression.imageURL = '${file.dirPath}/${expression.imageURL!}';
          }
        }
        setState(() {
          _expressionPacks.add(expressionPack);
        });
      }
      debugPrint('加载本地表情包: $files');
    } catch (e) {
      debugPrint('加载本地表情包失败: $e');
    }
  }

  /// 加载最近使用的表情数据
  Future<void> _loadRecentEmojis() async {
    try {
      final storedEmojis = _storage.read<List>(_recentKey);
      if (storedEmojis != null) {
        setState(() {
          _recentEmojis = storedEmojis
              .map((e) => Expression.fromJson(e))
              .where((e) => e.unicode != null && e.unicode!.isNotEmpty)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('加载最近使用表情失败: $e');
      // 如果加载失败，确保列表为空
      setState(() {
        _recentEmojis = [];
      });
    }
  }

  /// 保存最近使用的表情数据
  Future<void> _saveRecentEmojis() async {
    try {
      final emojiList = _recentEmojis.map((e) => e.toJson()).toList();
      await _storage.write(_recentKey, emojiList);
    } catch (e) {
      debugPrint('保存最近使用表情失败: $e');
    }
  }

  /// 处理用户点击表情的逻辑
  ///
  /// 更新最近使用表情列表，并通过回调返回表情对应的值（emoji 的 unicode 或图片 URL）
  void _onEmojiTap(Expression expression, ExpressionType type) {
    setState(() {
      // 如果表情已存在，则先移除，再插入到列表首位
      _recentEmojis.remove(expression);
      _recentEmojis.insert(0, expression);
      // 限制最近使用表情最多存储 8 个
      if (_recentEmojis.length > 8) {
        _recentEmojis = _recentEmojis.sublist(0, 8);
      }
    });
    _saveRecentEmojis();
    final value = type.name == 'emoji'
        ? expression.unicode ?? ''
        : expression.imageURL ?? '';
    widget.onEmojiSelected(value);
  }

  /// 构建 Emoji 表情网格，每行显示 8 个表情
  Widget _buildEmojiGrid(List<Expression> emojis) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: emojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        return _buildEmojiItem(emojis[index]);
      },
    );
  }

  /// 构建图片表情网格，每行显示 4 个表情
  Widget _buildImageGrid(List<Expression> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        return _buildImageItem(images[index]);
      },
    );
  }

  /// 构建单个 Emoji 表情项
  Widget _buildEmojiItem(Expression expression) {
    // 数据有效性检查
    if (expression.unicode == null || expression.unicode!.isEmpty) {
      debugPrint('警告: 发现无效的 Emoji 表情数据: ${expression.id}');
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () => _onEmojiTap(expression, ExpressionType.emoji),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          expression.unicode!,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  /// 构建单个图片表情项
  Widget _buildImageItem(Expression expression) {
    // 数据有效性检查
    if (expression.imageURL == null || expression.imageURL!.isEmpty) {
      debugPrint('警告: 发现无效的图片表情数据: ${expression.id}');
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () => _onEmojiTap(expression, ExpressionType.image),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Image.file(
          File(expression.imageURL!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('加载图片表情失败: $error, 路径: ${expression.imageURL}');
            return const Icon(
              Icons.error_outline,
              color: Colors.grey,
              size: 24,
            );
          },
        ),
      ),
    );
  }

  /// 构建顶部的 TabBar 标签栏
  ///
  /// 根据 [_expressionPacks] 动态生成 Tab 标签，
  /// 每个 Tab 显示对应表情包的第一个表情（若为空，则显示默认 Emoji）。
  Widget _buildTabBar() {
    // ... existing code ...
    return SizedBox(
      height: 36,
      child: TabBar(
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: _expressionPacks.map((pack) {
          if (pack.type == ExpressionType.emoji) {
            // 对于 emoji 类型，使用 unicode
            final emoji = pack.expressions.isNotEmpty
                ? pack.expressions.first.unicode ?? "😀"
                : "😀";
            return Tab(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else {
            // 对于图片类型，使用本地图片展示
            final imagePath = pack.expressions.isNotEmpty
                ? pack.expressions.first.imageURL
                : null;
            return Tab(
              child: imagePath != null
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('加载图片表情失败: $error, 路径: ${imagePath}');
                          return const Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.image,
                      size: 18,
                    ),
            );
          }
        }).toList(),
        indicatorWeight: 2,
        labelPadding: EdgeInsets.zero,
      ),
    );
  }

  /// 构建部分标题，用于分隔不同表情区域
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// 构建最近使用表情区域
  Widget _buildRecentEmojis() {
    return _recentEmojis.isEmpty
        ? const SizedBox(
            height: 80,
            child: Center(child: Text("暂无最近使用的表情")),
          )
        : _buildEmojiGrid(_recentEmojis);
  }
}
