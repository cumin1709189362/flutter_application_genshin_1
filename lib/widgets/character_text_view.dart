import 'package:flutter/material.dart';

import '../models/character_text_document.dart';

/// 角色长文的排版与懒加载渲染。
///
/// 解析结果由 [CharacterTextDocument] 提供，这里只负责：
/// - 把每个 [CharacterTextBlock] 按既有样式渲染成一个 Widget；
/// - 用 [ListView.builder] 只构建视口附近的块，长文滚动时不再整篇布局。
///
/// 样式规则（与旧版完全一致）：
/// - 一级标题：角色名大标题，可通过 [titleAction] 在行尾挂一个控件；
/// - 二级及以下标题：分隔线 + 元素色章节标题；
/// - `解锁条件` / `来源页面` 行有各自的样式，其余按正文段落排版；
/// - 正文段落可通过 [speakerColors] 给行首「姓名：」单独染色。
class CharacterTextView extends StatelessWidget {
  const CharacterTextView({
    super.key,
    required this.document,
    required this.elementColor,
    required this.padding,
    this.titleAction,
    this.listKey,
    this.speakerColors,
  });

  /// 已解析好的整篇文档，只读。
  final CharacterTextDocument document;

  /// 元素主题色，用于标题阴影与章节标题染色。
  final Color elementColor;

  /// 滚动区域的内边距（由页面按安全区与呼吸间距计算）。
  final EdgeInsetsGeometry padding;

  /// 一级标题行右侧的附加控件（详情页放语音入口，语音页为 null）。
  final Widget? titleAction;

  /// 交给测试与调试定位的列表 Key。
  final Key? listKey;

  /// 说话人姓名到姓名颜色的映射。
  ///
  /// 只有显式传入时才生效（当前仅旅行者语音页）：命中的段落会把行首的
  /// 「姓名：」拆成独立 [TextSpan] 染色，其余文字与所有未命中的段落
  /// 仍沿用原来的单 [Text] 渲染，正文里再次出现的同名文字不会被染色。
  final Map<String, Color>? speakerColors;

  /// 块与块之间的呼吸间距（旧实现里 `addSpace()` 插入的 SizedBox 高度）。
  static const double _blockGap = 16;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: listKey,
      padding: padding,
      // 正文块全部是无状态文本，不需要保活；
      // 每项自带独立重绘边界，滚动时只重绘新进入视口的块。
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: document.blocks.length,
      itemBuilder: (BuildContext context, int index) {
        final CharacterTextBlock block = document.blocks[index];

        Widget child = _buildBlock(block);
        if (block.spaceBefore) {
          child = Padding(
            padding: const EdgeInsets.only(top: _blockGap),
            child: child,
          );
        }

        // 旧实现是 Column(crossAxisAlignment: stretch)，每个块都被拉满宽度。
        // ListView 的子项只拿到最大宽度，补一个全宽约束才能让居中分隔线
        // 继续居中、让标题行的 Expanded 继续正确分配剩余宽度。
        return SizedBox(width: double.infinity, child: child);
      },
    );
  }

  Widget _buildBlock(CharacterTextBlock block) {
    switch (block.kind) {
      case CharacterTextBlockKind.characterName:
        return _buildCharacterName(block.text, elementColor, titleAction);
      case CharacterTextBlockKind.sectionHeader:
        return _buildSectionHeader(block.text, elementColor);
      case CharacterTextBlockKind.unlockCondition:
        return _buildUnlockCondition(block.text);
      case CharacterTextBlockKind.sourceLine:
        return _buildSourceLine(block.text);
      case CharacterTextBlockKind.paragraph:
        return _buildParagraph(block, speakerColors);
    }
  }
}

Widget _buildCharacterName(
  String text,
  Color elementColor,
  Widget? titleAction,
) {
  final Widget title = Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: 4,
      shadows: <Shadow>[
        Shadow(color: elementColor.withValues(alpha: 0.45), blurRadius: 24),
      ],
    ),
  );

  // 没有附加控件时保持原来的单 Text 布局；
  // 有附加控件时把标题放进 Expanded，让入口按钮始终贴住内容右边框。
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: titleAction == null
        ? title
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: title),
              const SizedBox(width: 12),
              titleAction,
            ],
          ),
  );
}

/// 分隔线 + 章节标题合并成同一块，保证它们不会被视口边缘切成两半。
Widget _buildSectionHeader(String text, Color elementColor) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[_buildDivider(), _buildSectionTitle(text, elementColor)],
  );
}

Widget _buildDivider() {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Text(
      _dividerText,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey.withValues(alpha: 0.5),
        fontSize: 12,
        height: 1.0,
        letterSpacing: 1.2,
      ),
    ),
  );
}

Widget _buildSectionTitle(String text, Color elementColor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        color: Color.lerp(Colors.white, elementColor, 0.35),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 2,
        shadows: <Shadow>[
          Shadow(color: elementColor.withValues(alpha: 0.38), blurRadius: 18),
        ],
      ),
    ),
  );
}

Widget _buildUnlockCondition(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 2, bottom: 14),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        height: 1.5,
        letterSpacing: 0.6,
      ),
    ),
  );
}

Widget _buildSourceLine(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 11,
        height: 1.5,
        letterSpacing: 0.3,
      ),
    ),
  );
}

Widget _buildParagraph(
  CharacterTextBlock block,
  Map<String, Color>? speakerColors,
) {
  final TextStyle style = TextStyle(
    color: Colors.white.withValues(alpha: 0.9),
    fontSize: 16,
    height: 1.8,
    letterSpacing: 0.5,
  );

  final String? speaker = block.speaker;
  final Color? speakerColor = speaker == null ? null : speakerColors?[speaker];

  // 未命中染色配置时保持原来的单 Text（故事页与其他语音页因此完全不变）；
  // 命中时只把行首的「姓名：」（含全角冒号）换成角色色，
  // 正文里再次出现的同名文字仍继承段落样式里的白色。
  if (speaker != null && speakerColor != null) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$speaker：',
              style: TextStyle(color: speakerColor),
            ),
            TextSpan(text: block.text.substring(speaker.length + 1)),
          ],
        ),
        style: style,
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(block.text, style: style),
  );
}

const String _dividerText = '-------------------------';
