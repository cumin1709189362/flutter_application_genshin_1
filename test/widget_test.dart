import 'package:flutter/material.dart';
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
    expect(find.text('Albedo'), findsOneWidget);
    expect(find.text('阿贝多'), findsOneWidget);
    expect(find.text('Amber'), findsOneWidget);

    // 第一行 Albedo 应排在 Amber 上方，确认列表按英文名 A-Z 升序。
    expect(
      tester.getTopLeft(find.text('Albedo')).dy,
      lessThan(tester.getTopLeft(find.text('Amber')).dy),
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
}
