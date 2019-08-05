import 'dart:async';

import 'package:daily_pics/components/recent.dart';
import 'package:daily_pics/components/settings.dart';
import 'package:daily_pics/components/suggest.dart';
import 'package:daily_pics/components/today.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _tabs = [
    TodayComponent(),
    RecentComponent(),
    SuggestComponent(),
    //SettingsComponent(),
  ];

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    getInitialUri().then(_handleUniLink);
    _subscription = getUriLinksStream().listen(_handleUniLink);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          _buildNavigationItem(Ionicons.ios_today, 'Today'),
          _buildNavigationItem(Ionicons.ios_time, '以往'),
          _buildNavigationItem(Ionicons.ios_flame, '推荐 '),
          //_buildNavigationItem(Ionicons.ios_settings, '更多'),
        ],
      ),
      tabBuilder: (_, i) {
        return CupertinoTabView(builder: (_) => _tabs[i]);
      },
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
    switch(uri.host) {
      case 'p': {
        DetailsPage.push(context, pid: uuid);
        break;
      }

      case 't': {
        // TODO: 2019-07-26 Yaerin: Support tujian://t/$tid
        break;
      }
    }
  }
}
