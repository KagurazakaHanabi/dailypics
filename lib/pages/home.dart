import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:daily_pics/components/archive.dart';
import 'package:daily_pics/components/viewer.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/events.dart';
import 'package:daily_pics/misc/tools.dart';
import 'package:daily_pics/pages/archive.dart';
import 'package:daily_pics/pages/settings.dart';
import 'package:daily_pics/pages/welcome.dart';
import 'package:daily_pics/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons/material_design_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

String _initial = '';
String _shopping = 'taobao://item.taobao.com/item.htm?id=588056088134';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  PageController _pageCtrl = PageController();
  int _index = 0;
  Picture _data;
  bool _transAppBar = false;

  @override
  void initState() {
    super.initState();
    // FIXME: 2019/3/4 Yaerin: 无法在启动时修改 PageView 的 index
    // WidgetsBinding.instance.addPostFrameCallback((_) => _setType(_index));
    SharedPreferences.getInstance().then((prefs) async {
      setState(() => _transAppBar = prefs?.getBool('trans') ?? false);
      if (prefs.getBool(C.pref_first) ?? true) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => WelcomePage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
      if (prefs.getBool(C.pref_night) ?? false) {
        ThemeModel.of(context).theme = Themes.night;
      } else {
        switch (prefs.getInt(C.pref_theme) ?? C.theme_normal) {
          case C.theme_amoled:
            ThemeModel.of(context).theme = Themes.amoled;
        }
      }
    });
    Tools.fetchText().then((val) => _initial = val);
    eventBus.on<ReceivedDataEvent>().listen((event) {
      if (event.from == _index) {
        setState(() => _data = event.data);
      }
    });
    _checkUpdate();
  }

  @override
  Widget build(BuildContext context) {
    double extent = kToolbarHeight + MediaQuery.of(context).padding.top;
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: _transAppBar
                ? EdgeInsets.zero
                : EdgeInsets.only(top: kToolbarHeight),
            child: PageView(
              controller: _pageCtrl,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                ViewerComponent(C.type_chowder, 0),
                ViewerComponent(C.type_illus, 1),
                ViewerComponent(C.type_bing, 2),
                ArchiveComponent(C.type_desktop),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: extent),
            child: FlexibleSpaceBar.createSettings(
              currentExtent: extent,
              child: _buildAppBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    Widget leading = IconButton(
      icon: Icon(Icons.menu),
      onPressed: () => _scaffoldKey.currentState.openDrawer(),
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    );
    Widget title = Text(_index != 3 ? _data?.title ?? '' : '归档: 桌面');
    List<Widget> actions = <Widget>[
      PopupMenuButton<int>(
        onSelected: _onMenuSelected,
        itemBuilder: (_) => _buildMenus(),
      ),
    ];
    if (_transAppBar) {
      return _AppBar(
        color: Colors.white,
        leading: leading,
        title: title,
        actions: _index == 3 ? null : actions,
      );
    } else {
      return AppBar(
        leading: leading,
        title: title,
        actions: _index == 3 ? null : actions,
      );
    }
  }

  List<PopupMenuEntry<int>> _buildMenus() {
    List<PopupMenuEntry<int>> entries = [];
    entries.add(PopupMenuItem<int>(child: Text('查看归档'), value: 0));
    entries.add(PopupMenuItem<int>(child: Text('下载原图'), value: 1));
    if (Platform.isAndroid) {
      entries.add(PopupMenuItem<int>(child: Text('设为壁纸'), value: 2));
    }
    entries.add(PopupMenuItem<int>(child: Text('分享到...'), value: 3));
    return entries;
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListTileTheme(
          selectedColor: Theme.of(context).accentColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: Image.asset('res/ic_launcher-web.png'),
                accountName: Text('Tujian R'),
                accountEmail: Text('无人为孤岛，一图一世界。'),
              ),
              ListTile(
                leading: Icon(MdiIcons.widgets),
                title: Text('杂烩'),
                onTap: () => _setIndex(0),
                selected: _index == 0,
              ),
              ListTile(
                leading: Icon(MdiIcons.drawing),
                title: Text('插画'),
                onTap: () => _setIndex(1),
                selected: _index == 1,
              ),
              Divider(),
              ListTile(
                leading: Icon(MdiIcons.bing),
                title: Text('必应'),
                onTap: () => _setIndex(2),
                selected: _index == 2,
              ),
              ListTile(
                leading: Icon(MdiIcons.monitor),
                title: Text('桌面'),
                onTap: () => _setIndex(3),
                selected: _index == 3,
              ),
              ListTile(
                leading: Icon(MdiIcons.text),
                title: Text('一句'),
                onTap: () {
                  showDialog(context: context, builder: (_) => _TextDialog());
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(MdiIcons.telegram),
                title: Text('推送'),
                onTap: () => Tools.safeLaunch('https://t.me/Tujiansays'),
              ),
              ListTile(
                leading: Icon(MdiIcons.qqchat),
                title: Text('群组'),
                onTap: () async {
                  String uri = 'mqqapi://card/show_pslcard?src_type=internal&'
                      'verson=1&uin=472863370&card_type=group&source=qrcode';
                  if (await canLaunch(uri)) {
                    launch(uri);
                  } else {
                    launch('https://jq.qq.com/?_wv=1027&k=5RQibWy');
                  }
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.cloud_upload),
                title: Text('投稿'),
                onTap: () {
                  /*Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => UploadPage()),
                );*/
                  Tools.safeLaunch('https://dpic.dev/tg');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(MdiIcons.settings),
                title: Text('设置'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SettingsPage()),
                  );
                },
              ),
              Offstage(
                offstage: Platform.isIOS,
                child: ListTile(
                  leading: Icon(MdiIcons.shopping),
                  title: Text('周边'),
                  onTap: () async {
                    if (await canLaunch(_shopping)) {
                      launch(_shopping);
                    } else {
                      launch(_shopping.replaceFirst('taobao', 'https'));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _setIndex(int index) {
    _data = null;
    eventBus.fire(OnPageChangedEvent(index));
    setState(() => _index = index);
    _pageCtrl.jumpToPage(index);
    Navigator.of(context).pop();
    if (index != 0 && index != 1) return;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(C.pref_page, index));
  }

  String _convertIndexToType(int index) {
    switch (index) {
      case 0:
        return C.type_chowder;
      case 1:
        return C.type_illus;
      case 2:
        return C.type_bing;
      case 3:
        return C.type_desktop;
      default:
        return null;
    }
  }

  void _onMenuSelected(int index) async {
    switch (index) {
      case C.menu_view_archive:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return ArchivePage(_convertIndexToType(_index));
          }),
        );
        break;
      case C.menu_download:
      case C.menu_set_wallpaper:
        Tools.fetchImage(context, _data, index == C.menu_set_wallpaper);
        break;
      case C.menu_share:
        Tools.share(_data);
        break;
    }
  }

  void _checkUpdate() async {
    if (!Platform.isAndroid) return;
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(
      'https://aus.nowtime.cc/api/query/update?appid=10831',
    ));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    dynamic data = jsonDecode(body);
    String buildNumber = (await PackageInfo.fromPlatform()).buildNumber;
    if ((data['version_code'] ?? 0) > (int.tryParse(buildNumber) ?? 0)) {
      showDialog(
        context: context,
        builder: (_) {
          return _UpdateDialog(
            data['update_log'],
            data['apk_url'],
            data['version_name'],
          );
        },
      );
    }
  }
}

class _AppBar extends StatelessWidget {
  final Color color;

  final Widget leading;

  final Widget title;

  final List<Widget> actions;

  _AppBar({this.color, this.leading, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    double statusBar = window.padding.top / window.devicePixelRatio;
    ThemeData theme = Theme.of(context);
    return Container(
      color: Colors.black26,
      margin: EdgeInsets.only(top: statusBar),
      height: kToolbarHeight,
      child: IconTheme.merge(
        data: theme.primaryIconTheme.copyWith(color: color),
        child: Row(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: kToolbarHeight),
              child: leading,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: DefaultTextStyle(
                  style: theme.primaryTextTheme.title.copyWith(color: color),
                  child: title,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: actions ?? [],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  final String content;

  final String url;

  final String version;

  _UpdateDialog(this.content, this.url, this.version);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('发现可用的更新: v$version'),
      content: Text(content),
      actions: <Widget>[
        FlatButton(
          child: Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text('去往酷安'),
          onPressed: () => Tools.safeLaunch(url),
        ),
      ],
    );
  }
}

class _TextDialog extends StatefulWidget {
  @override
  _TextDialogState createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('一句'),
      content: Text(content ?? _initial),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      actions: <Widget>[
        FlatButton(
          child: Text('复制'),
          onPressed: () => Clipboard.setData(ClipboardData(text: content)),
        ),
        FutureButton(
          child: Text('然后'),
          onPressed: () async {
            content = await Tools.fetchText();
            setState(() {});
          },
        ),
        FlatButton(
          child: Text('阅毕'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
