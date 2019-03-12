import 'package:daily_pics/misc/tools.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons/material_design_icons.dart';

class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  String _repo = 'https://github.com/KagurazakaHanabi/daily_pics';
  String _about = """
　　图鉴是一款简洁的壁纸推荐软件，有杂烩（摄影）、插画（二次元）以及桌面壁纸三个分类。均由人工从 Pixiv、酷安、Unsplash 等网站摘取而来，经过精挑细选，会更适合用作壁纸。

　　在经历常常找壁纸无果后，我和我的朋友们开发出了这样一款应用，希望你能喜欢。

　　在本应用的开发过程中，特此感谢 @Createlite、@Gadgetry、@Copyright³、@Chimon、@神楽坂花火以及项目运营 @Galentwww。
  """;

  @override
  Widget build(BuildContext context) {
    EdgeInsets windowPadding = MediaQuery.of(context).padding;
    Color color = Theme
        .of(context)
        .primaryColor;
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
                padding: windowPadding + EdgeInsets.fromLTRB(0, 28, 8, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset('res/ic_launcher-web.png', width: 96),
                    Text(
                      '「无人为孤岛，一图一世界」',
                      style: TextStyle(color: textColor, fontSize: 16),
                    ),
                    Text('v2.5β', style: TextStyle(color: textColor)),
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
