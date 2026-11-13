import 'package:flutter/material.dart';

import '../models/character.dart';
import '../utils/page_routes.dart';
import '../widgets/character_text_page.dart';
import '../widgets/solid_gradient_button.dart';
import 'character_voice_page.dart';

/// 角色详情页：以沉浸式长文阅读的方式展示角色背景故事。
///
/// 正文排版、加载与返回按钮由 [CharacterTextPage] 提供，
/// 这里只负责故事资源路径与标题行右侧的「角色语音」入口。
class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return CharacterTextPage(
      character: character,
      assetPath: character.storyAssetPath,
      loadingLabel: '正在载入故事…',
      emptyLabel: '故事未收录',
      backButtonKey: const Key('character-detail-back-button'),
      titleAction: _VoiceEntryButton(character: character),
    );
  }
}

/// 一级标题行右侧的「角色语音」入口。
///
/// 材质与角色列表按钮一致：半透明元素色填充 + 60% 元素色描边 +
/// 按下 0.95 缩放；高度与大标题行高（30 × 1.3 ≈ 39）齐平。
class _VoiceEntryButton extends StatelessWidget {
  const _VoiceEntryButton({required this.character});

  final Character character;

  static const double _height = 40;
  static const double _borderRadius = 20;

  /// 进入角色语音页，转场与列表页进入详情页完全一致。
  void _openVoice(BuildContext context) {
    // 转场进行中时防止重复推入页面。
    final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);
    if (currentRoute != null && !currentRoute.isCurrent) {
      return;
    }

    final Widget page = CharacterVoicePage(character: character);
    Navigator.of(context).push<void>(characterPageRoute(page));
  }

  @override
  Widget build(BuildContext context) {
    return SolidGradientButton(
      key: const Key('character-voice-entry-button'),
      onTap: () => _openVoice(context),
      semanticLabel: '${character.zhName} 角色语音',
      height: _height,
      borderRadius: _borderRadius,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: character.elementColor,
      borderColor: character.elementColor.withValues(alpha: 0.6),
      child: const Center(
        widthFactor: 1,
        child: Text(
          '角色语音→',
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
