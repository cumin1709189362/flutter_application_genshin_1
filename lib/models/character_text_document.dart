import 'package:flutter/foundation.dart';

/// 角色长文的「数据层」。
///
/// 详情页与语音页共用同一份 Markdown 解析规则，但这里只产出纯数据，
/// 不创建任何 Widget：页面可以先把整篇文档解析成 [CharacterTextBlock] 列表，
/// 再由 `ListView.builder` 按需把视口内的块渲染成 Widget。
/// 这样既避免在 `build()` 里重复做正则清洗，也让懒加载只发生在渲染阶段。
enum CharacterTextBlockKind {
  /// 一级标题：角色名大标题（详情页会在行尾挂「角色语音」入口）。
  characterName,

  /// 二级及以下标题：分隔线 + 元素色章节标题，视为同一块，避免被视口切开。
  sectionHeader,

  /// `解锁条件` 行。
  unlockCondition,

  /// `来源页面` / `来源：` 行。
  sourceLine,

  /// 普通正文段落。
  paragraph,
}

/// 一个排版块：只记录「画什么」与「和上一块之间要不要空一行」。
@immutable
class CharacterTextBlock {
  const CharacterTextBlock({
    required this.kind,
    required this.text,
    this.spaceBefore = false,
    this.speaker,
  });

  final CharacterTextBlockKind kind;

  /// 已完成 Markdown 清洗、可以直接展示的文本。
  final String text;

  /// 与上一块之间是否需要 16 的呼吸间距（对应旧实现的 `addSpace()`）。
  final bool spaceBefore;

  /// 台词行首的说话人姓名（不含冒号），例如语音稿里的「旅行者」「派蒙」。
  ///
  /// 只在整行以「姓名：」开头时记录；视图层据此只给「姓名：」这几个字染色，
  /// 正文中间出现的同名文字仍沿用普通正文样式。
  final String? speaker;
}

/// 整篇角色长文。
@immutable
class CharacterTextDocument {
  const CharacterTextDocument(this.blocks);

  /// 空文档（资源为空、或清洗后没有任何可展示内容）。
  static const CharacterTextDocument empty = CharacterTextDocument(
    <CharacterTextBlock>[],
  );

  final List<CharacterTextBlock> blocks;

  bool get isEmpty => blocks.isEmpty;
}

/// 把 Markdown 原文解析成排版块列表。
///
/// 规则与旧版 `buildCharacterTextBlocks` 完全一致：
/// - 一级标题对应角色名；二级及以下标题合并成「分隔线 + 章节标题」；
/// - `解锁条件` / `来源页面` / `来源：` 有各自样式，其余按正文处理；
/// - 引用、列表、删除线、链接等 Markdown 标记会被清洗成纯文本；
/// - 空行只在下一个块上留下一次 16px 间距，文档首块与末尾不留间距。
CharacterTextDocument parseCharacterTextDocument(String raw) {
  final List<String> lines = raw
      .replaceFirst('\uFEFF', '')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');

  final List<CharacterTextBlock> blocks = <CharacterTextBlock>[];
  bool lastWasSpace = false;
  bool skipBlank = false;
  bool pendingSpace = false;

  void addSpace() {
    if (skipBlank || blocks.isEmpty || lastWasSpace) {
      return;
    }
    pendingSpace = true;
    lastWasSpace = true;
  }

  void emit(CharacterTextBlockKind kind, String text, {String? speaker}) {
    blocks.add(
      CharacterTextBlock(
        kind: kind,
        text: text,
        spaceBefore: pendingSpace,
        speaker: speaker,
      ),
    );
    pendingSpace = false;
    lastWasSpace = false;
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
      emit(CharacterTextBlockKind.characterName, text);
    } else if (level >= 2) {
      emit(CharacterTextBlockKind.sectionHeader, _localizeStoryTitle(text));

      // 角色故事标题与紧接其后的解锁条件之间不插入空行。
      if (_storyNumber(text) != null) {
        skipBlank = true;
      }
    } else if (text.startsWith('解锁条件')) {
      emit(CharacterTextBlockKind.unlockCondition, text);
    } else if (text.startsWith('来源页面') || text.startsWith('来源：')) {
      emit(CharacterTextBlockKind.sourceLine, text);
    } else {
      // 语音稿的一句台词就是一段，行首的「姓名：」单独记下来，
      // 让视图层可以只给姓名染色而不必在 build() 里再切字符串。
      emit(
        CharacterTextBlockKind.paragraph,
        text,
        speaker: _speakerPattern.firstMatch(text)?.group(1),
      );
    }
  }

  if (blocks.isEmpty) {
    return CharacterTextDocument.empty;
  }
  return CharacterTextDocument(List<CharacterTextBlock>.unmodifiable(blocks));
}

final RegExp _headingPattern = RegExp(r'^\s{0,3}(#{1,6})\s+(.*)$');
final RegExp _quotePattern = RegExp(r'^\s{0,3}(?:>\s?)+');
final RegExp _listPattern = RegExp(r'^\s{0,3}(?:[-*+]|\d+\.)\s+');
final RegExp _rulePattern = RegExp(r'^\s{0,3}(?:[-*_]\s*){3,}$');
final RegExp _fencePattern = RegExp(r'^\s*```');
final RegExp _storyPattern = RegExp(r'^角色故事\s*(\d{1,2})$');

/// 台词行首的「姓名：」。
///
/// 只认 2–4 个汉字加全角冒号：人名太短会把「我：」这类正文误判成台词，
/// 太长又会把句子里的普通冒号（例如「来源页面：」）算进来。
final RegExp _speakerPattern = RegExp(r'^([\u4e00-\u9fa5]{2,4})：');

final RegExp _imagePattern = RegExp(r'!\[[^\]]*\]\([^)]*\)');
final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]\([^)]*\)');
final RegExp _breakPattern = RegExp(r'<br\s*/?>', caseSensitive: false);
final RegExp _htmlTagPattern = RegExp(r'<[^>]+>');
final RegExp _emphasisPattern = RegExp(r'[*_~`#]');

String _stripInlineMarkdown(String text) {
  String value = text;

  value = value.replaceAll(_imagePattern, '');
  value = value.replaceAllMapped(
    _linkPattern,
    (Match match) => match.group(1) ?? '',
  );
  value = value.replaceAll(_breakPattern, ' ');
  value = value.replaceAll(_htmlTagPattern, '');
  value = value.replaceAll(_emphasisPattern, '');
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
