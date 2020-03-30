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

import 'package:dailypics/extension.dart';
import 'package:dailypics/components/suggest.dart';
import 'package:dailypics/components/today.dart';
import 'package:dailypics/pages/about.dart';
import 'package:dailypics/pages/recent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';

class HomePage extends StatelessWidget {

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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CupertinoTheme.of(context).barBackgroundColor.isDark
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
        tabBuilder: (_, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(builder: (_) => TodayComponent());
            case 1:
              return CupertinoTabView(builder: (_) => RecentPage());
            case 2:
              return CupertinoTabView(builder: (_) => SuggestComponent());
            case 3:
              return CupertinoTabView(builder: (_) => AboutPage());
            default:
              return null;
          }
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationItem(IconData icon, String title) {
    return BottomNavigationBarItem(icon: Icon(icon), title: Text(title));
  }
}
