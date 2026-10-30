import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/character.dart';
import '../widgets/aurora_background.dart';
import 'character_detail_page.dart';

/// 蒙德角色数据，严格按英文名 A-Z 升序排列。
const List<Character> _mondstadtCharacters = <Character>[
  Character(
    enName: 'Albedo',
    zhName: '阿贝多',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Amber',
    zhName: '安柏',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Barbara',
    zhName: '芭芭拉',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Bennett',
    zhName: '班尼特',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Dahlia',
    zhName: '塔利雅',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Diluc',
    zhName: '迪卢克',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Diona',
    zhName: '迪奥娜',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Durin',
    zhName: '杜林',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Eula',
    zhName: '优菈',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Fischl',
    zhName: '菲谢尔',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Jean',
    zhName: '琴',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Kaeya',
    zhName: '凯亚',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Klee',
    zhName: '可莉',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Lisa',
    zhName: '丽莎',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Lohen',
    zhName: '洛恩',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Mika',
    zhName: '米卡',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Mona',
    zhName: '莫娜',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Noelle',
    zhName: '诺艾尔',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Razor',
    zhName: '雷泽',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Rosaria',
    zhName: '罗莎莉亚',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Sucrose',
    zhName: '砂糖',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Varka',
    zhName: '法尔伽',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Venti',
    zhName: '温迪',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
];

/// 根据国家名返回对应的角色名单。
///
/// 目前只实现蒙德；其他国家会展示“资料整理中”的空状态，
/// 后续在这里补充分支即可扩展。
List<Character> _charactersFor(String countryName) {
  if (countryName == '蒙德') {
    return _mondstadtCharacters;
  }
  return const <Character>[];
}

/// 将英文名转换为 Title Case（首字母大写、其余小写）。
String _toTitleCase(String value) {
  if (value.isEmpty) {
    return value;
  }

  return value
      .split(' ')
      .map((String word) {
        if (word.isEmpty) {
          return word;
        }
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      })
      .join(' ');
}

/// 角色列表页。
///
/// 背景复用 [AuroraBackground]，主体是纵向排列的长矩形液态玻璃按钮。
/// 点击任意角色会以“列表放大淡出 + 详情页淡入”的转场进入详情页。
class CharacterListPage extends StatelessWidget {
  const CharacterListPage({super.key, required this.countryName});

  /// 上一页（国家目录）传入的国家名，例如“蒙德”。
  final String countryName;

  /// 进入角色详情页。
  ///
  /// 复用首页“放大至全屏并变淡消失”的思路：
  /// 列表页由 catalog_page.dart 中的路由监听 secondaryAnimation 完成放大淡出，
  /// 这里负责详情页自身的缩放淡入。
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

  @override
  Widget build(BuildContext context) {
    final List<Character> characters = _charactersFor(countryName);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildHeader(characters.length),
              Expanded(
                child: characters.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: characters.length,
                        itemBuilder: (context, index) {
                          final Character character = characters[index];
                          return Padding(
                            // 水平 16 已由列表 padding 提供，这里补足垂直 8。
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: _CharacterGlassTile(
                              character: character,
                              onTap: () =>
                                  _openCharacterDetail(context, character),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 顶部返回按钮 + 国家标题。
  Widget _buildHeader(int characterCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 20, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: Colors.white),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  countryName,
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
          if (characterCount > 0)
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
    );
  }

  /// 暂未实现国家时的占位状态。
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '敬请期待',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 22,
                fontWeight: FontWeight.w400,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$countryName 的角色资料正在整理中',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
                height: 1.5,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 长矩形液态玻璃角色按钮。
///
/// 结构：BackdropFilter 模糊 + 元素淡彩底色 + 1px 半透明白色边框；
/// 按下缩放到 0.95，松开后以 elasticOut 曲线弹回。
class _CharacterGlassTile extends StatefulWidget {
  const _CharacterGlassTile({required this.character, required this.onTap});

  final Character character;
  final VoidCallback onTap;

  @override
  State<_CharacterGlassTile> createState() => _CharacterGlassTileState();
}

class _CharacterGlassTileState extends State<_CharacterGlassTile> {
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(22),
  );

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final Character character = widget.character;

    // 元素标准色 20% 透明度，得到淡彩玻璃质感。
    final Color fillColor = character.elementColor.withValues(alpha: 0.2);

    return Semantics(
      button: true,
      label: '${character.zhName} ${character.enName}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: Duration(milliseconds: _pressed ? 110 : 420),
          // 按下快速收缩，松开时 Q 弹回位。
          curve: _pressed ? Curves.easeOutCubic : Curves.elasticOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _borderRadius,
              boxShadow: <BoxShadow>[
                // 黑色投影把玻璃从极光背景里轻轻托起。
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                // 元素色微光，让每行保留一点角色元素氛围。
                BoxShadow(
                  color: character.elementColor.withValues(
                    alpha: _pressed ? 0.18 : 0.10,
                  ),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: _borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 64),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: _borderRadius,
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: _pressed ? 0.46 : 0.28,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          _toTitleCase(character.enName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            character.zhName,
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
                          const SizedBox(width: 12),
                          // 用 Container 的 boxShadow 给透明 PNG 图标叠加一圈
                          // 极淡的白色柔光，避免光晕盖过图标本身的细节。
                          Container(
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
                            child: Image.asset(
                              character.elementIconPath,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              // 原始图标约 3000px 宽，按 24dp 显示时只需解码到 96px，
                              // 避免几张超大 PNG 占满 ImageCache。
                              cacheWidth: 96,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ],
                      ),
                    ],
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
