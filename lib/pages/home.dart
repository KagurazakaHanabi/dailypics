import 'dart:io';

import 'package:daily_pics/components/archive.dart';
import 'package:daily_pics/components/viewer.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/events.dart';
import 'package:daily_pics/misc/plugins.dart';
import 'package:daily_pics/misc/tools.dart';
import 'package:daily_pics/pages/about.dart';
import 'package:daily_pics/pages/archive.dart';
import 'package:daily_pics/pages/settings.dart';
import 'package:daily_pics/widgets/buttons.dart';
import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons/material_design_icons.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _initial = '';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageCtrl = PageController();
  int _index = 0;
  Picture _data;

  @override
  void initState() {
    super.initState();
    // FIXME: 2019/3/4 Yaerin: 无法在启动时修改 PageView 的 index
    /*WidgetsBinding.instance.addPostFrameCallback((_) => _setType(_index));
    SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt(C.pref_page))
        .then((index) => _index = index);*/
    Tools.fetchText().then((val) => _initial = val);
    eventBus.on<ReceivedDataEvent>().listen((event) {
      if (event.from == _index) {
        setState(() => _data = event.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: PageView(
        controller: _pageCtrl,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          ViewerComponent(C.type_chowder, 0),
          ViewerComponent(C.type_illus, 1),
          ArchiveComponent(C.type_desktop),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    List<Widget> actions = <Widget>[
      PopupMenuButton<int>(
        onSelected: _onMenuSelected,
        itemBuilder: (_) => _buildMenus(),
      ),
    ];
    return AppBar(
      title: Text(_index != 2 ? _data?.title ?? '' : '归档: 桌面'),
      actions: _index == 2 ? null : actions,
    );
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
              onTap: () => _setType(0),
              selected: _index == 0,
            ),
            ListTile(
              leading: Icon(MdiIcons.drawing),
              title: Text('插画'),
              onTap: () => _setType(1),
              selected: _index == 1,
            ),
            Divider(),
            ListTile(
              leading: Icon(MdiIcons.monitor),
              title: Text('桌面'),
              onTap: () => _setType(2),
              selected: _index == 2,
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
              onTap: () => Tools.safeLaunch(
                  'mqqapi://card/show_pslcard?src_type=internal&verson=1&uin=47'
                      '2863370&card_type=group&source=qrcode'),
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
            ListTile(
              leading: Icon(MdiIcons.information),
              title: Text('关于'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AboutPage()),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _setType(int index) {
    _data = null;
    eventBus.fire(OnPageChangedEvent(index));
    setState(() => _index = index);
    _pageCtrl.jumpToPage(index);
    Navigator.of(context).pop();
    if (index != 0 && index != 1) return;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(C.pref_page, index));
  }

  void _onMenuSelected(int index) async {
    switch (index) {
      case C.menu_view_archive:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return ArchivePage(_index == 0 ? C.type_chowder : C.type_illus);
          }),
        );
        break;
      case C.menu_download:
      case C.menu_set_wallpaper:
      // FIXME: 2019/3/12 Yaerin: 等待 iOS 开发
        if (Platform.isIOS) {
          Toast(context, '将在后续版本中支持').show();
          break;
        }
        Toast(context, '正在开始下载...').show();
        File file = await Tools.cacheImage(_data);
        String path = await Plugins.syncGallery(file);
        Toast(context, '下载完成').show();
        if (index != C.menu_set_wallpaper) break;
        await Plugins.setWallpaper(File(path));
        break;
      case C.menu_share:
        Share.share('${_data.title}\n${_data.user}:${_data.info}\n'
            '${_data.url} 分享自@图鉴R');
        break;
    }
  }
}

class _TextDialog extends StatefulWidget {
  @override
  _TextDialogState createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  String content;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Tools.fetchText());
  }

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
