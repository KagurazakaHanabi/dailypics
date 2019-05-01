import 'dart:async';

import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: light ? Colors.white : null,
      body: Center(
        child: Hero(
          tag: '#',
          child: Image.asset(
            light ? 'res/ic_app_dark.png': 'res/ic_app_light.png',
            width: 128,
            height: 128,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chevron_right),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => _InternalPage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
      ),
    );
  }
}

class _InternalPage extends StatelessWidget {
  final String _desc = """
　　Tujian 是一款简约的人工精选壁纸软件，每天由维护者们在众多图片中为每个分类挑选出一张，作为今日的精选图片。自项目发起，我们已经收集了大量的优质精选图片。

　　我们的想法及理念「无人为孤岛，一图一世界」。这句话出自《岛上书店》中的「无人为孤岛，一书一世界」，因此，我们希望图片，优质的图片，能够作为一种艺术来深深的感染您。

　　Tujian 中的图片并非用于商业用途，若您认为 Tujian 存在侵权行为，请联系我们。
  """;

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: light ? Colors.white : null,
        body: Padding(
          padding: EdgeInsets.fromLTRB(32, 40, 32, 16),
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Hero(
                      tag: '#',
                      child: Image.asset(
                        light ? 'res/ic_app_dark.png': 'res/ic_app_light.png',
                        width: 108,
                        height: 108,
                      ),
                    ),
                    Text(
                      'Tujian',
                      style: TextStyle(
                        fontSize: 36,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '无人为孤岛，一图一世界',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(_desc, style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('隐私政策'),
                    onPressed: () {
                      Utils.safeLaunch('https://dpic.dev/licenses/privacy');
                    },
                  ),
                  FlatButton(
                    child: Text('联系我们'),
                    onPressed: () async {
                      String mail = 'mailto:Chimon@Chimon.me';
                      if (await canLaunch(mail)) {
                        launch(mail);
                      } else {
                        Toast(context, '邮箱已复制到剪贴板').show();
                        Clipboard.setData(
                          ClipboardData(text: mail.split(':')[1]),
                        );
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.chevron_right),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool(C.pref_first, false);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
