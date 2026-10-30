import 'dart:ui';

import 'package:flutter/material.dart';

/// 通用液态玻璃按钮。
///
/// 结构：BackdropFilter 毛玻璃 + 白色半透明渐变 + 1px 半透明描边，
/// 按下时整体缩小到 [pressedScale]，松开后使用 elasticOut 曲线弹回。
/// 通过 [tint] 可以给玻璃混入任意主题色（例如各国的淡彩色）。
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.borderRadius = 28,
    this.blurSigma = 16,
    this.tint,
    this.pressedScale = 0.95,
  });

  /// 按钮内容。
  final Widget child;

  /// 点击回调，为 null 时按钮不可点击。
  final VoidCallback? onTap;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  /// 圆角半径，胶囊按钮可传入高度的一半。
  final double borderRadius;

  /// 毛玻璃模糊强度。
  final double blurSigma;

  /// 玻璃主题色（会以低透明度混入白色基底）。
  final Color? tint;

  /// 按下时缩放比例。
  final double pressedScale;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(widget.borderRadius);
    final Color tint = widget.tint ?? Colors.white;
    final bool tinted = widget.tint != null;

    // 白色 15% 左右的玻璃基底，按需混入主题淡彩。
    final List<Color> glassColors = <Color>[
      Color.lerp(
        Colors.white,
        tint,
        tinted ? 0.30 : 0.0,
      )!.withValues(alpha: tinted ? 0.30 : 0.18),
      Color.lerp(
        Colors.white,
        tint,
        tinted ? 0.55 : 0.0,
      )!.withValues(alpha: tinted ? 0.17 : 0.12),
      Color.lerp(
        Colors.white,
        tint,
        tinted ? 0.20 : 0.0,
      )!.withValues(alpha: 0.05),
    ];

    final List<BoxShadow> shadows = <BoxShadow>[
      // 微弱的黑色投影，把玻璃从背景中轻轻托起。
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.32),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      if (tinted)
        BoxShadow(
          color: tint.withValues(alpha: _pressed ? 0.26 : 0.13),
          blurRadius: 26,
          spreadRadius: 1,
        ),
    ];

    return Semantics(
      button: true,
      enabled: _enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: Duration(milliseconds: _pressed ? 110 : 420),
          // 按下快速收缩，松开时弹回，形成 Q 弹的液态触感。
          curve: _pressed ? Curves.easeOutCubic : Curves.elasticOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: widget.width,
            height: widget.height,
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
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: glassColors,
                      stops: const <double>[0.0, 0.55, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: _pressed ? 0.42 : 0.28,
                      ),
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
