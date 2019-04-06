import 'package:daily_pics/main.dart';
import 'package:daily_pics/pages/about.dart';
import 'package:daily_pics/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences _pref;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((pref) => setState(() => _pref = pref));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        padding: EdgeInsets.only(top: 8),
        children: <Widget>[
          SwitchListTile(
            value: _pref?.getBool(C.pref_theme) ?? false,
            onChanged: (val) {
              _setBool(C.pref_theme, val);
              ThemeModel model = ThemeModel.of(context);
              if (val) {
                _setBool(C.pref_night, !val);
                model.theme = model.previous;
              }
              setState(() {});
            },
            title: Text('主题适应'),
            subtitle: Text('主题将自动变更（取色时会卡死，等待修复）'),
          ),
          SwitchListTile(
            value: _pref?.getBool(C.pref_night) ?? false,
            onChanged: (val) {
              _setBool(C.pref_night, val);
              ThemeModel model = ThemeModel.of(context);
              if (val) {
                model.theme = Themes.night;
                _setBool(C.pref_theme, !val);
              } else {
                model.theme = model.previous;
              }
              setState(() {});
            },
            title: Text('夜间主题'),
            subtitle: Text('与主题适应冲突'),
          ),
          SwitchListTile(
            value: _pref?.getBool(C.pref_debug) ?? false,
            onChanged: (val) => setState(() => _setBool(C.pref_debug, val)),
            title: Text('调试模式'),
            subtitle: Text('将会显示堆栈信息'),
          ),
          ListTile(
            title: Text('欢迎页'),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => WelcomePage(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text('关于'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _setBool(String key, bool value) {
    _pref.setBool(key, value);
  }
}
