import 'package:flutter/material.dart';

/// 原神角色数据模型。
///
/// 目前列表页只需要展示中英文名与元素主题色，
/// 后续的立绘、神之眼、命之座等信息可以继续在这里扩展字段。
@immutable
class Character {
  const Character({
    required this.enName,
    required this.zhName,
    required this.elementColor,
  });

  /// 英文名，用于列表左侧展示以及 A-Z 排序。
  final String enName;

  /// 中文名，用于列表右侧展示。
  final String zhName;

  /// 元素标准色，会在列表里转为 20% 透明度作为玻璃底色。
  final Color elementColor;
}
