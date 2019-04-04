import 'package:daily_pics/misc/tools.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons/material_design_icons.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  String _repo = 'https://github.com/KagurazakaHanabi/daily_pics';
  String _about = """
　　Tujian 是我在经历数次找壁纸无果后，与几个朋友共同完成的一款精选图片壁纸软件，每日两张，两个分类，两种风味。

　　虽然每一天选出的图片至多只有三张，但是全部是投稿者和维护者们的精挑细选。

　　虽然小众，希望大众。希望你能在享受图片的同时，将 Tujian 也推荐给你的好友，一千个人眼中一千个哈姆雷特，让图片更有内涵。

　　本应用开发过程中，感谢 @Createlite、@Gadgetry、@Copyright³、@Chimon、@神楽坂花火、@浦东吃西瓜以及项目运营 @Galentwww。
  """;
  String _versionName = '0.0.0';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((info) => setState(() => _versionName = info.version));
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets windowPadding = MediaQuery.of(context).padding;
    Color color = Theme.of(context).primaryColor;
    Color textColor;
    if (color.red * 0.299 + color.green * 0.578 + color.blue * 0.114 >= 192) {
      textColor = Colors.black;
    } else {
      textColor = Colors.white;
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 216,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(MdiIcons.github_circle),
                onPressed: () => Tools.safeLaunch(_repo),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Padding(
                padding: windowPadding + EdgeInsets.only(top: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image.asset('res/ic_launcher-web.png', width: 96),
                    Text(
                      '「无人为孤岛，一图一世界」',
                      style: TextStyle(color: textColor, fontSize: 16),
                    ),
                    Text('v$_versionName', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              Padding(padding: EdgeInsets.all(16), child: Text(_about)),
            ]),
          ),
        ],
      ),
    );
  }
}
