import 'package:flutter/material.dart';

import '../widgets/aurora_background.dart';
import '../widgets/solid_gradient_button.dart';
import 'character_list_page.dart';

/// 国家 / 地区条目。
class _Nation {
  const _Nation({
    required this.nameZh,
    required this.nameEn,
    required this.color,
  });

  final String nameZh;
  final String nameEn;

  /// 国家主题淡彩色，用于玻璃染色与辉光。
  final Color color;
}

/// 八个国家 / 地区及其主题色。
///
/// TODO: 下面每个 Color 都是占位用的“淡彩”主题色，
/// 后续替换具体 Hex 值时只需修改对应行即可。
const List<_Nation> _nations = <_Nation>[
  _Nation(nameZh: '蒙德', nameEn: 'Mondstadt', color: Color(0xFF359697)),
  _Nation(nameZh: '璃月', nameEn: 'Liyue', color: Color(0xFFCC9046)),
  _Nation(nameZh: '稻妻', nameEn: 'Inazuma', color: Color(0xFF6957C2)),
  _Nation(nameZh: '须弥', nameEn: 'Sumeru', color: Color(0xFF66AD16)),
  _Nation(nameZh: '枫丹', nameEn: 'Fontaine', color: Color(0xFF498FCC)),
  _Nation(nameZh: '纳塔', nameEn: 'Natlan', color: Color(0xFFEC4923)),
  _Nation(nameZh: '挪德卡莱', nameEn: 'Nod-Krai', color: Color(0xFFC7B8E8)),
  _Nation(nameZh: '至冬', nameEn: 'Snezhnaya', color: Color(0xFF35AACC)),
];

/// 目录页：双列黄金比例网格，展示八个国家入口。
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  static const double _gap = 10.0;

  void _openCharacterList(BuildContext context, _Nation nation) {
    // 转场进行中时防止重复推入页面。
    final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);
    if (currentRoute != null && !currentRoute.isCurrent) {
      return;
    }

    // 使用普通的 Navigator.push 保留路由栈，
    // 返回键 / 安卓侧滑返回手势可以正常 pop 当前自定义转场。
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CharacterListPage(countryName: nation.nameZh);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 角色列表页淡入。
          final Animation<double> fadeIn = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          // 详情页压栈时（secondaryAnimation 0 → 1），角色列表页
          // 放大至全屏并逐渐淡出，形成“进入角色”的纵深感。
          final Animation<double> scaleUp = Tween<double>(begin: 1.0, end: 1.18)
              .animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInOutCubic,
                ),
              );
          final Animation<double> fadeOut = Tween<double>(begin: 1.0, end: 0.0)
              .animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInOut,
                ),
              );

          return FadeTransition(
            opacity: fadeIn,
            child: ScaleTransition(
              scale: scaleUp,
              child: FadeTransition(opacity: fadeOut, child: child),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // 顶部标题：与首页相同的辉光，字号更小。
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: Text(
                  'Genshin Impact Characters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    height: 1.2,
                    letterSpacing: 1.2,
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.85),
                        blurRadius: 32,
                      ),
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.45),
                        blurRadius: 64,
                      ),
                      Shadow(
                        color: const Color(0xFF7FB6FF).withValues(alpha: 0.35),
                        blurRadius: 100,
                      ),
                    ],
                  ),
                ),
              ),
              // 中间留白，把下方的网格强行推到屏幕最底部。
              const Spacer(),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(_gap),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // 严格使用黄金比例。
                  childAspectRatio: 1.618,
                  crossAxisSpacing: _gap,
                  mainAxisSpacing: _gap,
                ),
                itemCount: _nations.length,
                itemBuilder: (context, index) {
                  final _Nation nation = _nations[index];
                  return SolidGradientButton(
                    onTap: () => _openCharacterList(context, nation),
                    semanticLabel: '${nation.nameZh} ${nation.nameEn}',
                    backgroundColor: nation.color,
                    borderColor: nation.color.withValues(alpha: 0.6),
                    borderRadius: 22,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            // 左上细线 + 右上发光圆点，作为极简装饰。
                            Container(
                              width: 16,
                              height: 1,
                              color: Color.lerp(
                                Colors.white,
                                nation.color,
                                0.45,
                              )!.withValues(alpha: 0.8),
                            ),
                            const Spacer(),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: nation.color.withValues(alpha: 0.95),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: nation.color.withValues(alpha: 0.7),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          nation.nameZh,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            letterSpacing: 2.5,
                            shadows: <Shadow>[
                              Shadow(
                                color: nation.color.withValues(alpha: 0.55),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          nation.nameEn.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // 距底部 Home Indicator 再留一点呼吸空间。
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
