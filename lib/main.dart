import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_page.dart';

/// 全局状态栏样式：透明背景 + 白色图标。
///
/// 通过 MaterialApp.builder 统一注入 [AnnotatedRegion]，所有页面共享同一套
/// 沉浸式状态栏样式，避免在每个页面里重复配置。
const SystemUiOverlayStyle _transparentStatusBar = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 内容延伸到状态栏 / 导航栏之下，配合透明状态栏实现全屏沉浸效果。
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(_transparentStatusBar);

  // 全局锁定竖屏。
  //
  // 目录页是「Column + Spacer + 不可滚动网格」的整屏布局，横屏时高度不足会溢出；
  // 长文阅读、极光背景与卡片尺寸也都是按竖屏设计的，因此统一锁定竖屏。
  SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(const GenshinApp());
}

class GenshinApp extends StatelessWidget {
  const GenshinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Impact Characters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        // ------------------------------------------------------------------
        // alreadyTODO: 在这里配置原神字体 assets 并在 pubspec.yaml 引入
        //
        // 1. 将字体文件放到 assets/fonts/ 目录（例如 GenshinFont-Regular.ttf）；
        // 2. 在 pubspec.yaml 的 flutter.fonts 中声明：
        //      fonts:
        //        - family: GenshinFont
        //          fonts:
        //            - asset: assets/fonts/GenshinFont-Regular.ttf
        // 3. 字体声明完成后，此处的 fontFamily 会自动生效，无需修改代码。
        // ------------------------------------------------------------------
        fontFamily: 'GenshinFont',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9CC4FF),
          secondary: Color(0xFF7FE6D0),
          surface: Color(0xFF0A1A3A),
        ),
        // 玻璃质感的按钮统一由 GestureDetector + 缩放反馈实现，
        // 关闭 Material 默认的水波纹，避免破坏通透感。
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      builder: (context, child) {
        // 大字号无障碍：保留系统「字体大小」设置，但限制放大倍率。
        //
        // 页面上有多处按固定尺寸排版的元素（64 高的列表表头、黄金比例卡片、
        // 40 高的语音入口按钮），系统字号放大到 1.5 倍以上就会溢出。
        // 这里把倍率夹在 0.8~1.4：确实调大字号的用户仍然能看到更大的字，
        // 同时不会把这类固定区域撑破。
        final MediaQueryData media = MediaQuery.of(context);

        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.4,
            ),
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: _transparentStatusBar,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const HomePage(),
    );
  }
}
