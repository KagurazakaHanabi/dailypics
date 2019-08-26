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
  List<Member> members;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() => packageInfo = info);
    });
    DefaultAssetBundle.of(context).loadString('res/members.json').then((s) {
      members = (jsonDecode(s) as List).map((e) => Member.fromJson(e)).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double padding = (size.width - size.height) / 2;
    return Scaffold(
      body: CupertinoScrollbar(
        controller: controller,
        child: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverPadding(
              padding: Device.isIPad(context) && !Device.isPortrait(context)
                  ? EdgeInsets.symmetric(horizontal: padding)
                  : EdgeInsets.zero,
              sliver: SliverToBoxAdapter(
                child: _buildList(),
              ),
            ),
          ],
        ),
      ),
      appBar: CupertinoNavigationBar(
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
      ),
    );
  }

  Widget _buildList() {
    final String prefix = 'res/avatars/';
    return Column(
      children: <Widget>[
        _buildHeader(),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 8, bottom: 32),
          child: Text(
            '团队信息',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(members != null ? 3 : 0, (i) {
            Member member = members[i];
            return GestureDetector(
              onTap: member.url == null ? null : () => launch(member.url),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
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
            );
          }),
        ),
        Divider(color: Colors.transparent, height: 32),
        Column(
          children: List<Widget>.generate(
            members != null ? members.length - 3 : 0,
            (index) {
              Member member = members[index + 3];
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

  Widget _buildHeader() {
    final String appName = packageInfo?.appName ?? '';
    final String version = packageInfo?.version ?? '';
    final String buildNumber = packageInfo?.buildNumber ?? '';
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('res/ic_launcher.png'),
          ),
        ),
        Text(
          appName,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          '版本号 $version($buildNumber)',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        ),
        Text(
          '无人为孤岛，一图一世界',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 2.2),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildAction(
                Ionicons.logo_github,
                '开源',
                () => launch('https://github.com/KagurazakaHanabi/daily_pics'),
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
