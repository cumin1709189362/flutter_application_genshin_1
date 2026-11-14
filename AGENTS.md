# AGENTS.md

> 本文件是**本仓库的唯一事实来源（single source of truth）**。
> 任何 AI 或人类在修改代码前，请先完整读完本文件；改动完成后，如果改了架构/约定，
> 请同步更新本文件。若文档与代码不一致，以代码为准，并顺手修正文档。

---

## 0. 摘要

- 这是一个 **Flutter Android 应用**，离线展示《原神》角色资料：角色故事与角色语音（Markdown 资源）。
- **没有后端、没有网络请求、没有任何第三方运行时依赖**（`pubspec.yaml` 的 dependencies 只有 `flutter`）。
- 数据规模：8 个国家共 **124 位角色** + 「特殊角色」4 个分组 **22 条**（含 4 条与国家级列表重复），
  共 **146 个条目 / 142 个不重复角色名**；对应 `assets/stories/` 130 个 Markdown、`assets/voices/` 123 个。
- 全部 UI 文案与代码注释使用**中文**；视觉风格是「暗色星空 + 极光 + 半透明玻璃卡片」。
- 质量门槛：`dart analyze` 必须 0 issue，`flutter test` 必须 25 个用例全绿。

---

## 1. 环境与常用命令

| 项 | 值 |
|---|---|
| 仓库根目录 | `flutter_application_genshin_1/`（本文档所在目录） |
| 包名 | `flutter_application_genshin_1` |
| 应用 ID | `com.projectgenshin.characters` |
| Flutter SDK | `D:\FlutterSDK\flutter`（Flutter 3.47.x / Dart 3.13.7） |
| JDK（签名用） | `D:\Android_Studio\jbr`（`keytool.exe` 在 `bin/` 下） |
| Android SDK | `C:\Users\17091\AppData\Local\Android\sdk`（见 `android/local.properties`） |
| 目标平台 | **仅 Android**（仓库里没有 `ios/`、`web/`、`windows/`） |

在仓库根目录执行：

```powershell
flutter pub get        # 拉依赖（本项目实际没有第三方依赖）
flutter analyze        # 静态检查，必须 0 issue
flutter test           # 25 个用例，必须全绿
flutter run            # 真机/模拟器调试
flutter build apk --release
```

> **本机环境提示**：在这台机器上直接调用 `flutter.bat` 有可能长时间无响应。
> 更稳的等价调用是
> `& 'D:\FlutterSDK\flutter\bin\cache\dart-sdk\bin\dart.exe' 'D:\FlutterSDK\flutter\bin\cache\flutter_tools.snapshot' <子命令>`。
> 另外，若通过受限沙箱执行，`dart analyze` / `flutter test` / `flutter build` 需要写入
> `.dart_tool/`、`build/` 与用户级 Gradle 缓存，可能需要更高权限。

---

## 2. 目录与文件职责

```
flutter_application_genshin_1/
├─ lib/
│  ├─ main.dart                      入口：主题、沉浸式状态栏、锁定竖屏、全局字号倍率夹取
│  ├─ models/
│  │   ├─ character.dart             角色值对象 + 资源路径解析（文件名映射）
│  │   └─ character_text_document.dart  长文「数据层」：Markdown → 排版块列表（纯 Dart）
│  ├─ screens/                       有独立路由的整页
│  │   ├─ home_page.dart             首页（发光标题 + 圆形箭头按钮）
│  │   ├─ catalog_page.dart          国家目录（2 列黄金比例网格 + 特殊角色入口）
│  │   ├─ character_list_page.dart   国家角色列表（含 780 行硬编码角色数据）
│  │   ├─ other_list_page.dart       特殊角色列表（4 个分组：旅行者/执行官/四影/罪人）
│  │   ├─ character_detail_page.dart 故事页（薄壳，只装配参数）
│  │   └─ character_voice_page.dart  语音页（更薄的壳，只改资源路径与文案）
│  ├─ widgets/                       可复用、无路由的组件
│  │   ├─ aurora_background.dart     动态极光背景（CustomPainter 自绘）
│  │   ├─ solid_gradient_button.dart 统一玻璃按钮（按压反馈 + 防连点）
│  │   ├─ character_text_page.dart   长文页骨架（读资源、延迟解析、加载/空态、返回键）
│  │   └─ character_text_view.dart   长文渲染（ListView.builder 按块懒加载）
│  └─ utils/
│      └─ page_routes.dart           详情/语音共用转场
├─ assets/
│  ├─ stories/   130 个 `<角色名>.md` 角色故事（技能/命座/故事/神之眼……）
│  ├─ voices/    123 个 `<角色名>_语音.md` 语音文本
│  ├─ elements/  11 张 PNG：7 元素 + moon_wheel + stellar_linchpin + empty + triquetra
│  ├─ fonts/     Genshin_Impact_Font.ttf（约 6.9 MB，全局字体 family = GenshinFont）
│  └─ icon/      仅用于 flutter_launcher_icons 生成启动图标，**不参与运行时**
├─ test/
│  ├─ character_text_document_test.dart  解析器单测（12 个）
│  └─ widget_test.dart                   界面/导航/懒加载测试（13 个）
├─ android/      Android 工程（包名、签名、清单）
├─ .widget_preview/  Flutter widget preview 的脚手架产物，**与本项目无关，勿改**
├─ pubspec.yaml  依赖、字体、资源目录声明
└─ analysis_options.yaml  flutter_lints 默认规则
```

### 文件级说明

| 文件 | 职责要点 |
|---|---|
| `lib/main.dart` | `MaterialApp`（dark、Material3、`fontFamily: 'GenshinFont'`、`splashFactory: NoSplash`）；`builder` 里统一注入透明状态栏 `AnnotatedRegion` 并把 `textScaler` 夹到 0.8~1.4；`main()` 里锁定竖屏 |
| `lib/models/character.dart` | `@immutable`；字段 `enName / zhName / elementColor / elementIconPath`；`storyAssetPath`、`voiceAssetPath` 两个计算属性；`_resolveAssetBaseName` 处理文件名特例 |
| `lib/models/character_text_document.dart` | `CharacterTextBlockKind`（5 种）、`CharacterTextBlock`、`CharacterTextDocument`、`parseCharacterTextDocument()`；不含任何 Widget |
| `lib/screens/catalog_page.dart` | 私有 `_Nation` 模型 + 8 条常量；`_pushWithTransition` 负责「淡入 + 被压栈时放大淡出」 |
| `lib/screens/character_list_page.dart` | 8 组 `const List<Character>`、`_charactersByCountry` 查表、`_toTitleCase`、悬浮表头、`_CharacterButton`、`_extraIcons` 映射、`_GlowIcon` |
| `lib/screens/other_list_page.dart` | `_OtherSection` / `_OtherEntry` 两层私有模型；单行与两行两种按钮排版；自定义透明返回键 |
| `lib/screens/character_detail_page.dart` | 参数装配；`_VoiceEntryButton`（40 高、圆角 20、元素色） |
| `lib/screens/character_voice_page.dart` | 只换 `assetPath` 与两句文案 |
| `lib/widgets/aurora_background.dart` | 静态底色 + 4 条径向渐变光带（`BlendMode.screen`）+ 96 星点 + 静态暗角；进度量化到 30fps；2π 整数倍周期，无缝循环 |
| `lib/widgets/solid_gradient_button.dart` | `GestureDetector` + `AnimatedScale`，按下 0.95（110ms `easeOutCubic`）、回弹 420ms `elasticOut`；最短按压 110ms；`_busy` 350ms 防连点 |
| `lib/widgets/character_text_page.dart` | `Future<CharacterTextDocument>`；`rootBundle.loadString` → 等 650ms → 解析；`FutureBuilder` 三态；`_logAssetManifest` 诊断；玻璃返回键 |
| `lib/widgets/character_text_view.dart` | `ListView.builder`（`addAutomaticKeepAlives: false`、`addRepaintBoundaries: true`）；每块外包 `SizedBox(width: double.infinity)` 还原旧 `Column(stretch)` 语义 |
| `lib/utils/page_routes.dart` | `characterPageRoute()`：620ms / 回退 420ms，淡入 + 0.92→1.0 放大 |

---

## 3. 架构与依赖方向

```
L0 入口      main.dart
L1 基础件    aurora_background / solid_gradient_button / page_routes
L2 业务组件  character_text_page / character_text_view
L3 页面      home / catalog / character_list / other_list / detail / voice
L4 数据      models/character.dart / models/character_text_document.dart
```

硬性约束：

- 依赖**只能向下**：`screens` 可以 import `widgets`、`models`、`utils`；`widgets` 不得 import `screens`；
  `models/character_text_document.dart` 只依赖 `package:flutter/foundation.dart`，**不得 import material**。
- 没有全局状态、没有状态管理库。页面内状态用 `StatefulWidget` + `setState`，跨页传递靠构造函数参数。
- 没有路由表：所有跳转都是 `Navigator.push(PageRouteBuilder(...))`，`main.dart` 只声明 `home:`。

### 导航拓扑与转场参数

```
HomePage ──pushReplacement 620ms（左滑出 / 右侧滑入）──► CatalogPage     # 首页不可返回
CatalogPage ──push 650 / pop 420ms（列表淡入；目录页放大1.18并淡出）──►
   ├─ CharacterListPage(countryName)
   └─ OtherListPage
        └──push characterPageRoute 620 / 420（淡入 + 0.92→1.0）──► CharacterDetailPage
                                                                  └──► CharacterVoicePage
```

- 防重复入栈有两道：路由侧 `ModalRoute.of(context).isCurrent` 判断；按钮侧 `_busy` 350ms 锁。
- 详情页/语音页的解析被人为延后 **650ms**（> 620ms 转场），避免在转场动画期间做正则清洗与解析。
  改这两个数字时必须成对考虑：`_deferParsingDuration` 应始终 ≥ 进入该页面的转场时长。

---

## 4. 数据流（从资源到屏幕）

```
Character.zhName ──(_resolveAssetBaseName 特例)──► assets/stories|voices/<name>.md
        │
        ├─ rootBundle.loadString(assetPath)            # >50KB 时 Flutter 自动转 isolate 解码
        ├─ await Future.delayed(650ms)                 # 让转场先跑完
        ├─ parseCharacterTextDocument(raw)             # 单遍扫描 → List<CharacterTextBlock>
        └─ FutureBuilder → CharacterTextView
                 └─ ListView.builder：只为视口附近的块创建 Widget
```

解析规则（与 `character_text_document.dart` 的实现一一对应，改之前先读那 12 个单测）：

- 一级标题 `#` → 角色名大标题；二级及以下标题 → 「分隔线 + 章节标题」合并成一块。
- `角色故事N` 自动转中文数字（0–10），且紧跟其后的 `解锁条件` 行之间不插空行。
- `解锁条件…` → 14px 白 70%；`来源页面…` / `来源：…` → 11px 白 35%；其余为正文。
- 引用 `>`、列表 `- / * / + / 1.`、`---` 分隔线、` ``` ` 围栏行、图片、链接、`<br>`、HTML 标签、
  强调符、HTML 实体都会被清洗；空行只会让下一块带上一次 16px 间距。
- 文档首块无间距、末尾不留间距。

---

## 5. 设计系统（**必须复用，禁止自创**）

### 5.1 颜色

| 用途 | 值 |
|---|---|
| 极光底色 | `#050B1E → #0A1A3A(55%) → #020409` |
| 主题 | dark；`primary #9CC4FF`、`secondary #7FE6D0`、`surface #0A1A3A` |
| 风 anemo | `#359697` |
| 岩 geo | `#CC9046` |
| 雷 electro | `#6957C2` |
| 草 dendro | `#64A038` |
| 水 hydro | `#498FCC` |
| 火 pyro | `#EC4923` |
| 冰 cryo | `#35AACC` |
| 挪德卡莱（目录页专用，非元素色） | `#C7B8E8` |
| 正文 / 次要 / 弱化 | 白 90% / 白 70% / 白 52%·45%·35% |
| 分隔线 | `Colors.grey` 50% |

> ⚠️ **同一个颜色只能有一个来源**：元素色从 `Character.elementColor` 取，
> 目录页的国家色写 `catalog_page.dart` 的 `_nations`。**不要在新代码里再硬编码元素色值**；
> 如果发现两处不一致（历史上须弥曾出现 `#66AD16` 与 `#64A038` 并存），以元素色为准修正。

### 5.2 字号阶梯

| 字号 | 用途 |
|---|---|
| 28–44（屏宽 × 0.082，夹取） | 首页主标题（w300） |
| 30 | 角色名大标题（w400, ls4, 元素色辉光 24） |
| 25 | 列表页表头国家名（w500, ls4） |
| 23 | 目录国家卡片中文名（w400, ls2.5） |
| 22 | 目录页顶部标题（w300）；空态「敬请期待」 |
| 20 | 章节标题（w700, ls2）；特殊角色分组标题（w700） |
| 18 | 角色英文名（w500, ls1.2） |
| 17 | 角色中文名（w500, ls2.0） |
| 16 | 正文（h1.8, ls0.5）；「角色语音→」按钮 |
| 15 / 13 | 空态说明 / 加载文案 |
| 14 | 解锁条件（white70, h1.5） |
| 11 | 来源行、表头「N 位」、席位称号 |
| 10 | 卡片英文小字（ls1.6）、表头副标题 |

### 5.3 间距与圆角

- 间距只用这些值：**4 / 7 / 8 / 10 / 12 / 16 / 20 / 24 / 32 / 42 / 48 / 96**
  - 16 = 正文块间距；20 = 按钮内边距；24 = 页面左右边距；96 = 长文内容顶部避让；32 = 特殊角色分组间距。
- 圆角：列表/卡片按钮 **22**，返回键 **24**，首页箭头 **26**，语音入口 **20**。
- 长文列表 padding：左 24、右 24、上 `safe.top + 96`、下 `safe.bottom + 48`。
- 列表页 padding：左右 `16 + safe`、上 `safe.top + 64 + 8`、下 `16 + safe.bottom`（表头高 64）。

### 5.4 材质与阴影

- 玻璃按钮 = 半透明纯色填充（默认 35% 元素色）+ 1px 60% 元素色描边 + 黑色 16% 投影（blur 12 / offset 0,4）。
  `backgroundColor == Colors.black` 是特例：固定 60% 黑色，用于返回键。
- 悬浮表头 = 黑色 60% + 底部 1px 白 12% + 黑色 18% 投影。
- 图标 = 24×24，外圈白色 20% 柔光（blur 4 / spread 0.5），`cacheWidth: 96`。
- **禁止** `BackdropFilter` / `ImageFiltered` / 大面积 `Opacity`：全项目刻意 0 处实时模糊，靠透明度模拟磨砂。

---

## 6. 硬性规则

### 6.1 必须

1. 任何可点击卡片/按钮 → 复用 `SolidGradientButton`（自带按压缩放、防连点、语义标签）。
2. 任何长文渲染 → `parseCharacterTextDocument()` + `CharacterTextView`；**禁止**在 `build()` 里做解析、正则清洗或 `split`。
3. 新页面必须有返回入口，并给返回按钮一个唯一 `Key`，命名沿用 `xxx-back-button`。
4. 资源路径一律走 `Character.storyAssetPath` / `voiceAssetPath`，**禁止**手拼字符串。
5. 新增资源目录必须在 `pubspec.yaml` 的 `flutter.assets` 里声明（漏了声明的直接症状是「未收录」）。
6. 颜色透明度用 `withValues(alpha: x)`；`withOpacity` 已废弃，不要用。
7. 布局必须能在 **1.4 倍系统字号**下不溢出（这是 `main.dart` 里的夹取上限，见 6.3 无障碍约定）。
8. 注释用中文，解释「为什么这样做」；文件头写清这个文件的职责。

### 6.2 禁止

1. **不要**引入状态管理（Provider/Riverpod/Bloc）、路由库（go_router）、代码生成（freezed/json_serializable）、
   第三方 UI 或 Markdown 库。本项目已验证「零依赖」足够用。
2. **不要**用 `InkWell` / `ElevatedButton` / `Card` 等 Material 默认组件替换现有自绘样式（水波纹已被全局关闭）。
3. **不要**改动这些经过实测的性能参数，除非有 profiling 数据：极光 30fps 量化、静态暗角分层、
   650ms 延迟解析、`addAutomaticKeepAlives: false`、`cacheWidth: 96`。
4. **不要**为了「更现代」重写能正常工作的代码；改动应尽量小、可回滚。
5. **不要**一次改多个页面；一次只做一件事，改完跑测试。
6. **不要**删除或弱化 `test/` 下的既有断言（它们锁定了字号、颜色、Key、排序与懒加载行为）。

### 6.3 无障碍约定

- `main.dart` 把 `MediaQuery.textScaler` 夹在 `0.8 ~ 1.4`，防止固定尺寸区域（64 高表头、黄金比例卡片、40 高语音按钮）被撑破。
- 两个列表页表头的主标题列包在 `FittedBox(fit: scaleDown, alignment: centerLeft)` 里，字号再大也只会等比缩小。
- 新写的固定高度容器，必须假设 `textScaler = 1.4`；能换成 `minHeight` + `FittedBox` 的就别写死高度。

---

## 7. 常见任务手册

### 7.1 新增一个国家

1. `lib/screens/catalog_page.dart` 的 `_nations` 追加一条 `_Nation(nameZh, nameEn, color)`（顺序决定网格位置）。
2. `lib/screens/character_list_page.dart` 追加 `const List<Character> _xxxCharacters`（**按英文名 A–Z 升序**）。
3. 同一文件的 `_charactersByCountry` 里注册 `'国家名': _xxxCharacters`。
4. 放好 `assets/stories|voices` 资源（见 7.2）。
5. 跑测试：`widget_test.dart` 里「八个国家均显示正确的角色数量」需要同步加一行期望值。

### 7.2 新增一个角色

1. 放资源：`assets/stories/<中文名>.md`、`assets/voices/<中文名>_语音.md`
   （文件名必须与 `zhName` 完全一致，除非加了 7.6 的映射）。
2. 在对应国家的 `const List<Character>` 里按英文名顺序插入一条：
   ```dart
   Character(
     enName: 'Albedo',
     zhName: '阿贝多',
     elementColor: Color(0xFFCC9046),   // 元素标准色，见 5.1
     elementIconPath: 'assets/elements/geo.png',
   ),
   ```
3. 若需要额外的「月轮 / 始基力」图标，在 `character_list_page.dart` 的 `_extraIcons` 里按中文名登记。
4. 验证：`flutter test`；必要时用一个真实资源做一次 `flutter run` 手工点开（缺资源时会显示「未收录」空态）。

### 7.3 新增一个特殊角色分组

在 `other_list_page.dart` 的 `_sections` 里追加 `_OtherSection(title, entries)`；表头「N 位」会自动按 `_totalCount` 求和，无需手改。

### 7.4 只改故事/语音内容

**只改 `.md` 文件，不要动 Dart 代码。** 支持 `#`/`##` 标题、`解锁条件`、`来源页面`、`---`、引用与列表（会被清洗）。
改完不需要重新编译以外的任何操作；但如果是**新增**文件，记得检查 `pubspec.yaml` 的资源目录声明（目录声明已覆盖 `stories/`、`voices/`）。

### 7.5 新增图标

放进 `assets/elements/`（目录已声明），文件名用小写 + 下划线；引用时写完整相对路径。
图标原始尺寸很大（130–250 KB/张），显示时必须给 `width/height` 并设 `cacheWidth`（当前 4 倍密度）。

### 7.6 文件名映射（`zhName` 与文件不同名）

`lib/models/character.dart` 的 `_resolveAssetBaseName` 目前有三条例外，新增特例请加在这里并补注释：

- `「散兵」斯卡拉姆齐` → `流浪者`
- `空` / `荧` → `旅行者`

---

## 8. 测试规范

- 共 **25 个用例**：`character_text_document_test.dart` 12 个（解析器）、`widget_test.dart` 13 个（界面与接线）。
- 视口统一 `1170×2532 @3.0`（`_usePhoneViewport`），否则目录页会在默认 800×600 横屏下溢出。
- **点击按钮后必须按两段 pump**：`SolidGradientButton` 有 110ms 最短按压 + 620/650ms 转场。
  直接用现成的 `_tapSolidButton(tester, finder)`，或 `pump()` → `pump(150ms)` → `pump(900ms)`。
- 已使用的 Key（测试依赖，改名会挂）：
  `character-text-list`、`character-detail-back-button`、`character-voice-back-button`、
  `character-voice-entry-button`、`other-list-back-button`。
- **`>50KB` 资源在 `AssetBundle.loadString` 里会走 isolate**，widget 测试的假时钟等不到它完成。
  因此页面级用例只能选 50KB 以内的资源（现用 `爱可菲_语音.md`，约 17KB），
  极限规模用合成 `CharacterTextDocument`（2000 块）覆盖。
- 断言包含具体样式数值（字号/字重/颜色），改设计就是改测试；**这是有意为之**，别为了省事把断言放宽。
- 不要写依赖真实时间的测试；所有等待都用 `pump(Duration)`。

---

## 9. 性能约定（已做的取舍，别推翻）

| 位置 | 做法 | 原因 |
|---|---|---|
| 极光背景 | 进度量化到 ~30fps；静态暗角独立 `DecoratedBox`；`RepaintBoundary` + `willChange: true` | 每帧要铺 4 个全屏径向渐变 + 96 星点，和正文滚动抢帧预算 |
| 长文渲染 | `ListView.builder` 只构建视口附近块 | 最大一份语音文档约 1942 块，整篇布局会卡顿 |
| 长文块 | `SizedBox(width: double.infinity)` | 还原旧 `Column(stretch)` 的全宽语义（居中的分隔线、标题行 `Expanded` 都依赖它） |
| 图标 | `cacheWidth: 96` | 原图约 3000px，直接解码会占满 `ImageCache` |
| 转场 | 解析延后 650ms | 避免在动画期间做正则清洗 |
| 全局 | 无 `BackdropFilter`/`Opacity` 大面积合成 | 玻璃质感靠颜色透明度实现 |

已知代价（可接受）：转场期间前后两个页面各有一个极光 `AnimationController` 在跑（被覆盖路由的
`TickerMode` 会被框架置为 `false`，因此不会真的重复出帧）。

---

## 10. 已知缺口 / 待办（截至最近一次整理）

- **缺资源**（点进去会显示「未收录」空态，属预期降级，不是 bug）：
  - 国家列表缺 3 位：安娜丝塔夏、达妮卡、诺伊（至冬）——故事与语音都没有；
  - 特殊角色缺 15 条：皮耶罗、卡皮塔诺、多托雷、普契涅拉、席诺拉、潘塔罗涅、纳贝里士、若娜瓦、
    伊斯塔露、阿斯莫代，以及坎瑞亚五大罪人。
- 诺伊的元素色暂用 `Colors.grey`、图标指向 `assets/elements/empty.png`（占位）。
- `README.md` 仍是 Flutter 模板内容。
- 可读性债（不影响功能，改前请权衡）：两个列表页的表头代码约 80 行几乎重复；
  `_GlowIcon` 与 `_ElementIcon` 实现近乎相同；转场代码在 `home_page` / `catalog_page` / `page_routes` 各写一份。
- 竖屏是**硬约束**：目录页是「Column + Spacer + 不可滚动网格」，横屏会溢出。不要移除 `main.dart` 里的锁屏。

---

## 11. 构建与签名（**改动前务必读**）

| 项 | 说明 |
|---|---|
| applicationId | `com.projectgenshin.characters`（`android/app/build.gradle.kts`） |
| namespace | 同上，且必须与 `MainActivity.kt` 的 `package` 一致 |
| keystore | `android/app/upload-keystore.jks`（PKCS12，别名 `genshin`，有效期 10000 天） |
| 密码文件 | `android/key.properties`（`storeFile` 相对 `android/app/`） |
| 版本控制 | `android/.gitignore` 已忽略 `key.properties` 与 `**/*.jks`——**这两个文件不会进仓库，必须单独备份** |
| 兜底 | `key.properties` 缺失时，`build.gradle.kts` 自动退回 debug 签名，保证 `flutter run` 可用 |
| 版本号 | `pubspec.yaml` 的 `version: x.y.z+N`；**每发一版把 N 加 1**，Android 用它判断是否为新版本 |

注意事项：

1. **改 `applicationId` 等于换了一个 App**：旧包不会被覆盖，而是并存成两个应用（数据不互通）。
2. **换签名必须卸载重装**；同一 keystore 才能覆盖升级。
3. 发布构建：`flutter build apk --release`，产物在 `build/app/outputs/flutter-apk/app-release.apk`。
4. 该 keystore 一旦丢失，就无法再发布「可覆盖安装」的更新，只能让用户卸载重装。

---

## 12. 代码风格

- `dart format` 保持默认 80 列；提交前对改动文件跑一次格式化。
- 命名：私有 Widget / 辅助类以 `_` 开头（`_CharacterButton`、`_GlowIcon`）；私有构建方法 `_buildXxx`；
  文件级常量 `_xxx` 或 `class` 内的 `static const`。
- 泛型集合字面量显式写类型：`<Widget>[]`、`<Character>[...]`（全项目一致，别混用）。
- 文件内部顺序：构造函数 → 字段 → 生命周期/方法 → `build()` → 私有构建方法 → 文件级私有 Widget。
- 注释解释取舍与历史原因（例如“为什么这里要 650ms”“为什么这里要拉伸宽度”），不要复述代码。
- 常量优先 `const`；`StatelessWidget` 优先于 `StatefulWidget`。

---

## 13. 提交前检查清单

- [ ] `flutter analyze` 无 issue
- [ ] `flutter test` 25 个用例全绿
- [ ] 新增资源文件已落地，且目录已在 `pubspec.yaml` 声明
- [ ] 新页面有返回入口 + 唯一 Key
- [ ] 没有引入新依赖、新字号、新颜色值
- [ ] 布局在 1.4 倍系统字号下不溢出
- [ ] 没有破坏 `test/` 里已有的断言
- [ ] 若改了架构/约定/构建配置，已同步更新本文件
