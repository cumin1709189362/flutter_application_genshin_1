import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_genshin_1/main.dart';

/// 使用手机竖屏尺寸，避免测试默认的 800x600 横屏视口
/// 让目录页的双列黄金比例卡片变得过高而溢出。
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('首页展示标题与箭头按钮', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const GenshinApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Genshin Impact Characters'), findsOneWidget);
    expect(find.text('→'), findsOneWidget);
  });

  testWidgets('点击箭头进入目录页并展示八个国家', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const GenshinApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('→'));
    await tester.pump();
    // 极光背景是无限循环动画，不能使用 pumpAndSettle，
    // 这里显式推进到转场结束。
    await tester.pump(const Duration(milliseconds: 900));

    // 目录页顶部也有同名标题。
    expect(find.text('Genshin Impact Characters'), findsOneWidget);
    expect(find.text('蒙德'), findsOneWidget);
    expect(find.text('璃月'), findsOneWidget);

    // GridView 使用 shrinkWrap 后会构建全部条目，最后一个国家也应存在。
    expect(find.text('至冬'), findsOneWidget);
  });

  testWidgets('目录卡片进入角色列表并可返回', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const GenshinApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('→'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.text('蒙德'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('角色列表'), findsOneWidget);
    expect(find.text('23 位'), findsOneWidget);
    expect(find.text('Albedo'), findsOneWidget);
    expect(find.text('阿贝多'), findsOneWidget);
    expect(find.text('Amber'), findsOneWidget);

    // 第一行 Albedo 应排在 Amber 上方，确认列表按英文名 A-Z 升序。
    expect(
      tester.getTopLeft(find.text('Albedo')).dy,
      lessThan(tester.getTopLeft(find.text('Amber')).dy),
    );

    // 角色行应加载本地元素图标，Albedo 对应岩元素。
    // Image.asset 指定 cacheWidth 后，provider 会被 ResizeImage 包装。
    final Iterable<Image> characterIcons = tester.widgetList<Image>(
      find.byType(Image),
    );
    expect(
      characterIcons.any((Image image) {
        final ImageProvider<Object> provider = image.image;
        if (provider is AssetImage) {
          return provider.assetName == 'assets/elements/geo.png';
        }
        if (provider is ResizeImage) {
          final ImageProvider<Object> resized = provider.imageProvider;
          return resized is AssetImage &&
              resized.assetName == 'assets/elements/geo.png';
        }
        return false;
      }),
      isTrue,
    );

    // 点击角色进入详情页。
    await tester.tap(find.text('Albedo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('阿贝多'), findsOneWidget);
    expect(find.text('ALBEDO'), findsOneWidget);
    expect(find.text('角色列表'), findsNothing);

    // 从详情页返回角色列表。
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Albedo'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('角色列表'), findsNothing);
    expect(find.text('蒙德'), findsOneWidget);
  });

  testWidgets('璃月列表显示 22 位角色并动态更新表头', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const GenshinApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('→'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.text('璃月'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    // 标题与数量都来自当前国家数据，而不是写死的蒙德。
    expect(find.text('璃月'), findsOneWidget);
    expect(find.text('蒙德'), findsNothing);
    expect(find.text('22 位'), findsOneWidget);
    expect(find.text('Baizhu'), findsOneWidget);
    expect(find.text('白术'), findsOneWidget);
    expect(find.text('Beidou'), findsOneWidget);
    expect(find.text('北斗'), findsOneWidget);

    expect(
      tester.getTopLeft(find.text('Baizhu')).dy,
      lessThan(tester.getTopLeft(find.text('Beidou')).dy),
    );

    // 严格按英文名排序时，Xiangling 应排在 Xianyun 之前。
    await tester.scrollUntilVisible(
      find.text('Xiangling'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pump();

    expect(find.text('Xiangling'), findsOneWidget);
    expect(find.text('Xianyun'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Xiangling')).dy,
      lessThan(tester.getTopLeft(find.text('Xianyun')).dy),
    );
  });

  testWidgets('八个国家均显示正确的角色数量', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const GenshinApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('→'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    const Map<String, String> expectedCounts = <String, String>{
      '蒙德': '23 位',
      '璃月': '22 位',
      '稻妻': '17 位',
      '须弥': '14 位',
      '枫丹': '13 位',
      '纳塔': '11 位',
      '挪德卡莱': '8 位',
      '至冬': '9 位',
    };

    for (final MapEntry<String, String> entry in expectedCounts.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text(entry.key), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
    }
  });

  testWidgets('长英文名通过 FittedBox 完整缩放显示', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const GenshinApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('→'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.text('稻妻'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final Finder longName = find.text('Kaedehara Kazuha');
    expect(longName, findsOneWidget);

    final Text text = tester.widget<Text>(longName);
    expect(text.style?.fontSize, 18);
    expect(text.overflow, isNot(TextOverflow.ellipsis));

    final Finder fittedBoxFinder = find.ancestor(
      of: longName,
      matching: find.byType(FittedBox),
    );
    expect(fittedBoxFinder, findsOneWidget);

    final FittedBox fittedBox = tester.widget<FittedBox>(fittedBoxFinder);
    expect(fittedBox.fit, BoxFit.scaleDown);
    expect(fittedBox.alignment, Alignment.centerLeft);
  });

  testWidgets('七种元素图标资源均已声明且可读取', (WidgetTester tester) async {
    const List<String> elementNames = <String>[
      'anemo',
      'geo',
      'electro',
      'dendro',
      'hydro',
      'pyro',
      'cryo',
    ];

    for (final String element in elementNames) {
      final data = await rootBundle.load('assets/elements/$element.png');
      expect(data.lengthInBytes, greaterThan(0));
    }
  });
}
