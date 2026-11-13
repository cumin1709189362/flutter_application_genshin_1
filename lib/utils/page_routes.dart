import 'package:flutter/material.dart';

/// 角色详情页、角色语音页共用的入场转场。
///
/// 新页面整体淡入，并从 0.92 放大到 1.0（620ms）；返回时 420ms 反向播放。
/// 角色列表 → 角色详情 → 角色语音三层使用同一套参数，过渡手感一致。
Route<void> characterPageRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 620),
    reverseTransitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final Animation<double> fadeIn = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      // 新页面从略小放大到全屏，和背后列表页的放大淡出叠在一起。
      final Animation<double> scaleIn = Tween<double>(
        begin: 0.92,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fadeIn,
        child: ScaleTransition(scale: scaleIn, child: child),
      );
    },
  );
}
