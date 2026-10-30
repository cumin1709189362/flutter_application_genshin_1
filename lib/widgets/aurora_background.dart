import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 暗黑深渊风格的动态极光背景。
///
/// 由三层叠加而成：
/// 1. 深蓝 → 纯黑的静态底色渐变；
/// 2. 多条缓慢漂移、拉伸、旋转的极光光带（径向渐变 + screen 混合）；
/// 3. 闪烁的星点与边缘暗角，强化“星空 / 深渊”的空间感。
///
/// 动画由 [AnimationController] 驱动，所有周期函数都使用 2π 的整数倍，
/// 因此循环播放时首尾可以无缝衔接。
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    this.child,
    this.duration = const Duration(seconds: 26),
  });

  /// 叠加在极光之上的页面内容。
  final Widget? child;

  /// 一次完整流动动画的时长，越长越缓慢柔和。
  final Duration duration;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant AuroraBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 静态底色：顶部深蓝、底部近乎纯黑，避免动画层透明时露出白底。
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF050B1E),
                Color(0xFF0A1A3A),
                Color(0xFF020409),
              ],
              stops: <double>[0.0, 0.55, 1.0],
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _AuroraPainter(progress: _controller.value),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

/// 一条极光光带的配置。
class _AuroraBlob {
  const _AuroraBlob({
    required this.color,
    required this.center,
    required this.radius,
    required this.opacity,
    required this.phase,
    required this.drift,
    required this.stretchX,
    required this.stretchY,
    required this.rotation,
    required this.speed,
  });

  /// 光带颜色。
  final Color color;

  /// 基准中心点（以屏幕宽高为 0~1 的相对坐标）。
  final Offset center;

  /// 半径，相对于屏幕短边。
  final double radius;

  /// 中心不透明度。
  final double opacity;

  /// 相位，错开各光带的运动节奏。
  final double phase;

  /// 漂移幅度（相对屏幕宽高）。
  final Offset drift;

  /// 横向拉伸倍数，把圆形渐变拉成光带。
  final double stretchX;

  /// 纵向拉伸倍数。
  final double stretchY;

  /// 初始旋转角度（弧度）。
  final double rotation;

  /// 运动速度，取整数以保证循环无缝。
  final int speed;
}

/// 星点配置。
class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.brightness,
  });

  final double x;
  final double y;
  final double radius;
  final double phase;
  final double brightness;
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.progress});

  /// 0 ~ 1 的循环进度。
  final double progress;

  static const List<_AuroraBlob> _blobs = <_AuroraBlob>[
    // 主极光：深蓝，横跨画面上半部分。
    _AuroraBlob(
      color: Color(0xFF2563EB),
      center: Offset(0.24, 0.28),
      radius: 0.58,
      opacity: 0.34,
      phase: 0.0,
      drift: Offset(0.14, 0.06),
      stretchX: 1.9,
      stretchY: 0.72,
      rotation: -0.32,
      speed: 1,
    ),
    // 青绿色极光：右侧竖向光柱。
    _AuroraBlob(
      color: Color(0xFF0E7490),
      center: Offset(0.82, 0.24),
      radius: 0.40,
      opacity: 0.26,
      phase: 0.28,
      drift: Offset(0.07, 0.12),
      stretchX: 0.85,
      stretchY: 1.85,
      rotation: 0.42,
      speed: 2,
    ),
    // 紫色极光：右下方的柔和雾团。
    _AuroraBlob(
      color: Color(0xFF4C1D95),
      center: Offset(0.66, 0.76),
      radius: 0.52,
      opacity: 0.28,
      phase: 0.55,
      drift: Offset(0.12, 0.05),
      stretchX: 1.7,
      stretchY: 0.9,
      rotation: 0.16,
      speed: 1,
    ),
    // 幽蓝极光：左下角压暗画面，营造深渊纵深。
    _AuroraBlob(
      color: Color(0xFF1E3A8A),
      center: Offset(0.12, 0.86),
      radius: 0.48,
      opacity: 0.30,
      phase: 0.78,
      drift: Offset(0.08, 0.07),
      stretchX: 1.4,
      stretchY: 1.1,
      rotation: -0.12,
      speed: 2,
    ),
  ];

  static final List<_Star> _stars = _buildStars();

  static List<_Star> _buildStars() {
    // 固定种子，保证每次运行星图一致，避免布局抖动。
    final math.Random random = math.Random(20240928);
    return List<_Star>.generate(96, (_) {
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.88,
        radius: 0.5 + random.nextDouble() * 1.4,
        phase: random.nextDouble(),
        brightness: 0.20 + random.nextDouble() * 0.55,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    _paintAurora(canvas, size);
    _paintStars(canvas, size);
    _paintVignette(canvas, size);
  }

  /// 绘制缓慢流动的极光光带。
  void _paintAurora(Canvas canvas, Size size) {
    final double shortSide = size.shortestSide;

    for (final _AuroraBlob blob in _blobs) {
      final double t = progress * math.pi * 2 * blob.speed + blob.phase;
      final Offset center = Offset(
        size.width * blob.center.dx + math.sin(t) * size.width * blob.drift.dx,
        size.height * blob.center.dy +
            math.cos(t * 2) * size.height * blob.drift.dy,
      );
      final double radius = shortSide * blob.radius;

      final Shader shader = RadialGradient(
        colors: <Color>[
          blob.color.withValues(alpha: blob.opacity),
          blob.color.withValues(alpha: blob.opacity * 0.40),
          blob.color.withValues(alpha: 0.0),
        ],
        stops: const <double>[0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(blob.rotation + math.sin(t + blob.phase) * 0.10);
      canvas.scale(blob.stretchX, blob.stretchY);
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..shader = shader
          // screen 混合让光带叠加时自然提亮，接近真实的极光融合效果。
          ..blendMode = BlendMode.screen,
      );
      canvas.restore();
    }
  }

  /// 绘制闪烁星点。
  void _paintStars(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (final _Star star in _stars) {
      // abs(sin) 的周期为 π，配合整数倍进度可无缝循环。
      final double twinkle = math
          .sin((progress * 2 + star.phase) * math.pi * 2)
          .abs();
      final double alpha = star.brightness * (0.35 + 0.65 * twinkle);

      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  /// 四周暗角，让中心内容更聚焦。
  void _paintVignette(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Shader shader = RadialGradient(
      center: Alignment.center,
      radius: 1.15,
      colors: <Color>[Colors.transparent, Colors.black.withValues(alpha: 0.62)],
      stops: const <double>[0.50, 1.0],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
