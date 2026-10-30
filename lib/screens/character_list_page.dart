import 'package:flutter/material.dart';

/// 角色列表页（占位）。
///
/// 纯黑背景、居中白色标题，左上角使用标准 [BackButton]。
/// 该页面通过普通的 Navigator.push 进入，因此系统返回键与
/// 安卓侧滑返回手势都能正常 pop。
class CharacterListPage extends StatelessWidget {
  const CharacterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const Center(
              child: Text(
                '角色列表',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 6,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: BackButton(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
