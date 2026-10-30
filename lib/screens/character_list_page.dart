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

/// 璃月角色数据，严格按英文名 A-Z 升序排列。
///
/// 注意：按英文名比较，`Xiangling` 应排在 `Xianyun` 之前。
const List<Character> _liyueCharacters = <Character>[
  Character(
    enName: 'Baizhu',
    zhName: '白术',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Beidou',
    zhName: '北斗',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Chongyun',
    zhName: '重云',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Gaming',
    zhName: '嘉明',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Ganyu',
    zhName: '甘雨',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Hu Tao',
    zhName: '胡桃',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Keqing',
    zhName: '刻晴',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Lan Yan',
    zhName: '蓝砚',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Ningguang',
    zhName: '凝光',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Qiqi',
    zhName: '七七',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Shenhe',
    zhName: '申鹤',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Xiangling',
    zhName: '香菱',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Xianyun',
    zhName: '闲云',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Xiao',
    zhName: '魈',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Xingqiu',
    zhName: '行秋',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Xinyan',
    zhName: '辛焱',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Yanfei',
    zhName: '烟绯',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Yaoyao',
    zhName: '瑶瑶',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Yelan',
    zhName: '夜兰',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Yun Jin',
    zhName: '云堇',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Zhongli',
    zhName: '钟离',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Zibai',
    zhName: '兹白',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
];

/// 稻妻角色数据，严格按英文名 A-Z 升序排列。
const List<Character> _inazumaCharacters = <Character>[
  Character(
    enName: 'Arataki Itto',
    zhName: '荒泷一斗',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Chiori',
    zhName: '千织',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Gorou',
    zhName: '五郎',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Kaedehara Kazuha',
    zhName: '枫原万叶',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Kamisato Ayaka',
    zhName: '神里绫华',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Kamisato Ayato',
    zhName: '神里绫人',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Kirara',
    zhName: '绮良良',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Kujou Sara',
    zhName: '九条裟罗',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Kuki Shinobu',
    zhName: '久岐忍',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Raiden Shogun',
    zhName: '雷电将军',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Sangonomiya Kokomi',
    zhName: '珊瑚宫心海',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Sayu',
    zhName: '早柚',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Shikanoin Heizou',
    zhName: '鹿野院平藏',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Thoma',
    zhName: '托马',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Yae Miko',
    zhName: '八重神子',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Yoimiya',
    zhName: '宵宫',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Yumemizuki Mizuki',
    zhName: '梦见月瑞希',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
];

/// 须弥角色数据，严格按英文名 A-Z 升序排列。
const List<Character> _sumeruCharacters = <Character>[
  Character(
    enName: 'Alhaitham',
    zhName: '艾尔海森',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Candace',
    zhName: '坎蒂丝',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Collei',
    zhName: '柯莱',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Cyno',
    zhName: '赛诺',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Dehya',
    zhName: '迪希雅',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Dori',
    zhName: '多莉',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Faruzan',
    zhName: '珐露珊',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Kaveh',
    zhName: '卡维',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Layla',
    zhName: '莱依拉',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Nahida',
    zhName: '纳西妲',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Nilou',
    zhName: '妮露',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Sethos',
    zhName: '赛索斯',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Tighnari',
    zhName: '提纳里',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Wanderer',
    zhName: '流浪者',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
];

/// 枫丹角色数据，严格按英文名 A-Z 升序排列。
const List<Character> _fontaineCharacters = <Character>[
  Character(
    enName: 'Charlotte',
    zhName: '夏洛蒂',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Chevreuse',
    zhName: '夏沃蕾',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Clorinde',
    zhName: '克洛琳德',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Emilie',
    zhName: '艾梅莉埃',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Escoffier',
    zhName: '爱可菲',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Freminet',
    zhName: '菲米尼',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Furina',
    zhName: '芙宁娜',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Lynette',
    zhName: '琳妮特',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Lyney',
    zhName: '林尼',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Navia',
    zhName: '娜维娅',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Neuvillette',
    zhName: '那维莱特',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Sigewinne',
    zhName: '希格雯',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Wriothesley',
    zhName: '莱欧斯利',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
];

/// 纳塔角色数据，严格按英文名 A-Z 升序排列。
const List<Character> _natlanCharacters = <Character>[
  Character(
    enName: 'Chasca',
    zhName: '恰斯卡',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Citlali',
    zhName: '茜特菈莉',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Iansan',
    zhName: '伊安珊',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Ifa',
    zhName: '伊法',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Kachina',
    zhName: '卡齐娜',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Kinich',
    zhName: '基尼奇',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Mavuika',
    zhName: '玛薇卡',
    elementColor: Color(0xFFEC4923),
    elementIconPath: 'assets/elements/pyro.png',
  ),
  Character(
    enName: 'Mualani',
    zhName: '玛拉妮',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Ororon',
    zhName: '欧洛伦',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Varesa',
    zhName: '瓦雷莎',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Xilonen',
    zhName: '希诺宁',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
];

/// 挪德卡莱角色数据，严格按英文名 A-Z 升序排列。
const List<Character> _nodKraiCharacters = <Character>[
  Character(
    enName: 'Aino',
    zhName: '爱诺',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Columbina',
    zhName: '哥伦比娅',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
  Character(
    enName: 'Flins',
    zhName: '菲林斯',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Illuga',
    zhName: '叶洛亚',
    elementColor: Color(0xFFCC9046),
    elementIconPath: 'assets/elements/geo.png',
  ),
  Character(
    enName: 'Ineffa',
    zhName: '伊涅芙',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Jahoda',
    zhName: '雅珂达',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Lauma',
    zhName: '菈乌玛',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
  Character(
    enName: 'Nefer',
    zhName: '奈芙尔',
    elementColor: Color(0xFF64A038),
    elementIconPath: 'assets/elements/dendro.png',
  ),
];

/// 至冬角色数据，严格按英文名 A-Z 升序排列。
const List<Character> _snezhnayaCharacters = <Character>[
  Character(
    enName: 'Alyosha',
    zhName: '阿罗夏',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Anastasya',
    zhName: '安娜丝塔夏',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Danica',
    zhName: '达妮卡',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Mitya',
    zhName: '米提亚',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  // TODO: 待补充诺伊的元素和颜色
  Character(
    enName: 'Noy',
    zhName: '诺伊',
    elementColor: Colors.grey,
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Odette',
    zhName: '奥黛塔',
    elementColor: Color(0xFF35AACC),
    elementIconPath: 'assets/elements/cryo.png',
  ),
  Character(
    enName: 'Valeriy',
    zhName: '瓦列里',
    elementColor: Color(0xFF6957C2),
    elementIconPath: 'assets/elements/electro.png',
  ),
  Character(
    enName: 'Vesna',
    zhName: '薇斯纳',
    elementColor: Color(0xFF359697),
    elementIconPath: 'assets/elements/anemo.png',
  ),
  Character(
    enName: 'Vodyanitsa',
    zhName: '沃雅妮莎',
    elementColor: Color(0xFF498FCC),
    elementIconPath: 'assets/elements/hydro.png',
  ),
];

/// 国家名 → 角色列表。
///
/// 表头标题和“XX 位”都直接使用这里的查询结果，新增国家时只需继续补充条目。
const Map<String, List<Character>> _charactersByCountry =
    <String, List<Character>>{
      '蒙德': _mondstadtCharacters,
      '璃月': _liyueCharacters,
      '稻妻': _inazumaCharacters,
      '须弥': _sumeruCharacters,
      '枫丹': _fontaineCharacters,
      '纳塔': _natlanCharacters,
      '挪德卡莱': _nodKraiCharacters,
      '至冬': _snezhnayaCharacters,
    };

/// 根据国家名返回对应的角色名单，未实现的国家返回空列表。
List<Character> _charactersFor(String countryName) {
  return _charactersByCountry[countryName] ?? const <Character>[];
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

  /// 悬浮玻璃表头内容区的高度（不含状态栏安全区）。
  static const double _headerHeight = 64.0;

  /// 列表顶部与表头底部之间的呼吸间距。
  static const double _headerListGap = 8.0;

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
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final double topInset = padding.top;
    final double bottomInset = padding.bottom;
    final double listTopPadding = topInset + _headerHeight + _headerListGap;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AuroraBackground(
        // 列表在下、悬浮表头在上，滚动内容会从玻璃表头后面隐约透出。
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: characters.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: topInset + _headerHeight + _headerListGap,
                      ),
                      child: _buildEmptyState(),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16 + padding.left,
                        listTopPadding,
                        16 + padding.right,
                        16 + bottomInset,
                      ),
                      // 保持列表项状态并为每一项建立独立重绘边界，
                      // 配合表头的 BackdropFilter，滚动时减少不必要的重建和重绘。
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(characters.length),
            ),
          ],
        ),
      ),
    );
  }

  /// 悬浮液态玻璃表头：返回按钮 + 国家标题 + 角色数量。
  ///
  /// 背景延伸到状态栏下方，内容由 [SafeArea] 保护，避免和系统状态栏重叠。
  Widget _buildHeader(int characterCount) {
    return Listener(
      // 表头是悬浮层，吸收空白区域的点击，避免误触到被遮住的列表项。
      behavior: HitTestBehavior.opaque,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: _headerHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 20, 0),
                  child: Row(
                    children: <Widget>[
                      const BackButton(color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
            ),
          ),
        ),
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
