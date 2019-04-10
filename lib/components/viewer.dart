import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/events.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    SharedPreferences.getInstance().then((prefs) {
      _debug = prefs.getBool(C.pref_debug) ?? false;
      eventBus.on<OnPageChangedEvent>().listen((event) {
        if (_data != null && event.value == widget.index) {
          eventBus.fire(ReceivedDataEvent(widget.index, _data));
          if (!(prefs.getBool(C.pref_night) ?? false)) {
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
            imageUrl: _data.url,
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
                        _data.info,
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
          info: json['copyright'],
          width: 1080,
          height: 1920,
          user: '',
          url: 'https://cn.bing.com${json['urlbase']}_1080x1920.jpg',
          date: json['enddate'],
          type: '必应',
        );
      }
      eventBus.fire(ReceivedDataEvent(widget.index, _data));
      setState(() {});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if ((prefs.getInt(C.pref_theme) ?? C.theme_normal) != C.theme_auto) {
        return;
      }
      PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(_data.url),
        timeout: Duration(seconds: 5),
      ).then((generator) {
        _color = generator.mutedColor?.color;
        _switchTheme();
      });
    } catch (err) {
      if (mounted) setState(() => _error = err);
    }
  }

  void _switchTheme() {
    if (_color == null) return;
    ThemeModel.of(context).theme = ThemeData(
      primaryColor: _color,
      primaryColorDark: _color,
      accentColor: _color,
    );
  }

  @override
  bool get wantKeepAlive => _data != null;
}
