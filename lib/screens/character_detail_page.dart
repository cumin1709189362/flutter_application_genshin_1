import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/character.dart';
import '../widgets/aurora_background.dart';
import '../widgets/solid_gradient_button.dart';

/// 角色详情页：以沉浸式长文阅读的方式展示角色背景故事。
class CharacterDetailPage extends StatefulWidget {
  const CharacterDetailPage({super.key, required this.character});

  final Character character;

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  static const double _horizontalPadding = 24;
  static const double _topContentGap = 96;
  static const double _bottomContentGap = 48;
  static const String _dividerText = '-------------------------';

  /// 让列表页的 620ms 转场先完成，再回到 UI Thread 解析长文本。
  static const Duration _deferParsingDuration = Duration(milliseconds: 650);

  /// 故事 Markdown 所在目录，必须与 pubspec.yaml 中声明的 assets 目录一致。
  static const String _storyAssetDir = 'assets/stories/';

  /// 本次实际读取的资源路径，例如 `assets/stories/米提亚.md`。
  ///
  /// 中文名两端若混入空格、制表符或换行，`rootBundle` 会直接抛
  /// Asset not found，所以这里统一 `trim()` 后再拼路径。
  late final String _storyAssetPath;

  late final Future<String> _storyFuture;

  @override
  void initState() {
    super.initState();
    _storyAssetPath = '$_storyAssetDir${widget.character.zhName.trim()}.md';
    _storyFuture = _loadStory(_storyAssetPath);
  }

  Future<String> _loadStory(String assetPath) async {
    try {
      final String raw = await rootBundle.loadString(assetPath);

      // 文件读取本身是异步 I/O；这里再等转场结束，
      // 避免在 PageRouteBuilder 动画期间做正则清洗和 Widget 列表构建。
      await Future<void>.delayed(_deferParsingDuration);
      return raw;
    } catch (e, stackTrace) {
      debugPrint('加载失败: $e');
      debugPrint('尝试读取的资源路径: $assetPath');
      debugPrintStack(stackTrace: stackTrace);

      // 进一步区分“文件不存在”和“文件存在但没被打进包”。
      await _logStoryManifest(assetPath);
      rethrow;
    }
  }

  /// Debug 用：把资源清单里 `assets/stories/` 下的条目打出来。
  ///
  /// 如果这里显示 `contains = false`，说明资源没进构建产物
  /// （新增文件后没有重新打包），而不是 Dart 路径写错。
  Future<void> _logStoryManifest(String assetPath) async {
    try {
      final AssetManifest manifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> stories = manifest
          .listAssets()
          .where((String key) => key.startsWith(_storyAssetDir))
          .toList()
        ..sort();

      final bool contained = stories.contains(assetPath);
      debugPrint(
        'AssetManifest: assets/stories/ 共 ${stories.length} 个条目，'
        '包含 $assetPath = $contained',
      );

      if (!contained) {
        final String name = widget.character.zhName.trim();
        final List<String> similar = stories
            .where((String key) => key.contains(name))
            .toList();
        debugPrint(
          similar.isEmpty
              ? '清单中没有任何名称含「$name」的资源，多为新增资源未重新打包。'
              : '清单中存在相似资源: $similar',
        );
      }
    } catch (e) {
      debugPrint('读取 AssetManifest 失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AuroraBackground(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: FutureBuilder<String>(
                future: _storyFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoading();
                      }
                      if (snapshot.hasError) {
                        return _buildMessage('故事未收录');
                      }

                      final String raw = snapshot.data ?? '';
                      if (raw.trim().isEmpty) {
                        return _buildMessage('故事未收录');
                      }

                      final List<Widget> blocks = _buildBlocks(raw);
                      if (blocks.isEmpty) {
                        return _buildMessage('故事未收录');
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          _horizontalPadding,
                          safe.top + _topContentGap,
                          _horizontalPadding,
                          safe.bottom + _bottomContentGap,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: blocks,
                        ),
                      );
                    },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _GlassBackButton(
                    key: const Key('character-detail-back-button'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBlocks(String raw) {
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
        blocks.add(_buildCharacterName(text));
      } else if (level >= 2) {
        blocks.add(_buildDivider());
        blocks.add(_buildSectionTitle(_localizeStoryTitle(text)));

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

  Widget _buildCharacterName(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w400,
          height: 1.3,
          letterSpacing: 4,
          shadows: <Shadow>[
            Shadow(
              color: widget.character.elementColor.withValues(alpha: 0.45),
              blurRadius: 24,
            ),
          ],
        ),
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

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Color.lerp(Colors.white, widget.character.elementColor, 0.35),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.35,
          letterSpacing: 2,
          shadows: <Shadow>[
            Shadow(
              color: widget.character.elementColor.withValues(alpha: 0.38),
              blurRadius: 18,
            ),
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

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: 2,
            color: widget.character.elementColor,
          ),
          const SizedBox(height: 18),
          Text(
            '正在载入故事…',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.menu_book_outlined,
            color: Colors.white.withValues(alpha: 0.35),
            size: 34,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 15,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

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

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: SolidGradientButton(
        onTap: onTap,
        semanticLabel: '返回',
        borderRadius: 24,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        borderColor: Colors.white.withValues(alpha: 0.6),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}
