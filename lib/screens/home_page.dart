import 'package:flutter/material.dart';

import '../widgets/aurora_background.dart';
import '../widgets/glass_button.dart';
import 'catalog_page.dart';

/// 首页：极光背景 + 发光标题 + 液态玻璃箭头按钮。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const Duration _transitionDuration = Duration(milliseconds: 620);

  /// 驱动“当前页整体向左滑出”的本地动画。
  late final AnimationController _exitController;

  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    _exitController = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    );
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  void _openCatalog() {
    if (_isLeaving) {
      return;
    }
    _isLeaving = true;

    // 首页整体向左加速滑出；easeIn 让速度由慢到快。
    _exitController.forward();

    // 使用 pushReplacement：目录页替换首页，不保留返回首页的历史。
    Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        transitionDuration: _transitionDuration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CatalogPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 目录页从右侧同步滑入，与首页的向左滑出拼成一整条“推进”转场。
          final Animation<Offset> slideIn = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

          // 当角色列表页压栈时（secondaryAnimation 0 → 1），
          // 目录页放大至全屏并逐渐淡出；配合新页面的淡入完成转场。
          final Animation<double> scaleUp = Tween<double>(begin: 1.0, end: 1.18)
              .animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInOutCubic,
                ),
              );
          final Animation<double> fadeOut = Tween<double>(begin: 1.0, end: 0.0)
              .animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInOut,
                ),
              );

          return SlideTransition(
            position: slideIn,
            child: ScaleTransition(
              scale: scaleUp,
              child: FadeTransition(opacity: fadeOut, child: child),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double titleSize = (screenWidth * 0.082).clamp(28.0, 44.0).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SlideTransition(
        position:
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1.0, 0.0),
            ).animate(
              CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
            ),
        child: AuroraBackground(
          child: SafeArea(
            child: Align(
              // 居中偏上。
              alignment: const Alignment(0.0, -0.16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Genshin Impact Characters',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w300,
                        height: 1.2,
                        letterSpacing: 1.5,
                        shadows: <Shadow>[
                          // 大半径白色辉光，让标题像悬浮在极光里。
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.85),
                            blurRadius: 32,
                          ),
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.45),
                            blurRadius: 64,
                          ),
                          Shadow(
                            color: const Color(0xFF7FB6FF)
                                .withValues(alpha: 0.35),
                            blurRadius: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 42),
                  GlassButton(
                    onTap: _openCatalog,
                    width: 92,
                    height: 52,
                    borderRadius: 26,
                    padding: EdgeInsets.zero,
                    child: const Center(
                      child: Text(
                        '→',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
