import 'dart:async';

import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/tools.dart';
import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(C.pref_first, false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Hero(
          tag: '#',
          child: Image.asset('res/Icon-App-40x40@3x.png'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chevron_right),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _InternalPage()),
          );
        },
      ),
    );
  }
}

class _InternalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InternalPageState();
}

class _InternalPageState extends State<_InternalPage> {
  bool _willPop = false;
  String _desc = """
　　Tujian 是一款简约的人工精选壁纸软件，每天由维护者们在众多图片中为每个分类挑选出一张，作为今日的精选图片。自项目发起，我们已经收集了大量的优质精选图片。

　　我们的想法及理念「无人为孤岛，一图一世界」。这句话出自《岛上书店》中的「无人为孤岛，一书一世界」，因此，我们希望图片，优质的图片，能够作为一种艺术来深深的感染您。

　　Tujian 中的图片并非用于商业用途，若您认为 Tujian 存在侵权行为，请联系我们。
  """;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(_willPop),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(left: 32, right: 32, bottom: 16),
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Hero(
                      tag: '#',
                      child: Image.asset('res/Icon-App-1024x1024@1x.png'),
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
                      Tools.safeLaunch('https://dpic.dev/licenses/privacy');
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
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
