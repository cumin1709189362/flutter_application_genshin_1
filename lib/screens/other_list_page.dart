import 'package:flutter/material.dart';

import '../models/character.dart';
import '../widgets/aurora_background.dart';
import '../widgets/solid_gradient_button.dart';
import 'character_detail_page.dart';

/// 特殊角色列表页。
///
/// 全屏极光背景 + 悬浮半透明表头，内容区是“愚人众执行官”分组标题
/// 与 11 个长矩形按键；按键尺寸、圆角、按压反馈与转场动画均与角色列表页一致。
class OtherListPage extends StatelessWidget {
  const OtherListPage({super.key});

  /// 悬浮玻璃表头内容区的高度（不含状态栏安全区）。
  static const double _headerHeight = 64.0;

  /// 列表顶部与表头底部之间的呼吸间距。
  static const double _headerListGap = 8.0;

  /// 愚人众执行官名录，按席位顺序排列。
  ///
  /// `character.zhName` 使用纯中文名，用于拼接 `assets/stories/xxx.md`；
  /// 按钮上展示的带代号名字单独放在 `displayName` 里。
  static const List<_Harbinger> _harbingers = <_Harbinger>[
    _Harbinger(
      character: Character(
        enName: 'Pierro',
        zhName: '皮耶罗',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「丑角」皮耶罗',
      title: '统括官',
    ),
    _Harbinger(
      character: Character(
        enName: 'Il Capitano',
        zhName: '卡皮塔诺',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「队长」卡皮塔诺',
      title: '第一席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Il Dottore',
        zhName: '多托雷',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「博士」多托雷',
      title: '第二席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Columbina',
        zhName: '哥伦比娅',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「少女」哥伦比娅',
      title: '第三席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Arlecchino',
        zhName: '阿蕾奇诺',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「仆人」阿蕾奇诺',
      title: '第四席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Pulcinella',
        zhName: '普契涅拉',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「公鸡」普契涅拉',
      title: '第五席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Scaramouche',
        zhName: '斯卡拉姆齐',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「散兵」斯卡拉姆齐',
      title: '第六席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Sandrone',
        zhName: '桑多涅',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「木偶」桑多涅',
      title: '第七席',
    ),
    _Harbinger(
      character: Character(
        enName: 'La Signora',
        zhName: '席诺拉',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「女士」席诺拉',
      title: '第八席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Pantalone',
        zhName: '潘塔罗涅',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「富人」潘塔罗涅',
      title: '第九席',
    ),
    _Harbinger(
      character: Character(
        enName: 'Tartaglia',
        zhName: '达达利亚',
        elementColor: Colors.grey,
        elementIconPath: '',
      ),
      displayName: '「公子」达达利亚',
      title: '末席',
    ),
  ];

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
                  _buildSectionTitle(),
                  ..._harbingers.map((_Harbinger harbinger) {
                    return Padding(
                      // 与角色列表页一致：水平 16 由列表 padding 提供，这里补足垂直 8。
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _HarbingerButton(
                        harbinger: harbinger,
                        onTap: () =>
                            _openCharacterDetail(context, harbinger.character),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(context, _harbingers.length),
            ),
          ],
        ),
      ),
    );
  }

  /// 分组标题：左对齐的白色粗体文字。
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
      child: Text(
        '愚人众执行官',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 2,
          shadows: <Shadow>[
            Shadow(
              color: Colors.white.withValues(alpha: 0.35),
              blurRadius: 16,
            ),
          ],
        ),
      ),
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
                  // 数量由数据源动态计算，当前为“11 位”。
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

/// 愚人众执行官条目数据。
class _Harbinger {
  const _Harbinger({
    required this.character,
    required this.displayName,
    required this.title,
  });

  /// 传给详情页的角色对象，`zhName` 为纯中文名，用于拼接故事资源路径。
  final Character character;

  /// 按钮上展示的带代号中文名，例如「博士」多托雷。
  final String displayName;

  /// 职位 / 席位，显示在按钮右侧下方。
  final String title;
}

/// 长矩形执行官按钮。
///
/// 尺寸、圆角、按压 0.95 缩放统一交给 [SolidGradientButton]，
/// 与角色列表页的按钮保持完全一致的交互反馈。
class _HarbingerButton extends StatelessWidget {
  const _HarbingerButton({required this.harbinger, required this.onTap});

  final _Harbinger harbinger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SolidGradientButton(
      onTap: onTap,
      semanticLabel:
          '${harbinger.displayName} ${harbinger.character.enName} ${harbinger.title}',
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 64),
      // 与“特殊角色”入口按钮同款的灰色半透明 + 灰色高光边框。
      backgroundColor: Colors.grey,
      backgroundOpacity: 0.35,
      borderColor: Colors.grey.withValues(alpha: 0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                harbinger.character.enName,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                harbinger.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                harbinger.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
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
