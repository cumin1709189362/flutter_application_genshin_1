import 'package:flutter/material.dart';

import '../models/character.dart';

/// 角色详情页（占位）。
///
/// 目前只展示纯黑背景与角色中英文名，AppBar 保持透明并保留白色返回按钮。
/// 后续会在这里加入角色立绘、元素、命之座等详细信息。
class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({super.key, required this.character});

  /// 从角色列表页传入的角色数据。
  final Character character;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 让内容区域延伸到 AppBar 之下，中英文名可以在整屏内真正居中。
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                character.zhName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                character.enName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                  letterSpacing: 6,
                ),
              ),
              // TODO: 以后在这里添加角色立绘和详细信息。
            ],
          ),
        ),
      ),
    );
  }
}
