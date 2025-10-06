import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LongPressMenu extends StatefulWidget {
  final Widget child;
  final List<MenuItem> items;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final Duration animationDuration;
  final bool enableHaptic;
  final Offset offset; // 全局偏移 (dx, dy)
  final double maxMenuWidth;

  const LongPressMenu({
    Key? key,
    required this.child,
    required this.items,
    this.backgroundColor,
    this.shape,
    this.animationDuration = const Duration(milliseconds: 150),
    this.enableHaptic = true,
    this.offset = Offset.zero,
    this.maxMenuWidth = 220,
  }) : super(key: key);

  @override
  State<LongPressMenu> createState() => _LongPressMenuState();
}

class _LongPressMenuState extends State<LongPressMenu>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isShowing = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _dismissMenu(immediately: true);
    _controller.dispose();
    super.dispose();
  }

  void _showMenuAt(Offset globalPosition) {
    if (_isShowing || widget.items.isEmpty) return;
    _isShowing = true;

    if (widget.enableHaptic) HapticFeedback.mediumImpact();

    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // 计算菜单尺寸（估算）：每项高度 48
    final itemHeight = 48.0;
    final menuHeight = itemHeight * widget.items.length + 8.0;
    final menuWidth = widget.maxMenuWidth.clamp(120.0, screenSize.width - 24.0);

    // 初步位置：水平居中于 globalPosition.dx，垂直向下 10px
    double left = globalPosition.dx - menuWidth / 2 + widget.offset.dx;
    double top = globalPosition.dy + 10.0 + widget.offset.dy;

    // 水平边界修正
    if (left < 8.0) left = 8.0;
    if (left + menuWidth > screenSize.width - 8.0)
      left = screenSize.width - menuWidth - 8.0;

    // 垂直超出则向上弹
    if (top + menuHeight > screenSize.height - padding.bottom - 8.0) {
      top = globalPosition.dy - menuHeight - 10.0 + widget.offset.dy;
      if (top < padding.top + 8.0) top = padding.top + 8.0;
    }

    _overlayEntry = OverlayEntry(builder: (ctx) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _dismissMenu(),
        onSecondaryTap: () => _dismissMenu(),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 屏幕遮罩（透明，拦截点击）
              Positioned.fill(
                child: Container(color: Colors.transparent),
              ),
              // 菜单
              Positioned(
                left: left,
                top: top,
                child: SafeArea(
                  minimum: const EdgeInsets.all(4.0),
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    alignment: Alignment.topCenter,
                    child: _buildMenuContainer(menuWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    Overlay.of(context)!.insert(_overlayEntry!);
    _controller.forward();
  }

  Widget _buildMenuContainer(double width) {
    final bg = widget.backgroundColor ?? Theme.of(context).cardColor;
    final shape = widget.shape ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0));
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: ShapeDecoration(
          color: bg,
          shape: shape,
          shadows: [
            const BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((it) {
            return InkWell(
              onTap: () {
                _dismissMenu();
                // 延后执行回调，确保 overlay 已被移除，避免页面栈竞争
                Future.microtask(() => it.onTap?.call());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14.0, vertical: 12.0),
                child: Row(
                  children: [
                    if (it.icon != null) ...[
                      Icon(it.icon,
                          size: 20, color: Theme.of(context).iconTheme.color),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                        child: Text(it.title,
                            style: const TextStyle(fontSize: 16))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _dismissMenu({bool immediately = false}) {
    if (!_isShowing) return;
    _isShowing = false;
    if (_overlayEntry == null) return;
    try {
      if (immediately) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      } else {
        _controller.reverse().whenComplete(() {
          _overlayEntry?.remove();
          _overlayEntry = null;
        });
      }
    } catch (_) {
      _overlayEntry = null;
    }
  }

  // 支持长按开始（获取精确位置）和桌面右键（secondary tap）
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (ev) {
        // 可选：按下时做一些视觉反馈等
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (details) {
          _showMenuAt(details.globalPosition);
        },
        onSecondaryTapDown: (details) {
          // 右键（桌面/网页）也弹出菜单
          _showMenuAt(details.globalPosition);
        },
        child: widget.child,
      ),
    );
  }
}

/// 菜单项数据类（同你的定义）
class MenuItem {
  final IconData? icon;
  final String title;
  final VoidCallback? onTap;

  const MenuItem({this.icon, required this.title, this.onTap});
}
