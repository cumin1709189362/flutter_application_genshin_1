import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/character.dart';
import '../widgets/aurora_background.dart';

/// 角色详情页：以沉浸式长文阅读的方式展示角色背景故事。
class CharacterDetailPage extends StatefulWidget {
  const CharacterDetailPage({super.key, required this.character});

  /// 从角色列表页传入的角色数据。
  final Character character;

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  static const double _horizontalPadding = 24.0;
  static const double _topContentGap = 96.0;
  static const double _bottomContentGap = 48.0;

  late final Future<String> _storyFuture;

  @override
  void initState() {
    super.initState();
    _storyFuture = _loadStory();
  }

  Future<String> _loadStory() async {
    final String raw = await rootBundle.loadString(
      'assets/stories/${widget.character.zhName}.md',
    );
    return _cleanMarkdown(raw);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.paddingOf(context);
    final double topPadding = viewPadding.top + _topContentGap;
    final double bottomPadding = viewPadding.bottom + _bottomContentGap;

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
                        return _buildLoadingState();
                      }
                      if (snapshot.hasError) {
                        return _buildMessageState('故事未收录');
                      }

                      final String story = (snapshot.data ?? '').trim();
                      if (story.isEmpty) {
                        return _buildMessageState('故事未收录');
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          _horizontalPadding,
                          topPadding,
                          _horizontalPadding,
                          bottomPadding,
                        ),
                        child: Text(
                          story,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.8,
                            letterSpacing: 0.5,
                          ),
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

  Widget _buildLoadingState() {
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

  Widget _buildMessageState(String message) {
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

/// 简单的 Markdown 纯文本清洗。
///
/// 只处理故事文件中常见的标题、引用、列表、强调、代码围栏和链接等标记，
/// 保留段落文字与换行，避免引入额外的 Markdown 渲染依赖。
String _cleanMarkdown(String source) {
  String text = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // 代码围栏本身不展示，围栏内的文本保留。
  text = text.replaceAll(RegExp(r'```[^\n]*'), '');

  // 图片整体移除；普通链接只保留链接文字。
  text = text.replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), '');
  text = text.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]*\)'),
    (Match match) => match.group(1) ?? '',
  );

  // 常见 HTML 换行与标签。
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'<[^>]+>'), '');

  // 标题、引用（支持嵌套）、有序 / 无序列表。
  text = text.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '');
  text = text.replaceAll(RegExp(r'^\s{0,3}(?:>\s?)+', multiLine: true), '');
  text = text.replaceAll(
    RegExp(r'^\s{0,3}(?:[-*+]|\d+\.)\s+', multiLine: true),
    '',
  );

  // 水平分割线。
  text = text.replaceAll(
    RegExp(r'^\s{0,3}(?:[-*_]\s*){3,}$', multiLine: true),
    '',
  );

  // 剩余的行内强调、代码与标题符号。
  text = text.replaceAll(RegExp(r'[*_~`#]'), '');

  // 常见 HTML 实体。
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  // 清理行尾空白，并折叠过多的连续空行。
  text = text.replaceAll(RegExp(r'[ \t]+$', multiLine: true), '');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return text.trim();
}

/// 液态玻璃圆形返回按钮。
///
/// 按下缩放到 0.95，松开后弹回；毛玻璃背景上叠加半透明白色描边。
class _GlassBackButton extends StatefulWidget {
  const _GlassBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton> {
  static const double _size = 48.0;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '返回',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: Duration(milliseconds: _pressed ? 110 : 380),
          curve: _pressed ? Curves.easeOutCubic : Curves.elasticOut,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
