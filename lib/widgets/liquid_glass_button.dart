import 'dart:ui';

import 'package:flutter/material.dart';

/// 可复用的液态玻璃按压按钮。
///
/// - BackdropFilter 毛玻璃 + 半透明白色描边
/// - 按下缩放到 [pressedScale]，松开弹回
/// - 快速点击时保证按压态至少显示 [minPressDuration]，
///   让跳转前能看到完整的缩小反馈
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 22,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.blurSigma = 16,
    this.constraints,
    this.pressedScale = 0.95,
    this.minPressDuration = const Duration(milliseconds: 110),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double blurSigma;
  final BoxConstraints? constraints;
  final double pressedScale;
  final Duration minPressDuration;
  final String? semanticLabel;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton> {
  bool _pressed = false;
  bool _busy = false;
  DateTime? _pressStartedAt;

  bool get _enabled => widget.onTap != null;

  void _handleTapDown(TapDownDetails _) {
    if (!_enabled || _busy) {
      return;
    }
    _pressStartedAt = DateTime.now();
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    // 这里故意不立即清除按压态。快速点击时 onTapUp 往往和 onTap
    // 落在同一帧，如果此时恢复 scale，用户就看不到缩小反馈。
    // 真正的释放交给 _handleTap 的最短按压时长控制。
  }

  void _handleTapCancel() {
    if (!_pressed) {
      return;
    }
    setState(() => _pressed = false);
    _pressStartedAt = null;
  }

  Future<void> _handleTap() async {
    if (!_enabled || _busy) {
      return;
    }
    _busy = true;

    final DateTime now = DateTime.now();
    final Duration elapsed = _pressStartedAt == null
        ? Duration.zero
        : now.difference(_pressStartedAt!);
    final Duration remaining = widget.minPressDuration - elapsed;

    // 至少让按压动画走完，再执行跳转。
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) {
      return;
    }

    setState(() => _pressed = false);
    widget.onTap?.call();

    // 给路由转场留出时间，同时保证返回列表后按钮可以再次点击。
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(widget.borderRadius);
    final Color background =
        widget.backgroundColor ?? Colors.white.withValues(alpha: 0.12);
    final Color border =
        widget.borderColor ?? Colors.white.withValues(alpha: 0.28);
    final List<BoxShadow> shadows =
        widget.boxShadow ??
        const <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ];

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? _handleTapDown : null,
        onTapUp: _enabled ? _handleTapUp : null,
        onTapCancel: _enabled ? _handleTapCancel : null,
        onTap: _enabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: Duration(milliseconds: _pressed ? 110 : 420),
          curve: _pressed ? Curves.easeOutCubic : Curves.elasticOut,
          child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: widget.constraints,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: radius,
                    border: Border.all(
                      color: _pressed ? border.withValues(alpha: 0.46) : border,
                      width: 1,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
