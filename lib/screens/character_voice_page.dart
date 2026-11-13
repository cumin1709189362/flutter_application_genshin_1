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

  @override
  Widget build(BuildContext context) {
    return CharacterTextPage(
      character: character,
      assetPath: character.voiceAssetPath,
      loadingLabel: '正在载入语音…',
      emptyLabel: '语音未收录',
      backButtonKey: const Key('character-voice-back-button'),
    );
  }
}
