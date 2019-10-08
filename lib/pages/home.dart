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

import 'package:daily_pics/components/suggest.dart';
import 'package:daily_pics/components/today.dart';
import 'package:daily_pics/pages/about.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:daily_pics/pages/recent.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  static void push(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(pageBuilder: (_, Animation<double> animation, __) {
        return FadeTransition(
          opacity: animation,
          child: HomePage(),
        );
      }),
    );
  }
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _tabs = [
    TodayComponent(),
    RecentPage(),
    SuggestComponent(),
    AboutPage(),
  ];

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = getUriLinksStream().listen(_handleUniLink);
    getInitialUri().then(_handleUniLink);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Utils.isDarkColor(CupertinoTheme.of(context).barBackgroundColor)
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: CupertinoTabScaffold(
        resizeToAvoidBottomInset: false,
        tabBar: CupertinoTabBar(
          items: [
            _buildNavigationItem(Ionicons.ios_today, 'Today'),
            _buildNavigationItem(Ionicons.ios_time, '以往'),
            _buildNavigationItem(Ionicons.ios_flame, '推荐 '),
            _buildNavigationItem(Ionicons.ios_settings, '更多'),
          ],
        ),
        tabBuilder: (_, i) {
          return CupertinoTabView(builder: (_) => _tabs[i]);
        },
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  BottomNavigationBarItem _buildNavigationItem(IconData icon, String title) {
    return BottomNavigationBarItem(icon: Icon(icon), title: Text(title));
  }

  void _handleUniLink(Uri uri) {
    if (uri == null) return;
    String uuid = uri.path.substring(1);
    switch (uri.host) {
      case 'p':
        DetailsPage.push(context, pid: uuid);
        break;

      case 't':
        RecentPage.push(context, tid: uuid);
        break;
    }
  }
}
