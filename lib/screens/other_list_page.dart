import 'package:flutter/material.dart';

import '../models/character.dart';
import '../widgets/aurora_background.dart';
import '../widgets/solid_gradient_button.dart';
import 'character_detail_page.dart';

/// 特殊角色列表页。
///
/// 全屏极光背景 + 悬浮半透明表头，内容区由若干个分组纵向排列：
/// 愚人众执行官（11 位）、天理四影（4 位）、坎瑞亚五大罪人（5 位）。
///
/// 所有分组共用一个 [ListView] 顺序构建，避免嵌套滚动引发的物理冲突；
/// 按键尺寸、圆角、按压反馈与转场动画均与角色列表页保持一致。
class OtherListPage extends StatelessWidget {
  const OtherListPage({super.key});

  /// 悬浮玻璃表头内容区的高度（不含状态栏安全区）。
  static const double _headerHeight = 64.0;

  /// 列表顶部与表头底部之间的呼吸间距。
  static const double _headerListGap = 8.0;

  /// 分组之间的间距：上一个分组的最后一个按钮 → 下一个分组的标题。
  static const double _sectionGap = 32.0;

  /// 同一分组内相邻按钮之间的间距。
  static const double _buttonGap = 16.0;

  /// 分组名录，按展示顺序排列。
  ///
  /// 每个分组自带左侧标题与组前间距，因此新增模块只需往这里追加一项。
  static const List<_OtherSection> _sections = <_OtherSection>[
    // 旅行者放在最顶部；空 / 荧共用 `assets/stories/旅行者.md`，
    // 详情页里的文件名映射负责把这两个中文名指向同一份剧情。
    _OtherSection(
      title: '旅行者',
      entries: <_OtherEntry>[
        _OtherEntry(
          character: Character(
            enName: 'Aether',
            zhName: '空',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '空',
          // 中文名右侧的「始基力」图标；尺寸由 _ElementIcon 内部固定。
          iconPath: 'assets/elements/stellar_linchpin.png',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Lumine',
            zhName: '荧',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '荧',
          iconPath: 'assets/elements/stellar_linchpin.png',
        ),
      ],
    ),
    _OtherSection(
      title: '愚人众执行官',
      entries: <_OtherEntry>[
        _OtherEntry(
          character: Character(
            enName: 'Pierro',
            zhName: '皮耶罗',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「丑角」皮耶罗',
          title: '统括官',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Il Capitano',
            zhName: '卡皮塔诺',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「队长」卡皮塔诺',
          title: '第一席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Il Dottore',
            zhName: '多托雷',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「博士」多托雷',
          title: '第二席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Columbina',
            zhName: '哥伦比娅',
            elementColor: Color(0xFF498FCC), // 水元素
            elementIconPath: '',
          ),
          displayName: '「少女」哥伦比娅',
          title: '第三席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Arlecchino',
            zhName: '阿蕾奇诺',
            elementColor: Color(0xFFEC4923), // 火元素
            elementIconPath: '',
          ),
          displayName: '「仆人」阿蕾奇诺',
          title: '第四席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Pulcinella',
            zhName: '普契涅拉',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「公鸡」普契涅拉',
          title: '第五席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Scaramouche',
            zhName: '「散兵」斯卡拉姆齐',
            elementColor: Color(0xFF359697), // 风元素
            elementIconPath: '',
          ),
          displayName: '「散兵」斯卡拉姆齐',
          title: '第六席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Sandrone',
            zhName: '桑多涅',
            elementColor: Color(0xFF35AACC), // 冰元素
            elementIconPath: '',
          ),
          displayName: '「木偶」桑多涅',
          title: '第七席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'La Signora',
            zhName: '席诺拉',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「女士」席诺拉',
          title: '第八席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Pantalone',
            zhName: '潘塔罗涅',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「富人」潘塔罗涅',
          title: '第九席',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Tartaglia',
            zhName: '达达利亚',
            elementColor: Color(0xFF498FCC), // 水元素
            elementIconPath: '',
          ),
          displayName: '「公子」达达利亚',
          title: '末席',
        ),
      ],
    ),
    _OtherSection(
      title: '天理四影',
      entries: <_OtherEntry>[
        _OtherEntry(
          character: Character(
            enName: 'Naberius',
            zhName: '纳贝里士',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '纳贝里士',
          title: '生之执政',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Ronova',
            zhName: '若娜瓦',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '若娜瓦',
          title: '死之执政',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Istaroth',
            zhName: '伊斯塔露',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '伊斯塔露',
          title: '时之执政',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Asmoday',
            zhName: '阿斯莫代',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '阿斯莫代',
          title: '空之执政',
        ),
      ],
    ),
    // 罪人按钮没有称号，`title` 留空即自动切换为单行排版（尺寸不变）；
    // 代号直接写进 `zhName` / `displayName`，与「散兵」的写法一致。
    _OtherSection(
      title: '坎瑞亚五大罪人',
      entries: <_OtherEntry>[
        _OtherEntry(
          character: Character(
            enName: 'Hroptatyr',
            zhName: '「贤者」海洛塔帝',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「贤者」海洛塔帝',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Vedrfolnir',
            zhName: '「预言家」维瑟弗尼尔',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「预言家」维瑟弗尼尔',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Rhinedottir',
            zhName: '「黄金」莱茵多特',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「黄金」莱茵多特',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Surtalogi',
            zhName: '「极恶骑」苏尔特洛奇',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「极恶骑」苏尔特洛奇',
        ),
        _OtherEntry(
          character: Character(
            enName: 'Rerir',
            zhName: '「猎月人」雷利尔',
            elementColor: Colors.grey,
            elementIconPath: '',
          ),
          displayName: '「猎月人」雷利尔',
        ),
      ],
    ),
  ];

  /// 全部条目的总数，用于表头右侧的“N 位”。
  static int get _totalCount {
    return _sections.fold<int>(
      0,
      (int sum, _OtherSection section) => sum + section.entries.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final double topInset = padding.top;
    final double bottomInset = padding.bottom;
    final double listTopPadding = topInset + _headerHeight + _headerListGap;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AuroraBackground(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ListView(
                // 内容不足一屏时也保留下拉回弹。
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // 顶部避让悬浮表头，左右与角色列表页保持一致。
                padding: EdgeInsets.fromLTRB(
                  16 + padding.left,
                  listTopPadding,
                  16 + padding.right,
                  16 + bottomInset,
                ),
                children: <Widget>[
                  for (int index = 0; index < _sections.length; index++)
                    _buildSection(
                      context,
                      _sections[index],
                      isFirst: index == 0,
                    ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(context, _totalCount),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建一个分组：可选的上方间距 + 左对齐标题 + 一组按键。
  Widget _buildSection(
    BuildContext context,
    _OtherSection section, {
    required bool isFirst,
  }) {
    final int lastIndex = section.entries.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!isFirst) const SizedBox(height: _sectionGap),
        _SectionTitle(
          text: section.title,
          padding: EdgeInsets.only(left: 4, top: isFirst ? 4 : 0, bottom: 8),
        ),
        for (int index = 0; index <= lastIndex; index++)
          Padding(
            // 与角色列表页一致：水平 16 由列表 padding 提供，这里只管垂直间距。
            // 最后一个按钮不留底部间距，保证分组间正好是 32.0。
            padding: EdgeInsets.only(
              bottom: index == lastIndex ? 0 : _buttonGap,
            ),
            child: _OtherEntryButton(
              entry: section.entries[index],
              onTap: () => _openCharacterDetail(
                context,
                section.entries[index].character,
              ),
            ),
          ),
      ],
    );
  }

  /// 进入角色详情页。
  ///
  /// 与角色列表页完全一致：详情页整体淡入，并从 0.92 放大到 1.0；
  /// 当前列表页由 CatalogPage 的 secondaryAnimation 负责放大淡出。
  void _openCharacterDetail(BuildContext context, Character character) {
    // 转场进行中时防止重复推入页面。
    final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);
    if (currentRoute != null && !currentRoute.isCurrent) {
      return;
    }

    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 620),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CharacterDetailPage(character: character);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Animation<double> fadeIn = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          // 详情页从略小放大到全屏，和背后列表页的放大淡出叠在一起。
          final Animation<double> scaleIn = Tween<double>(begin: 0.92, end: 1.0)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: fadeIn,
            child: ScaleTransition(scale: scaleIn, child: child),
          );
        },
      ),
    );
  }

  /// 悬浮半透明表头：返回按钮 + 标题 + 数量，与角色列表页完全一致。
  Widget _buildHeader(BuildContext context, int characterCount) {
    return Listener(
      // 表头是悬浮层，吸收空白区域的点击，避免误触到被遮住的列表。
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: _headerHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 20, 0),
              child: Row(
                children: <Widget>[
                  _HeaderBackButton(
                    key: const Key('other-list-back-button'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '特殊角色',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                            letterSpacing: 4,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.45),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '角色列表',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.52),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 数量由数据源动态计算，当前四个分组共 22 位。
                  Text(
                    '$characterCount 位',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 页面中的一个分组：标题 + 按顺序排列的条目。
class _OtherSection {
  const _OtherSection({required this.title, required this.entries});

  /// 左侧对齐的分组标题，例如“天理四影”。
  final String title;

  /// 分组内的角色条目。
  final List<_OtherEntry> entries;
}

/// 特殊角色条目数据。
class _OtherEntry {
  const _OtherEntry({
    required this.character,
    required this.displayName,
    this.title,
    this.iconPath,
  });

  /// 传给详情页的角色对象，`zhName` 用于拼接故事资源路径。
  final Character character;

  /// 按钮上展示的中文名，可带「代号」，例如「博士」多托雷。
  final String displayName;

  /// 职位 / 席位 / 称号，显示在按钮右侧下方。
  ///
  /// 为 `null` 时按钮只渲染一行中文名（没有副标题），尺寸保持不变。
  final String? title;

  /// 单行排版时紧跟在中文名右侧的图标，例如旅行者的「始基力」。
  ///
  /// 为 `null` 表示不显示图标；图标始终以 24 的固定方块参与布局，
  /// 不会把按钮撑高。
  final String? iconPath;

  /// 是否只显示一行中文名。
  bool get isSingleLine => title == null;
}

/// 分组标题：左对齐的白色粗体文字。
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    this.padding = const EdgeInsets.only(left: 4, bottom: 8),
  });

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 2,
          shadows: <Shadow>[
            // Colors.white.withValues(alpha: 0.35) 的等价常量，便于写成 const。
            Shadow(color: Color(0x59FFFFFF), blurRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// 特殊角色长矩形按键。
///
/// 尺寸、圆角、按压 0.95 缩放统一交给 [SolidGradientButton]，
/// 与角色列表页的按钮保持完全一致的交互反馈。
///
/// 两种排版（两行 / 单行）共用同一套尺寸参数——圆角 22、
/// 内边距 20、最小高度 64——与 CharacterListPage 的普通角色按钮逐项一致，
/// 单行文字不再单独压缩高度。
class _OtherEntryButton extends StatelessWidget {
  const _OtherEntryButton({required this.entry, required this.onTap});

  final _OtherEntry entry;
  final VoidCallback onTap;

  /// 左侧英文名的统一样式。
  static const TextStyle _enStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 1.2,
  );

  /// 右侧中文名的统一样式。
  static const TextStyle _zhStyle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 2.0,
  );

  /// 右侧小字号灰色称号。
  static TextStyle get _titleStyle => TextStyle(
    color: Colors.grey.shade400,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    final Color accent = entry.character.elementColor;
    final bool singleLine = entry.isSingleLine;

    return SolidGradientButton(
      onTap: onTap,
      semanticLabel: singleLine
          ? '${entry.displayName} ${entry.character.enName}'
          : '${entry.displayName} ${entry.character.enName} ${entry.title}',
      // 以下三项与 CharacterListPage 的 _CharacterButton 完全一致；
      // 所有条目（含旅行者）都用同一套尺寸，不会被内部图标撑大。
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 64),
      // 元素色统一走 Character.elementColor：
      // 桑多涅 = 冰、阿蕾奇诺 = 火、哥伦比娅 = 水，其余为灰色。
      backgroundColor: accent,
      backgroundOpacity: 0.35,
      borderColor: accent.withValues(alpha: 0.6),
      child: singleLine ? _buildSingleLineRow() : _buildTwoLineRow(),
    );
  }

  /// 执行官 / 天理四影：右侧分上下两行（中文名 + 称号）。
  Widget _buildTwoLineRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              entry.character.enName,
              maxLines: 1,
              softWrap: false,
              style: _enStyle,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _zhStyle,
            ),
            const SizedBox(height: 4),
            Text(
              entry.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _titleStyle,
            ),
          ],
        ),
      ],
    );
  }

  /// 单行排版：右侧是一行中文名（可选附带图标），坎瑞亚五大罪人与旅行者共用。
  ///
  /// 外框圆角 22、内边距 20、最小高度 64 与普通角色按钮完全一致，
  /// 图标只占 24 的固定方块，不会把按钮撑高。
  /// 英文名放在 [Expanded] + [FittedBox] 里，名字再长也只会等比缩小，
  /// 不会挤压或撑破右侧的内容。
  Widget _buildSingleLineRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              entry.character.enName,
              maxLines: 1,
              softWrap: false,
              style: _enStyle,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 中文名 + 图标整体贴右，Row 默认 crossAxisAlignment.center 保证垂直居中。
        _buildSingleLineTrailing(),
      ],
    );
  }

  /// 单行排版的右侧内容：中文名，以及可选的单个图标。
  ///
  /// 空 / 荧会渲染成 `中文名 → 始基力图标`，两者在同一水平线上垂直居中。
  Widget _buildSingleLineTrailing() {
    final String? iconPath = entry.iconPath;
    if (iconPath == null) {
      return Text(
        entry.displayName,
        maxLines: 1,
        softWrap: false,
        style: _zhStyle,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(entry.displayName, maxLines: 1, softWrap: false, style: _zhStyle),
        // 中文名与图标之间留 16，图标与按钮右边缘之间由 padding 的 20 兜底。
        const SizedBox(width: 16),
        _ElementIcon(assetPath: iconPath),
      ],
    );
  }
}

/// 元素 / 阵营图标。
///
/// 外圈柔光（白色 20%、blur 4、spread 0.5）与 CharacterListPage 的角色按钮
/// 完全一致。图标始终放在 24×24 的固定方块里，并用 [ClipRect] 裁掉多余部分，
/// 因此无论图片本身多大，都不会影响按钮的高度与宽度。
class _ElementIcon extends StatelessWidget {
  const _ElementIcon({required this.assetPath, this.size = 24});

  final String assetPath;

  /// 图标的固定占位边长，默认 24（与普通元素图标一致）。
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
      // 固定宽高 + 裁剪：图标再大也只在这个方块内绘制，绝不撑大按钮。
      child: SizedBox.square(
        dimension: size,
        child: ClipRect(
          child: Image.asset(
            assetPath,
            // TODO: 在此处调整 stellar_linchpin 图标大小，不要撑破按钮高度
            width: size,
            height: size,
            fit: BoxFit.contain,
            // 按 4 倍像素密度解码，避免大图缩小时发糊，也不会浪费内存。
            cacheWidth: (size * 4).round(),
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}

/// 透明返回按钮：与角色列表页的返回按钮一致。
///
/// 只保留纯白图标、按压缩放反馈和点击返回逻辑，不带背景与描边。
class _HeaderBackButton extends StatefulWidget {
  const _HeaderBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<_HeaderBackButton> createState() => _HeaderBackButtonState();
}

class _HeaderBackButtonState extends State<_HeaderBackButton> {
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
        onTapDown: (TapDownDetails _) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (TapUpDetails _) => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
