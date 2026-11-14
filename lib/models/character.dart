import 'package:flutter/material.dart';

/// 原神角色数据模型。
///
/// 目前列表页只需要展示中英文名、元素主题色与元素图标，
/// 后续的立绘、神之眼、命之座等信息可以继续在这里扩展字段。
@immutable
class Character {
  const Character({
    required this.enName,
    required this.zhName,
    required this.elementColor,
    required this.elementIconPath,
  });

  /// 英文名，用于列表左侧展示以及 A-Z 排序。
  final String enName;

  /// 中文名，用于列表右侧展示。
  final String zhName;

  /// 元素标准色，会在列表里转为 20% 透明度作为玻璃底色。
  final Color elementColor;

  /// 元素图标的本地资源路径，例如 `assets/elements/anemo.png`。
  final String elementIconPath;

  /// 中文名与本地 Markdown 文件名不一致时的映射。
  ///
  /// - 「散兵」斯卡拉姆齐：故事与语音实际存放在 `流浪者.md` / `流浪者_语音.md`；
  /// - 空 / 荧：两位旅行者共用 `旅行者` 一份资源。
  ///
  /// 其余角色直接使用 `zhName` 作为文件名。
  static String _resolveAssetBaseName(String zhName) {
    switch (zhName) {
      case '「散兵」斯卡拉姆齐':
        return '流浪者';
      case '空':
      case '荧':
        return '旅行者';
      default:
        return zhName;
    }
  }

  /// 故事正文资源路径，例如 `assets/stories/胡桃.md`。
  ///
  /// 中文名两端若混入空格、制表符或换行，`rootBundle` 会直接抛
  /// Asset not found，所以这里统一 `trim()` 后再拼路径。
  String get storyAssetPath =>
      'assets/stories/${_resolveAssetBaseName(zhName.trim())}.md';

  /// 角色语音资源路径，例如 `assets/voices/胡桃_语音.md`。
  String get voiceAssetPath =>
      'assets/voices/${_resolveAssetBaseName(zhName.trim())}_语音.md';

  /// 是否共用「旅行者」这一份资源（空 / 荧）。
  ///
  /// 语音页据此决定要不要给台词里的「旅行者：」「派蒙：」染色：
  /// 只有这份双人对话稿需要突出说话人，其他角色的语音保持原样。
  bool get isTraveler => _resolveAssetBaseName(zhName.trim()) == '旅行者';
}
