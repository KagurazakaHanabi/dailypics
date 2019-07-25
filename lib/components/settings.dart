import 'package:daily_pics/pages/upload.dart';
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
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('投稿'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(builder: (_) => UploadPage()),
            );
          },
        ),
      ),
      child: ListView(
        children: <Widget>[],
      ),
    );
  }
}
