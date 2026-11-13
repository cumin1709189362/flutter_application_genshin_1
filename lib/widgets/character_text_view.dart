import 'package:flutter/material.dart';

/// 角色长文的排版规则。
///
/// 角色详情页（故事）与角色语音页共用这一套解析与样式，
/// 保证两处的标题、正文、分隔线与间距完全一致。
///
/// - 一级标题：角色名大标题，可通过 [titleAction] 在行尾挂一个控件；
/// - 二级及以下标题：分隔线 + 元素色章节标题；
/// - `解锁条件` / `来源页面` 行有各自的样式，其余按正文段落排版；
/// - 引用、列表、删除线等 Markdown 标记会被清洗成纯文本。
List<Widget> buildCharacterTextBlocks({
  required String raw,
  required Color elementColor,
  Widget? titleAction,
}) {
  final List<String> lines = raw
      .replaceFirst('\uFEFF', '')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');

  final List<Widget> blocks = <Widget>[];
  bool lastWasSpace = false;
  bool skipBlank = false;

  void addSpace() {
    if (skipBlank || blocks.isEmpty || lastWasSpace) {
      return;
    }
    blocks.add(const SizedBox(height: 16));
    lastWasSpace = true;
  }

  for (final String rawLine in lines) {
    if (_fencePattern.hasMatch(rawLine)) {
      continue;
    }
    if (_rulePattern.hasMatch(rawLine)) {
      addSpace();
      continue;
    }

    final RegExpMatch? heading = _headingPattern.firstMatch(rawLine);
    final int level = heading == null ? 0 : heading.group(1)!.length;
    String line = heading == null ? rawLine : heading.group(2)!;

    if (level == 0) {
      line = line.replaceFirst(_quotePattern, '');
      line = line.replaceFirst(_listPattern, '');
    }

    final String text = _stripInlineMarkdown(line);
    if (text.isEmpty) {
      addSpace();
      continue;
    }

    skipBlank = false;
    lastWasSpace = false;

    if (level == 1) {
      blocks.add(_buildCharacterName(text, elementColor, titleAction));
    } else if (level >= 2) {
      blocks.add(_buildDivider());
      blocks.add(_buildSectionTitle(_localizeStoryTitle(text), elementColor));

      // 角色故事标题与紧接其后的解锁条件之间不插入空行。
      if (_storyNumber(text) != null) {
        skipBlank = true;
      }
    } else if (text.startsWith('解锁条件')) {
      blocks.add(_buildUnlockCondition(text));
    } else if (text.startsWith('来源页面') || text.startsWith('来源：')) {
      blocks.add(_buildSourceLine(text));
    } else {
      blocks.add(_buildParagraph(text));
    }
  }

  if (blocks.isNotEmpty && blocks.last is SizedBox) {
    blocks.removeLast();
  }

  return blocks;
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

Widget _buildParagraph(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 16,
        height: 1.8,
        letterSpacing: 0.5,
      ),
    ),
  );
}

const String _dividerText = '-------------------------';

final RegExp _headingPattern = RegExp(r'^\s{0,3}(#{1,6})\s+(.*)$');
final RegExp _quotePattern = RegExp(r'^\s{0,3}(?:>\s?)+');
final RegExp _listPattern = RegExp(r'^\s{0,3}(?:[-*+]|\d+\.)\s+');
final RegExp _rulePattern = RegExp(r'^\s{0,3}(?:[-*_]\s*){3,}$');
final RegExp _fencePattern = RegExp(r'^\s*```');
final RegExp _storyPattern = RegExp(r'^角色故事\s*(\d{1,2})$');

String _stripInlineMarkdown(String text) {
  String value = text;

  value = value.replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), '');
  value = value.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]*\)'),
    (Match match) => match.group(1) ?? '',
  );
  value = value.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ');
  value = value.replaceAll(RegExp(r'<[^>]+>'), '');
  value = value.replaceAll(RegExp(r'[*_~`#]'), '');
  value = value
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  return value.trim();
}

int? _storyNumber(String text) {
  final RegExpMatch? match = _storyPattern.firstMatch(text);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

String _localizeStoryTitle(String text) {
  final int? number = _storyNumber(text);
  if (number == null) {
    return text;
  }
  return '角色故事${_numberToChinese(number)}';
}

String _numberToChinese(int number) {
  const List<String> numerals = <String>[
    '零',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
  ];

  if (number >= 0 && number < numerals.length) {
    return numerals[number];
  }
  return number.toString();
}
