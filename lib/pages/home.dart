import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:daily_pics/components/archive.dart';
import 'package:daily_pics/components/viewer.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/events.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/pages/archive.dart';
import 'package:daily_pics/pages/settings.dart';
import 'package:daily_pics/pages/welcome.dart';
import 'package:daily_pics/widgets/buttons.dart';
import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons/material_design_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

String _initial = '';
String _donate = '''
　　众所周知，Tujian 是一个公益项目。随着用户的增加、图片收录数量等方面的问题，Tujian 服务器已经不堪重负...

　　因此，经过 第 3195 次 Tujian 事务所 圆桌会议，我们决定放一个微信收款二维码...欢迎捐赠以支持 Tujian 发展
''';
String _final = '''
　　由于业务发展需要以及一直以来的亏本运营，图鉴事务所决定即日起终止对 Tujian R 的维护及后续更新，但仍会在短时间内支持查看每日日图等服务，Tujian X 会继续维护更新。若您想继续正常使用 Tujian 及其全部服务，请安装 Tujian X。感谢您一直以来对 Tujian R 的陪伴！

　　无人为孤岛，一图一世界。
''';

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
    Utils.fetchText().then((val) => _initial = val);
    eventBus.on<ReceivedDataEvent>().listen((event) {
      if (event.from == _index) {
        setState(() => _data = event.data);
      }
    });
    _makeCaches();
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
    if (_data != null) {
      entries.add(PopupMenuItem<int>(child: Text('下载原图'), value: 1));
    }
    if (Platform.isAndroid && _data != null) {
      entries.add(PopupMenuItem<int>(child: Text('设为壁纸'), value: 2));
    }
    if (_data != null) {
      entries.add(PopupMenuItem<int>(child: Text('分享到...'), value: 3));
    }
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
                onTap: () => Utils.safeLaunch('https://t.me/Tujiansays'),
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
                  Utils.safeLaunch('https://dpic.dev/tg');
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
        Utils.fetchImage(context, _data, false);
        break;
      case C.menu_set_wallpaper:
        Utils.fetchImage(context, _data, true);
        break;
      case C.menu_share:
        Utils.share(_data);
        break;
    }
  }

  // TODO: 2019/5/9 Yaerin: 等待测试
  void _makeCaches() async {
    Uri uri = Uri.parse('https://dp.chimon.me/api/today.php');
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    String json = await response.transform(utf8.decoder).join();
    String cacheDir = (await getTemporaryDirectory()).path;
    File file = File('$cacheDir/today.json');
    file.writeAsStringSync(json);
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
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black26,
      ));
    }
    double statusBar = window.padding.top / window.devicePixelRatio;
    ThemeData theme = Theme.of(context);
    return Container(
      color: Colors.black26,
      margin: EdgeInsets.only(top: Platform.isIOS ? 0 : statusBar),
      padding: EdgeInsets.only(top: Platform.isIOS ? statusBar : 0),
      height: kToolbarHeight + statusBar,
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

class _TextDialog extends StatefulWidget {
  @override
  _TextDialogState createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  String content;

  @override
  Widget build(BuildContext context) {
    if (content == null) content = _initial;
    return AlertDialog(
      title: Text('一句'),
      content: Text(content),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      actions: <Widget>[
        FlatButton(
          child: Text('复制'),
          onPressed: () {
            Toast(context, '已复制到剪贴板').show();
            Clipboard.setData(ClipboardData(text: content));
          },
        ),
        FutureButton(
          child: Text('然后'),
          onPressed: () async {
            content = await Utils.fetchText();
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

  @override
  void dispose() {
    super.dispose();
    Utils.fetchText().then((text) => _initial = text);
  }
}
