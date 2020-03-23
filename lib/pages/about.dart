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

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailypics/misc/bean.dart';
import 'package:dailypics/model/app.dart';
import 'package:dailypics/pages/upload.dart';
import 'package:dailypics/utils/api.dart';
import 'package:dailypics/utils/utils.dart';
import 'package:dailypics/widget/image_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show CircleAvatar, Colors, Divider, ListTile, Scaffold, Theme, ThemeData;
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
          contributors = (jsonDecode(value) as List).map((e) => Contributor.fromJson(e)).toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double padding = SystemUtils.isIPad(context) && !SystemUtils.isPortrait(context)
        ? (size.width - size.height) / 2
        : 0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: CupertinoScrollbar(
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
                middle: const Text('更多'),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('投稿'),
                  onPressed: () => UploadPage.push(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildAppInfo(),
        _buildCollection(),
        const Divider(),
        const Padding(
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: GestureDetector(
                onTap: member.url == null ? null : () => launch(member.url),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: CachedNetworkImageProvider(
                          member.avatar,
                        ),
                      ),
                    ),
                    Text(member.name),
                    Text(
                      member.position,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoDynamicColor.withBrightness(
                          color: Colors.black54,
                          darkColor: Colors.white70,
                        ).resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const Divider(color: Colors.transparent, height: 16),
        Theme(
          data: ThemeData(brightness: CupertinoTheme.of(context).brightness),
          child: Column(
            children: <Widget>[
              ...List<Widget>.generate(
                contributors != null ? contributors.length - 3 : 0,
                (index) {
                  Contributor member = contributors[index + 3];
                  return ListTile(
                    onTap: member.url == null ? null : () => launch(member.url),
                    title: Text(member.name),
                    subtitle: Text(member.position),
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(member.avatar),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('「图鉴日图」用户协议'),
                onTap: () => launch('https://www.dailypics.cn/doc/1'),
                trailing: _buildTrailing(true),
              ),
              ListTile(
                title: const Text('「图鉴日图」隐私政策'),
                onTap: () => launch('https://www.dailypics.cn/doc/2'),
                trailing: _buildTrailing(true),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAppInfo() {
    final String version = packageInfo?.version ?? '0.0.0';
    final String buildNumber = packageInfo?.buildNumber ?? '190000';
    Color textColor = CupertinoDynamicColor.withBrightness(
      color: Colors.black54,
      darkColor: Colors.white70,
    ).resolveFrom(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('res/ic_launcher.png'),
            ),
          ),
          const Text('图鉴日图', style: TextStyle(fontSize: 18)),
          Text(
            '版本号 $version($buildNumber)',
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '无人为孤岛，一图一世界',
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildAction(
                  Ionicons.logo_github,
                  '开源',
                  () => launch(
                    'https://github.com/KagurazakaHanabi/dailypics',
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
                  () => SystemUtils.requestReview(false),
                ),
                _buildAction(
                  Ionicons.ios_chatboxes,
                  '反馈',
                  () => launch('https://support.qq.com/product/120654'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '我的收藏',
            style: TextStyle(fontSize: 22),
          ),
        ),
        SizedBox(
          height: Settings.marked.isEmpty ? 64 : 256,
          child: FutureBuilder(
            future: _fetchData(),
            builder: (BuildContext context, AsyncSnapshot<List<Picture>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (snapshot.data.isEmpty) {
                return const Center(
                  child: Text(
                    '无数据',
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              } else {
                final data = snapshot.data;
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.length,
                  itemBuilder: (_, i) {
                    return ImageCard(
                      data[i],
                      'C-$i-${data[i].id}',
                      padding: const EdgeInsets.all(12),
                      showTexts: false,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          offset: Offset(0, 3),
                          spreadRadius: -16,
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: Color(0x0A000000),
                          offset: Offset(0, 3),
                          spreadRadius: -16,
                          blurRadius: 1,
                        ),
                      ],
                    );
                  },
                );
              }
            },
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
            padding: const EdgeInsets.all(4),
            child: Icon(icon),
          ),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTrailing(bool accepted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Offstage(
          offstage: accepted,
          child: const Text(
            '请阅读并同意',
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
        ),
        const Icon(CupertinoIcons.right_chevron),
      ],
    );
  }

  Future<List<Picture>> _fetchData() async {
    List<Picture> result = [];
    List<String> ids = Settings.marked.reversed.toList();
    if (ids.isEmpty) {
      return result;
    }

    List<Picture> saved = AppModel.of(context).collections;
    if (saved.isNotEmpty) {
      return saved;
    }

    for (int i = 0; i < ids.length; i++) {
      result.add((await TujianApi.getDetails(ids[i]))..marked = true);
    }
    AppModel.of(context).collections = result;
    return result;
  }
}
