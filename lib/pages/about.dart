import 'dart:convert';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show CircleAvatar, Colors, Divider, ListTile, Scaffold;
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => AboutPage()),
    );
  }
}

class _AboutPageState extends State<AboutPage> {
  ScrollController controller = ScrollController();

  PackageInfo packageInfo;
  List<Contributor> contributors;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() => packageInfo = info);
    });
    DefaultAssetBundle.of(context).loadString('res/contributors.json').then(
      (String value) {
        setState(() {
          contributors = (jsonDecode(value) as List)
              .map((e) => Contributor.fromJson(e))
              .toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double padding = Device.isIPad(context) && !Device.isPortrait(context)
        ? (size.width - size.height) / 2
        : 0;
    return Scaffold(
      body: CupertinoScrollbar(
        controller: controller,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: controller,
              padding: MediaQuery.of(context).padding,
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 44, padding, 0),
                child: _buildList(),
              ),
            ),
            CupertinoNavigationBar(
              /*padding: EdgeInsetsDirectional.zero,
              leading: CupertinoButton(
                child: Icon(CupertinoIcons.back),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
              ),*/
              middle: Text('关于'),
              /*trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('测试入口'),
                onPressed: () => UserSpacePage.push(context),
              ),*/
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final String prefix = 'res/avatars/';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildAppInfo(),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Text(
            '团队信息',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(contributors != null ? 3 : 0, (i) {
            Contributor member = contributors[i];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: GestureDetector(
                onTap: member.url == null ? null : () => launch(member.url),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: AssetImage(prefix + member.assetName),
                      ),
                    ),
                    Text(member.name),
                    Text(
                      member.position,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        Divider(color: Colors.transparent, height: 16),
        Column(
          children: List<Widget>.generate(
            contributors != null ? contributors.length - 3 : 0,
            (index) {
              Contributor member = contributors[index + 3];
              return ListTile(
                onTap: member.url == null ? null : () => launch(member.url),
                title: Text(member.name),
                subtitle: Text(member.position),
                leading: CircleAvatar(
                  backgroundImage: AssetImage(prefix + member.assetName),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildAppInfo() {
    final String appName = packageInfo?.appName ?? '';
    final String version = packageInfo?.version ?? '';
    final String buildNumber = packageInfo?.buildNumber ?? '';
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('res/ic_launcher.png'),
            ),
          ),
          Text(appName, style: TextStyle(fontSize: 18)),
          Text(
            '版本号 $version($buildNumber)',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '无人为孤岛，一图一世界',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildAction(
                  Ionicons.logo_github,
                  '开源',
                  () => launch(
                    'https://github.com/KagurazakaHanabi/daily_pics',
                  ),
                ),
                _buildAction(
                  Ionicons.ios_link,
                  '官网',
                  () => launch('https://www.dailypics.cn/'),
                ),
                _buildAction(
                  Ionicons.ios_star_half,
                  '评分',
                  () => Utils.requestReview(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String title, GestureTapCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(4),
            child: Icon(icon),
          ),
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
