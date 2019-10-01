import 'dart:async';
import 'dart:io';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/pages/home.dart';
import 'package:daily_pics/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  File _file;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchOrShowSplash();
  }

  @override
  Widget build(BuildContext context) {
    if (_file == null) {
      return CupertinoPageScaffold(
        child: Container(),
      );
    }
    return CupertinoPageScaffold(
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Image.file(
          _file,
          fit: BoxFit.cover,
          frameBuilder: (_, Widget child, int frame, bool synchronouslyLoaded) {
            if (synchronouslyLoaded) return child;
            return AnimatedOpacity(
              child: child,
              curve: Curves.easeOut,
              opacity: frame == null ? 0 : 1,
              duration: Duration(milliseconds: 300),
            );
          },
        ),
      ),
    );
  }

  Future<void> _fetchOrShowSplash() async {
    Splash splash = await TujianApi.getSplash();
    String url = splash.imageUrl;
    DateTime now = DateTime.now();
    if (now.isAfter(splash.effectiveAt) && now.isBefore(splash.expiresAt)) {
      DefaultCacheManager manager = DefaultCacheManager();
      FileInfo info = await manager.getFileFromCache(url);
      if (info != null) {
        setState(() => _file = info.file);
        _timer = Timer(Duration(seconds: 3), () => HomePage.push(context));
        return;
      } else {
        manager.downloadFile(url);
      }
    }
    HomePage.push(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
