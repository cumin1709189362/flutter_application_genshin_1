import 'package:flutter/material.dart';

import '../models/character.dart';
import '../widgets/character_text_page.dart';

/// 角色语音页：展示 `assets/voices/<角色名>_语音.md`。
///
/// 正文与标题直接复用详情页的排版（[CharacterTextPage]），
/// 因此故事页与语音页的阅读观感完全一致。
class CharacterVoicePage extends StatelessWidget {
  const CharacterVoicePage({super.key, required this.character});

  final Character character;

  /// 旅行者语音稿里两位说话人的姓名颜色。
  ///
  /// 旅行者取岩元素标准色、派蒙取冰元素标准色（见 AGENTS.md 5.1）；
  /// 只染行首「旅行者：」「派蒙：」这几个字，正文中的同名文字仍是白色。
  static const Map<String, Color> _travelerSpeakerColors = <String, Color>{
    '旅行者': Color(0xFFCC9046), // 岩元素
    '派蒙': Color(0xFF35AACC), // 冰元素
  };

  @override
  Widget build(BuildContext context) {
    return CharacterTextPage(
      character: character,
      assetPath: character.voiceAssetPath,
      loadingLabel: '正在载入语音…',
      emptyLabel: '语音未收录',
      backButtonKey: const Key('character-voice-back-button'),
      // 空 / 荧共用同一份双人对话稿，需要突出说话人；其他角色传 null，
      // 渲染路径与改动前完全一致。
      speakerColors: character.isTraveler ? _travelerSpeakerColors : null,
    );
  }
}
