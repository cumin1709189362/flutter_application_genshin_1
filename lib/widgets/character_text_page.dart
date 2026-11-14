import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/character.dart';
import '../models/character_text_document.dart';
import '../widgets/aurora_background.dart';
import '../widgets/character_text_view.dart';
import '../widgets/solid_gradient_button.dart';

/// 角色长文阅读页的公共骨架：角色详情页与角色语音页共用。
///
/// 两页只有资源路径、“正在载入 / 未收录”文案、返回按钮 Key 以及
/// 标题行右侧的附加控件不同；加载、空态、滚动与排版全部复用这里，
/// 保证语音页与故事页的观感完全一致。
///
/// 正文渲染分三段：这里负责读取资源并在转场结束后解析成
/// [CharacterTextDocument]，由 [CharacterTextView] 用 `ListView.builder`
/// 只构建视口附近的文本块，因此页面再长也不会一次性布局整篇内容。
class CharacterTextPage extends StatefulWidget {
  const CharacterTextPage({
    super.key,
    required this.character,
    required this.assetPath,
    required this.loadingLabel,
    required this.emptyLabel,
    required this.backButtonKey,
    this.titleAction,
    this.speakerColors,
  });

  /// 当前角色，提供元素主题色与中文名（用于资源排查日志）。
  final Character character;

  /// 要读取的 Markdown 资源路径，例如 `assets/stories/胡桃.md`。
  final String assetPath;

  /// 加载过程中显示的文案。
  final String loadingLabel;

  /// 资源缺失或内容为空时显示的文案。
  final String emptyLabel;

  /// 左上角返回按钮的 Key，方便测试与调试定位。
  final Key backButtonKey;

  /// 一级标题行右侧的附加控件（详情页放语音入口，语音页为 null）。
  final Widget? titleAction;

  /// 台词说话人的姓名颜色（见 [CharacterTextView.speakerColors]）。
  ///
  /// 默认 null：故事页与此前完全一致；只有双人对话稿（旅行者语音）会传入。
  final Map<String, Color>? speakerColors;

  @override
  State<CharacterTextPage> createState() => _CharacterTextPageState();
}

class _CharacterTextPageState extends State<CharacterTextPage> {
  static const double _horizontalPadding = 24;
  static const double _topContentGap = 96;
  static const double _bottomContentGap = 48;

  /// 让上一页的 620ms 转场先完成，再回到 UI Thread 解析长文本。
  static const Duration _deferParsingDuration = Duration(milliseconds: 650);

  late final Future<CharacterTextDocument> _documentFuture;

  @override
  void initState() {
    super.initState();
    _documentFuture = _loadDocument(widget.assetPath);
  }

  Future<CharacterTextDocument> _loadDocument(String assetPath) async {
    try {
      final String raw = await rootBundle.loadString(assetPath);

      // 文件读取本身是异步 I/O；这里再等转场结束，
      // 避免在 PageRouteBuilder 动画期间做正则清洗和文档解析。
      await Future<void>.delayed(_deferParsingDuration);
      return parseCharacterTextDocument(raw);
    } catch (e, stackTrace) {
      debugPrint('加载失败: $e');
      debugPrint('尝试读取的资源路径: $assetPath');
      debugPrintStack(stackTrace: stackTrace);

      // 进一步区分“文件不存在”和“文件存在但没被打进包”。
      await _logAssetManifest(assetPath);
      rethrow;
    }
  }

  /// Debug 用：把资源清单里同一目录下的条目打出来。
  ///
  /// 如果这里显示 `contains = false`，说明资源没进构建产物
  /// （新增文件后没有重新打包），而不是 Dart 路径写错。
  Future<void> _logAssetManifest(String assetPath) async {
    try {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
        rootBundle,
      );
      final int slash = assetPath.lastIndexOf('/');
      final String dir = slash < 0 ? '' : assetPath.substring(0, slash + 1);
      final List<String> entries =
          manifest
              .listAssets()
              .where((String key) => key.startsWith(dir))
              .toList()
            ..sort();

      final bool contained = entries.contains(assetPath);
      debugPrint(
        'AssetManifest: $dir 共 ${entries.length} 个条目，'
        '包含 $assetPath = $contained',
      );

      if (!contained) {
        final String name = widget.character.zhName.trim();
        final List<String> similar = entries
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
              child: FutureBuilder<CharacterTextDocument>(
                future: _documentFuture,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<CharacterTextDocument> snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoading();
                      }

                      final CharacterTextDocument? document = snapshot.data;
                      if (snapshot.hasError ||
                          document == null ||
                          document.isEmpty) {
                        return _buildMessage(widget.emptyLabel);
                      }

                      return CharacterTextView(
                        document: document,
                        elementColor: widget.character.elementColor,
                        titleAction: widget.titleAction,
                        speakerColors: widget.speakerColors,
                        listKey: const Key('character-text-list'),
                        padding: EdgeInsets.fromLTRB(
                          _horizontalPadding,
                          safe.top + _topContentGap,
                          _horizontalPadding,
                          safe.bottom + _bottomContentGap,
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
                    key: widget.backButtonKey,
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
            widget.loadingLabel,
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
