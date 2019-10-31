// Copyright 2019 KagurazakaHanabi<i@yaerin.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dailypics/misc/bean.dart';
import 'package:dailypics/model/app.dart';
import 'package:dailypics/pages/home.dart';
import 'package:dailypics/utils/api.dart';
import 'package:dailypics/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  ImageFrameBuilder _frameBuilder = (_, Widget child, int frame, bool loaded) {
    if (loaded) return child;
    return AnimatedOpacity(
      child: child,
      curve: Curves.easeOut,
      opacity: frame == null ? 0 : 1,
      duration: Duration(milliseconds: 300),
    );
  };

  File _file;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _initial();
  }

  Future<void> _initial() async {
    _timer = Timer(Duration(seconds: 3), () => HomePage.push(context));
    List<dynamic> results = await Future.wait([
      TujianApi.getTypes(),
      Settings.initial(),
      _fetchOrShowSplash(),
    ]);
    AppModel.of(context).types = results[0];
    if (_file == null) {
      _timer.cancel();
      HomePage.push(context);
    }
  }

  Future<void> _fetchOrShowSplash() async {
    Splash splash = await TujianApi.getSplash();
    String url = splash.imageUrl;
    DateTime now = DateTime.now();
    if (now.isAfter(splash.effectiveAt) && now.isBefore(splash.expiresAt)) {
      DefaultCacheManager manager = DefaultCacheManager();
      FileInfo info = await manager.getFileFromCache(url);
      if (info != null) {
        return setState(() => _file = info.file);
      } else {
        manager.downloadFile(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_file == null) {
      return CupertinoPageScaffold(
        child: Container(),
      );
    }
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          Image.file(
            _file,
            fit: BoxFit.cover,
            frameBuilder: _frameBuilder,
          ),
          if (SystemUtils.isIPad(context))
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Image.file(
                  _file,
                  fit: BoxFit.contain,
                  frameBuilder: _frameBuilder,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
