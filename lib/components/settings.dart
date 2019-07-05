import 'package:flutter/cupertino.dart';

class SettingsComponent extends StatefulWidget {
  @override
  _SettingsComponentState createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('更多'),
      ),
      child: ListView(
        children: <Widget>[],
      ),
    );
  }
}
