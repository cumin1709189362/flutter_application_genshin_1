import 'package:flutter/material.dart';

/// 高性能半透明实色按钮。
///
/// 使用纯色半透明背景 + 1px 高光边框，完全不含实时模糊合成，
/// 避免长列表和页面转场中的高开销 GPU 处理。
class SolidGradientButton extends StatefulWidget {
  const SolidGradientButton({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    required this.borderRadius,
    required this.child,
    required this.padding,
    this.width,
    this.height,
    this.constraints,
    this.backgroundOpacity = 0.35,
    this.boxShadow,
    this.pressedScale = 0.95,
    this.minPressDuration = const Duration(milliseconds: 110),
    this.semanticLabel,
  });

  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;
  final double borderRadius;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final double backgroundOpacity;
  final List<BoxShadow>? boxShadow;
  final double pressedScale;
  final Duration minPressDuration;
  final String? semanticLabel;

  @override
  State<SolidGradientButton> createState() => _SolidGradientButtonState();
}

class _SolidGradientButtonState extends State<SolidGradientButton> {
  bool _pressed = false;
  bool _busy = false;
  DateTime? _pressStartedAt;

  Color get _fillColor {
    if (widget.backgroundColor == Colors.black) {
      return Colors.black.withValues(alpha: 0.6);
    }
    return widget.backgroundColor.withValues(alpha: widget.backgroundOpacity);
  }

  List<BoxShadow> get _shadows {
    return widget.boxShadow ??
        <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
  }

  void _handleTapDown(TapDownDetails _) {
    if (_busy) {
      return;
    }
    _pressStartedAt = DateTime.now();
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    // 不在这里立即恢复 scale，避免快速点击时反馈被下一帧的跳转覆盖。
    // 真正的释放由 _handleTap 的最短展示时长控制。
  }

  void _handleTapCancel() {
    if (!_pressed) {
      return;
    }
    setState(() => _pressed = false);
    _pressStartedAt = null;
  }

  Future<void> _handleTap() async {
    if (_busy) {
      return;
    }
    _busy = true;

    final DateTime now = DateTime.now();
    final Duration elapsed = _pressStartedAt == null
        ? Duration.zero
        : now.difference(_pressStartedAt!);
    final Duration remaining = widget.minPressDuration - elapsed;

    // 至少让按压缩小动画显示一小段时间，再执行跳转。
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) {
      return;
    }

    setState(() => _pressed = false);
    widget.onTap();

    // 防止转场期间重复点击；返回后按钮恢复可交互。
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(widget.borderRadius);

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: Duration(milliseconds: _pressed ? 110 : 420),
          curve: _pressed ? Curves.easeOutCubic : Curves.elasticOut,
          child: Container(
            width: widget.width,
            height: widget.height,
            constraints: widget.constraints,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: _fillColor,
              borderRadius: radius,
              border: Border.all(color: widget.borderColor, width: 1.0),
              boxShadow: _shadows,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
