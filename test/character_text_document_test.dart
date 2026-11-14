import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_genshin_1/models/character_text_document.dart';

void main() {
  group('parseCharacterTextDocument', () {
    test('归一 BOM 与 CRLF，并识别角色名一级标题', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '\uFEFF# 胡桃\r\n\r\n正文第一段',
      );

      expect(document.blocks.length, 2);
      expect(document.blocks[0].kind, CharacterTextBlockKind.characterName);
      expect(document.blocks[0].text, '胡桃');
      expect(document.blocks[0].spaceBefore, isFalse);
      expect(document.blocks[1].kind, CharacterTextBlockKind.paragraph);
      expect(document.blocks[1].text, '正文第一段');
      expect(document.blocks[1].spaceBefore, isTrue);
    });

    test('章节标题与解锁条件合并处理，故事标题后不留空行', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '## 角色故事1\n\n> 解锁条件：好感2级\n\n正文',
      );

      expect(document.blocks.length, 3);
      expect(document.blocks[0].kind, CharacterTextBlockKind.sectionHeader);
      expect(document.blocks[0].text, '角色故事一');
      expect(document.blocks[1].kind, CharacterTextBlockKind.unlockCondition);
      expect(document.blocks[1].text, '解锁条件：好感2级');
      expect(document.blocks[1].spaceBefore, isFalse);
      expect(document.blocks[2].kind, CharacterTextBlockKind.paragraph);
      expect(document.blocks[2].spaceBefore, isTrue);
    });

    test('两位数故事编号转成中文', () {
      expect(
        parseCharacterTextDocument('## 角色故事10').blocks.single.text,
        '角色故事十',
      );
      expect(
        parseCharacterTextDocument('## 角色故事2').blocks.single.text,
        '角色故事二',
      );
    });

    test('非故事标题的三级标题原样保留为章节头', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '### 闲聊·往生堂',
      );

      expect(document.blocks.single.kind, CharacterTextBlockKind.sectionHeader);
      expect(document.blocks.single.text, '闲聊·往生堂');
    });

    test('清洗内联 Markdown：链接、图片、HTML、强调与实体', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '见[对照表](https://example.com)与![图](a.png)。**粗体**<br>换行&amp;结束',
      );

      expect(document.blocks.single.kind, CharacterTextBlockKind.paragraph);
      expect(document.blocks.single.text, '见对照表与。粗体 换行&结束');
    });

    test('剥离引用与列表标记', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '> 引用\n- 列表\n1. 有序',
      );

      expect(
        document.blocks.map((CharacterTextBlock block) => block.text).toList(),
        <String>['引用', '列表', '有序'],
      );
    });

    test('分隔线只产生空行语义，不生成独立块', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '正文\n\n---\n\n下一段',
      );

      expect(
        document.blocks.map((CharacterTextBlock block) => block.kind).toList(),
        <CharacterTextBlockKind>[
          CharacterTextBlockKind.paragraph,
          CharacterTextBlockKind.paragraph,
        ],
      );
      expect(document.blocks[1].spaceBefore, isTrue);
    });

    test('代码围栏行被跳过', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '正文\n```dart\n代码\n```\n结尾',
      );

      expect(
        document.blocks.map((CharacterTextBlock block) => block.text).toList(),
        <String>['正文', '代码', '结尾'],
      );
    });

    test('连续空行只产生一次间距，首块没有间距', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '\n\n正文一\n\n\n\n正文二',
      );

      expect(document.blocks.length, 2);
      expect(document.blocks[0].spaceBefore, isFalse);
      expect(document.blocks[1].spaceBefore, isTrue);
    });

    test('来源页面行单独识别', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '# 阿贝多\n\n- 来源页面：https://example.com/a',
      );

      expect(document.blocks.last.kind, CharacterTextBlockKind.sourceLine);
      expect(document.blocks.last.text, '来源页面：https://example.com/a');
    });

    test('章节标题前的空行会保留间距', () {
      final CharacterTextDocument document = parseCharacterTextDocument(
        '正文\n\n## 角色详细',
      );

      expect(document.blocks.last.kind, CharacterTextBlockKind.sectionHeader);
      expect(document.blocks.last.spaceBefore, isTrue);
    });

    test('空内容与纯空白内容得到空文档', () {
      expect(parseCharacterTextDocument('').isEmpty, isTrue);
      expect(parseCharacterTextDocument('  \n\n\t\n').isEmpty, isTrue);
    });
  });
}
