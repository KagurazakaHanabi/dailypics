import 'dart:async';
import 'dart:io';

import 'package:daily_pics/widget/adaptive_scaffold.dart';
import 'package:flutter/cupertino.dart';

class SplashPage extends StatefulWidget {
  final File data;

  const SplashPage(this.data, {Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();

  static void push(BuildContext context, File data) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (_, Animation<double> animation, __) {
          return FadeTransition(
            opacity: animation,
            child: SplashPage(data),
          );
        },
      ),
    );
  }
}

class _SplashPageState extends State<SplashPage> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 3), () => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Image.file(widget.data, fit: BoxFit.cover),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
