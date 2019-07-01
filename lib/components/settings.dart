import 'package:flutter/cupertino.dart';

class SettingsComponent extends StatefulWidget {
  @override
  _SettingsComponentState createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(),
    );
  }
}
