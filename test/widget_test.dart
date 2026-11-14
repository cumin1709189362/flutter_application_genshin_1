import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_genshin_1/main.dart';
import 'package:flutter_application_genshin_1/models/character.dart';
import 'package:flutter_application_genshin_1/models/character_text_document.dart';
import 'package:flutter_application_genshin_1/screens/character_detail_page.dart';
import 'package:flutter_application_genshin_1/screens/character_voice_page.dart';
import 'package:flutter_application_genshin_1/widgets/character_text_view.dart';
import 'package:flutter_application_genshin_1/widgets/solid_gradient_button.dart';

/// 使用手机竖屏尺寸，避免测试默认的 800x600 横屏视口
/// 让目录页的双列黄金比例卡片变得过高而溢出。
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// SolidGradientButton 会先展示约 110ms 的按压反馈，再开始页面转场。
Future<void> _tapSolidButton(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump(const Duration(milliseconds: 900));
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

    await _tapSolidButton(tester, find.text('→'));

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

    await _tapSolidButton(tester, find.text('→'));

    await _tapSolidButton(tester, find.text('蒙德'));

    expect(find.text('角色列表'), findsOneWidget);
    expect(find.text('24 位'), findsOneWidget);
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

    // 点击角色进入详情页，故事异步加载完成后应展示纯文本内容。
    await tester.tap(find.text('Albedo'));
    await tester.pump();
    // LiquidGlassButton 会先保留至少 110ms 的按压反馈，再触发跳转。
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 900));

    expect(
      find.byKey(const Key('character-detail-back-button')),
      findsOneWidget,
    );

    // 首屏：懒加载只构建视口附近的块。
    expect(find.textContaining('角色详细'), findsOneWidget);
    expect(find.text('-------------------------'), findsWidgets);
    expect(find.textContaining('这门技术历史悠久'), findsOneWidget);
    expect(find.textContaining('##'), findsNothing);
    expect(find.textContaining('> 解锁条件'), findsNothing);
    expect(find.text('ALBEDO'), findsNothing);
    expect(find.text('角色列表'), findsNothing);

    final Text bodyText = tester.widget<Text>(find.textContaining('这门技术历史悠久'));
    expect(bodyText.style?.fontSize, 16);
    expect(bodyText.style?.height, 1.8);

    // 「角色故事一」位于首屏之下，需要滚动触发按需构建。
    final Finder detailList = find.descendant(
      of: find.byKey(const Key('character-text-list')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('角色故事一'),
      200,
      scrollable: detailList,
    );
    await tester.pump();

    expect(find.text('角色故事一'), findsOneWidget);
    expect(find.text('角色故事1'), findsNothing);

    final Text storyTitle = tester.widget<Text>(find.text('角色故事一'));
    expect(storyTitle.style?.fontSize, 20);
    expect(storyTitle.style?.fontWeight, FontWeight.w700);

    // 解锁条件紧跟章节标题，稍作滚动即可构建。
    await tester.scrollUntilVisible(
      find.text('解锁条件：好感2级'),
      100,
      scrollable: detailList,
    );
    await tester.pump();

    expect(find.text('解锁条件：好感2级'), findsOneWidget);

    final Text unlockCondition = tester.widget<Text>(find.text('解锁条件：好感2级'));
    expect(unlockCondition.style?.fontSize, 14);
    expect(unlockCondition.style?.color, Colors.white70);

    // 从详情页的悬浮玻璃按钮返回角色列表。
    await tester.tap(find.byKey(const Key('character-detail-back-button')));
    await tester.pump();
    // 同样等待 LiquidGlassButton 的最短按压时间，再让 pop 转场完成。
    await tester.pump(const Duration(milliseconds: 150));
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

    await _tapSolidButton(tester, find.text('→'));

    await _tapSolidButton(tester, find.text('璃月'));

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

    await _tapSolidButton(tester, find.text('→'));

    const Map<String, String> expectedCounts = <String, String>{
      '蒙德': '24 位',
      '璃月': '22 位',
      '稻妻': '17 位',
      '须弥': '14 位',
      '枫丹': '15 位',
      '纳塔': '11 位',
      '挪德卡莱': '10 位',
      '至冬': '11 位',
    };

    for (final MapEntry<String, String> entry in expectedCounts.entries) {
      await _tapSolidButton(tester, find.text(entry.key));

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

    await _tapSolidButton(tester, find.text('→'));

    await _tapSolidButton(tester, find.text('稻妻'));

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

  testWidgets('故事文件缺失时显示未收录提示', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterDetailPage(
          character: const Character(
            enName: 'Missing',
            zhName: '不存在的角色',
            elementColor: Color(0xFF359697),
            elementIconPath: 'assets/elements/anemo.png',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('故事未收录'), findsOneWidget);
    expect(
      find.byKey(const Key('character-detail-back-button')),
      findsOneWidget,
    );
  });

  testWidgets('角色详情页标题行右侧可进入语音页', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    const Character huTao = Character(
      enName: 'Hu Tao',
      zhName: '胡桃',
      elementColor: Color(0xFFEC4923),
      elementIconPath: 'assets/elements/pyro.png',
    );

    await tester.pumpWidget(
      const MaterialApp(home: CharacterDetailPage(character: huTao)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    // 标题与按钮在同一行：按钮取角色元素色、与标题行高齐平。
    expect(find.text('胡桃'), findsOneWidget);
    final Finder voiceButton = find.text('角色语音→');
    expect(voiceButton, findsOneWidget);

    final SolidGradientButton button = tester.widget<SolidGradientButton>(
      find.ancestor(
        of: voiceButton,
        matching: find.byType(SolidGradientButton),
      ),
    );
    expect(button.backgroundColor, huTao.elementColor);
    expect(button.borderRadius, 20);
    expect(button.height, 40);

    await _tapSolidButton(tester, voiceButton);

    expect(
      find.byKey(const Key('character-voice-back-button')),
      findsOneWidget,
    );
    expect(find.text('胡桃 语音'), findsOneWidget);
    expect(find.text('初次见面…'), findsOneWidget);
    expect(find.textContaining('找本堂主有何贵干'), findsOneWidget);

    // 语音页沿用故事页的标题与正文样式。
    final Text voiceSection = tester.widget<Text>(find.text('初次见面…'));
    expect(voiceSection.style?.fontSize, 20);
    expect(voiceSection.style?.fontWeight, FontWeight.w700);

    final Text voiceBody = tester.widget<Text>(find.textContaining('找本堂主有何贵干'));
    expect(voiceBody.style?.fontSize, 16);
    expect(voiceBody.style?.height, 1.8);
    // 非旅行者语音不传说话人颜色，仍是原来的单 Text 渲染。
    expect(voiceBody.textSpan, isNull);

    // 返回详情页后标题与语音入口仍在。
    await tester.tap(find.byKey(const Key('character-voice-back-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('角色语音→'), findsOneWidget);
  });

  testWidgets('语音文件缺失时显示未收录提示', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterVoicePage(
          character: const Character(
            enName: 'Missing',
            zhName: '不存在的角色',
            elementColor: Color(0xFF359697),
            elementIconPath: 'assets/elements/anemo.png',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('语音未收录'), findsOneWidget);
    expect(
      find.byKey(const Key('character-voice-back-button')),
      findsOneWidget,
    );
  });

  testWidgets('长语音页按块懒加载，滚动后再构建后续段落', (WidgetTester tester) async {
    _usePhoneViewport(tester);
    // 用 17KB / 220 块的语音资源验证页面接线。
    // 注意：>50KB 的资源会被 AssetBundle.loadString 丢进 isolate 解码，
    // 假时钟等不到结果，所以页面级用例刻意选了 50KB 以内的文件。
    const Character chef = Character(
      enName: 'Escoffier',
      zhName: '爱可菲',
      elementColor: Color(0xFF6BA8E5),
      elementIconPath: '',
    );

    await tester.pumpWidget(
      const MaterialApp(home: CharacterVoicePage(character: chef)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    // 列表就绪，但只构建了首屏附近的少量文本块。
    expect(find.byKey(const Key('character-text-list')), findsOneWidget);
    expect(find.byType(Text).evaluate().length, lessThan(80));

    // 文档末尾的台词此时还不存在；顶部标题已经构建。
    expect(find.text('刀具和餐叉，准备就绪。'), findsNothing);
    expect(find.text('爱可菲 语音'), findsOneWidget);

    // 向下滚动后，末尾内容按需构建，顶部标题被回收。
    await tester.scrollUntilVisible(
      find.text('刀具和餐叉，准备就绪。'),
      800,
      scrollable: find.byType(Scrollable),
      maxScrolls: 40,
    );
    await tester.pump();

    expect(find.text('刀具和餐叉，准备就绪。'), findsOneWidget);
    expect(find.text('爱可菲 语音'), findsNothing);
  });

  testWidgets('CharacterTextView 面对 2000 块文档也只渲染视口附近', (
    WidgetTester tester,
  ) async {
    _usePhoneViewport(tester);
    final List<CharacterTextBlock> blocks = <CharacterTextBlock>[
      const CharacterTextBlock(
        kind: CharacterTextBlockKind.characterName,
        text: '测试角色',
      ),
      for (int index = 1; index <= 2000; index++)
        CharacterTextBlock(
          kind: CharacterTextBlockKind.paragraph,
          text: '第 $index 段正文',
          spaceBefore: true,
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterTextView(
            document: CharacterTextDocument(blocks),
            elementColor: Colors.blue,
            padding: const EdgeInsets.all(24),
            listKey: const Key('synthetic-text-list'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('synthetic-text-list')), findsOneWidget);
    expect(find.byType(Text).evaluate().length, lessThan(100));
    expect(find.text('第 2000 段正文'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('第 2000 段正文'),
      2000,
      scrollable: find.byType(Scrollable),
      maxScrolls: 60,
    );
    await tester.pump();

    expect(find.text('第 2000 段正文'), findsOneWidget);
  });

  testWidgets('CharacterTextView 只给说话人姓名染色，正文保持白色', (
    WidgetTester tester,
  ) async {
    _usePhoneViewport(tester);
    const CharacterTextDocument document = CharacterTextDocument(
      <CharacterTextBlock>[
        CharacterTextBlock(
          kind: CharacterTextBlockKind.paragraph,
          text: '旅行者：和派蒙一起出发吧。',
          speaker: '旅行者',
        ),
        CharacterTextBlock(
          kind: CharacterTextBlockKind.paragraph,
          text: '派蒙：好耶！',
          speaker: '派蒙',
          spaceBefore: true,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterTextView(
            document: document,
            elementColor: Colors.blue,
            padding: const EdgeInsets.all(24),
            speakerColors: const <String, Color>{
              '旅行者': Color(0xFFCC9046),
              '派蒙': Color(0xFF35AACC),
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // 段落仍然是 Text，只是改用 TextSpan 渲染，正文样式保持不变。
    final Text travelerLine = tester.widget<Text>(find.text('旅行者：和派蒙一起出发吧。'));
    expect(travelerLine.style?.fontSize, 16);
    expect(travelerLine.style?.color, Colors.white.withValues(alpha: 0.9));

    final TextSpan travelerSpan = travelerLine.textSpan! as TextSpan;
    final TextSpan travelerLabel = travelerSpan.children![0] as TextSpan;
    expect(travelerLabel.text, '旅行者：');
    expect(travelerLabel.style?.color, const Color(0xFFCC9046));

    // 这一行正文里再次出现的「派蒙」仍是未单独设色的白色文字。
    final TextSpan travelerBody = travelerSpan.children![1] as TextSpan;
    expect(travelerBody.text, '和派蒙一起出发吧。');
    expect(travelerBody.style, isNull);

    final Text paimonLine = tester.widget<Text>(find.text('派蒙：好耶！'));
    final TextSpan paimonSpan = paimonLine.textSpan! as TextSpan;
    final TextSpan paimonLabel = paimonSpan.children![0] as TextSpan;
    expect(paimonLabel.text, '派蒙：');
    expect(paimonLabel.style?.color, const Color(0xFF35AACC));
  });

  testWidgets('语音资源已声明且可读取', (WidgetTester tester) async {
    final data = await rootBundle.load('assets/voices/胡桃_语音.md');
    expect(data.lengthInBytes, greaterThan(0));
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
