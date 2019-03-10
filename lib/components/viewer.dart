import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/events.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
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
  Picture _data;
  Object _error;
  Color _color;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    eventBus.on<OnPageChangedEvent>().listen((event) {
      if (_data != null && _color != null && event.value == widget.index) {
        eventBus.fire(ReceivedDataEvent(widget.index, _data));
        _switchTheme();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget result = Center(child: CircularProgressIndicator());
    if (_error != null) {
      result = GestureDetector(
        onTap: () => setState(() {}),
        child: Center(
          child: Text(
            '$_error\n加载失败，点击重试',
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(_data.url),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.black26,
                  child: Text(
                    _data.info,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _fetch() async {
    try {
      _error = null;
      String s = 'https://wallpaper.yaerin.com/api?type=${widget.type}&limit=1';
      HttpClient client = HttpClient();
      HttpClientRequest request = await client.getUrl(Uri.parse(s));
      HttpClientResponse response = await request.close();
      String body = await response.transform(utf8.decoder).join();
      _data = Response.fromJson(jsonDecode(body)).data[0];
      eventBus.fire(ReceivedDataEvent(widget.index, _data));
      setState(() {});
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (!(pref.getBool('pick_color') ?? false)) return;
      PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(_data.url),
      ).then((generator) {
        _color = generator.mutedColor.color;
        _switchTheme();
      });
    } catch (err) {
      if (mounted) setState(() => _error = err);
    }
  }

  void _switchTheme() {
    ThemeModel.of(context).theme = ThemeData(
      primaryColor: _color,
      primaryColorDark: _color,
      accentColor: _color,
    );
  }

  @override
  bool get wantKeepAlive => _data != null;
}
