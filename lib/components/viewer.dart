import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/events.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewerComponent extends StatefulWidget {
  final String type;

  final int index;

  const ViewerComponent(this.type, [this.index = 0]);

  @override
  _ViewerComponentState createState() => _ViewerComponentState();
}

class _ViewerComponentState extends State<ViewerComponent>
    with AutomaticKeepAliveClientMixin {
  bool _debug = false;
  Picture _data;
  dynamic _error;
  Color _color;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((result) async {
      if (result == ConnectivityResult.none) {
        String cacheDir = (await getTemporaryDirectory()).path;
        File file = File('$cacheDir/today.json');
        if (!file.existsSync()) return;
        String json = file.readAsStringSync();
        Response response = Response.fromJson(jsonDecode(json));
        List<Picture> data = response.data;
        for (int i = 0; i < data.length; i++) {
          if (data[i].type == widget.type) {
            _data = data[i];
          }
        }
        setState(() {});
      } else {
        _fetch();
      }
    });
    SharedPreferences.getInstance().then((prefs) {
      _debug = prefs.getBool(C.pref_debug) ?? false;
      eventBus.on<OnPageChangedEvent>().listen((event) {
        if (_data != null && event.value == widget.index) {
          eventBus.fire(ReceivedDataEvent(widget.index, _data));
          if ((prefs.getInt(C.pref_theme) ?? C.theme_normal) == C.theme_auto) {
            _switchTheme();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget result = Center(child: CircularProgressIndicator());
    if (_error != null && _error is Error) {
      String trace = _error.stackTrace.toString() + '\n';
      result = GestureDetector(
        onTap: () => setState(() => _error = null),
        child: Center(
          child: Text(
            '$_error\n${_debug ? trace : ''}加载失败，点击重试',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      );
    }
    if (_data != null) {
      result = _buildViewer();
    }
    return result;
  }

  Widget _buildViewer() {
    return GestureDetector(
      onLongPress: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailsPage(_data)),
        );
      },
      child: Stack(
        children: <Widget>[
          CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: Utils.getCompressed(_data),
            width: window.physicalSize.width,
            height: window.physicalSize.height,
            placeholder: (_, __) => Center(child: CircularProgressIndicator()),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.black26,
                      child: Text(
                        _data.content,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _fetch() async {
    try {
      _error = null;
      if (widget.type != C.type_bing) {
        String s = 'https://dp.chimon.me/api/today.php?sort=${widget.type}';
        HttpClient client = HttpClient();
        HttpClientRequest request = await client.getUrl(Uri.parse(s));
        HttpClientResponse response = await request.close();
        String body = await response.transform(utf8.decoder).join();
        _data = Response.fromJson(jsonDecode(body)).data[0];
        if (_data == null) _error = body;
      } else {
        HttpClient client = HttpClient();
        HttpClientRequest request = await client.getUrl(Uri.parse(
          'https://cn.bing.com/HPImageArchive.aspx?format=js&n=1&idx=0',
        ));
        HttpClientResponse response = await request.close();
        String body = await response.transform(utf8.decoder).join();
        Map<String, dynamic> json = jsonDecode(body)['images'][0];
        DateTime date = DateTime.now();
        _data = Picture(
          id: '${json['urlbase']}_1080x1920'.split('?')[1],
          title: '${date.year} 年 ${date.month} 月 ${date.day} 日',
          content: json['copyright'],
          width: 1080,
          height: 1920,
          user: '',
          url: 'https://cn.bing.com${json['urlbase']}_1080x1920.jpg',
          date: json['enddate'],
          type: '必应',
        );
      }
      _color = _data.color;
      eventBus.fire(ReceivedDataEvent(widget.index, _data));
      setState(() {});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if ((prefs.getInt(C.pref_theme) ?? C.theme_normal) != C.theme_auto) {
        return;
      }
      if (_color == null) {
        _color = (await PaletteGenerator.fromImageProvider(
          CachedNetworkImageProvider(_data.url),
          timeout: Duration(seconds: 5),
        )).mutedColor.color;
      }
      _switchTheme();
    } catch (err) {
      if (mounted) setState(() => _error = err);
    }
  }

  void _switchTheme() {
    if (_color == null) return;
    ThemeData theme = Theme.of(context);
    Color accentColor = _color;
    if (Utils.isColorSimilar(_color, theme.backgroundColor)) {
      accentColor = theme.brightness == Brightness.light
          ? Colors.black87
          : Color(0xff64ffda);
    }
    ThemeModel.of(context).theme = ThemeData(
      primaryColor: _color,
      primaryColorDark: _color,
      accentColor: accentColor,
    );
  }

  @override
  bool get wantKeepAlive => _data != null;
}
