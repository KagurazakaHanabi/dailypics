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
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => _prefs = prefs);
      // 兼容 2.5.8 及以前的版本
      try {
        bool b = prefs.getBool(C.pref_theme);
        if (b != null) prefs.remove(C.pref_theme);
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        padding: EdgeInsets.only(top: 8),
        children: <Widget>[
          ListTile(
            title: Text('主题风格'),
            subtitle: Text(_getTheme()),
            onTap: () async {
              ThemeData theme = await showDialog(
                context: context,
                builder: (_) {
                  return ListTileTheme(
                    contentPadding: EdgeInsets.only(left: 24, right: 16),
                    child: SimpleDialog(
                      title: Text('主题风格'),
                      children: <Widget>[
                        ListTile(
                          title: Text('默认白'),
                          onTap: () {
                            _setBool(C.pref_night, false);
                            _setInt(C.pref_theme, C.theme_normal);
                            Navigator.of(context).pop(Themes.normal);
                          },
                        ),
                        ListTile(
                          title: Text('A 屏黑'),
                          onTap: () {
                            _setBool(C.pref_night, false);
                            _setInt(C.pref_theme, C.theme_amoled);
                            Navigator.of(context).pop(Themes.amoled);
                          },
                        ),
                        ListTile(
                          title: Text('自适应 (Experimental)'),
                          onTap: () {
                            _setBool(C.pref_night, false);
                            _setInt(C.pref_theme, C.theme_auto);
                            ThemeModel model = ThemeModel.of(context);
                            model.theme = model.previous;
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
              if (theme != null) {
                ThemeModel.of(context).theme = theme;
              }
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('夜间模式', style: TextStyle(fontSize: 12)),
                Switch(
                  value: _prefs?.getBool(C.pref_night) ?? false,
                  onChanged: (val) {
                    _setBool(C.pref_night, val);
                    ThemeModel model = ThemeModel.of(context);
                    if (val) {
                      model.theme = Themes.night;
                    } else {
                      model.theme = model.previous;
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          SwitchListTile(
            value: _prefs?.getBool('trans') ?? false,
            onChanged: (val) => setState(() => _setBool('trans', val)),
            title: Text('透明 AppBar'),
            subtitle: Text('重启应用生效'),
          ),
          SwitchListTile(
            value: _prefs?.getBool(C.pref_debug) ?? false,
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

  String _getTheme() {
    switch (_prefs?.getInt(C.pref_theme) ?? 0) {
      case 1:
        return 'A 屏黑';
      case 2:
        return '自适应 (Experimental)';
      case 0:
      default:
        return '默认白';
    }
  }

  void _setBool(String key, bool value) {
    _prefs.setBool(key, value);
  }

  void _setInt(String key, int value) {
    _prefs.setInt(key, value);
  }
}
