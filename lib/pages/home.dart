import 'package:daily_pics/components/recent.dart';
import 'package:daily_pics/components/settings.dart';
import 'package:daily_pics/components/suggest.dart';
import 'package:daily_pics/components/today.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final List<Widget> _tabs = [
    TodayComponent(),
    RecentComponent(),
    SuggestComponent(),
    //SettingsComponent(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  BottomNavigationBarItem _buildNavigationItem(IconData icon, String title) {
    return BottomNavigationBarItem(icon: Icon(icon), title: Text(title));
  }

  @override
  void didChangeMetrics() => setState(() {});
}
