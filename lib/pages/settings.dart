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
        children: <Widget>[
          SwitchListTile(
            value: _pref?.getBool('pick_color') ?? false,
            onChanged: (val) => setState(() => _setBool('pick_color', val)),
            title: Text('主题适应'),
            subtitle: Text('主题将自动变更'),
          ),
          SwitchListTile(
            value: _pref?.getBool('debug') ?? false,
            onChanged: (val) => setState(() => _setBool('debug', val)),
            title: Text('调试模式'),
            subtitle: Text('将会显示堆栈信息'),
          )
        ],
      ),
    );
  }

  void _setBool(String key, bool value) {
    _pref.setBool(key, value);
  }
}