import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArchiveComponent extends StatefulWidget {
  final String type;

  const ArchiveComponent(this.type);

  @override
  ArchiveComponentState createState() => ArchiveComponentState();
}

class ArchiveComponentState extends State<ArchiveComponent>
    with AutomaticKeepAliveClientMixin {
  bool _debug = false;
  List<Picture> _pictures;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    SharedPreferences.getInstance()
        .then((pref) => _debug = pref.getBool(C.pref_debug) ?? false);
  }

  @override
  Widget build(BuildContext context) {
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
    if (_pictures != null) {
      String type = Uri.decodeQueryComponent(widget.type);
      int crossAxisCount = type == '电脑壁纸' ? 1 : 2;
      result = Scrollbar(
        child: StaggeredGridView.countBuilder(
          crossAxisCount: crossAxisCount,
          itemCount: _pictures.length,
          itemBuilder: (_, index) => _Tile(_pictures[index], '#$index'),
          staggeredTileBuilder: (_) => StaggeredTile.fit(1),
        ),
      );
    }
    return result;
  }

  Future<void> _fetch() async {
    if (widget.type == C.type_bing) {
      return _fetchBing();
    }
    try {
      _error = null;
      String uri = 'https://dp.chimon.me/api/bysort.php?sort=${widget.type}';
      HttpClient client = HttpClient();
      HttpClientRequest request = await client.getUrl(Uri.parse(uri));
      HttpClientResponse response = await request.close();
      String body = await response.transform(utf8.decoder).join();
      Response res = Response.fromJson(jsonDecode(body));
      setState(() => _pictures = res.data ?? []);
    } catch (err) {
      if (mounted) setState(() => _error = err);
    }
  }

  Future<void> _fetchBing() async {
    try {
      _error = null;
      HttpClient client = HttpClient();
      HttpClientRequest request = await client.getUrl(Uri.parse(
        'https://cn.bing.com/HPImageArchive.aspx?format=js&n=8&idx=1',
      ));
      HttpClientResponse response = await request.close();
      String body = await response.transform(utf8.decoder).join();
      Map<String, dynamic> json = jsonDecode(body);
      Response res = Response(
        data: (json['images'] as List).map((e) {
          if (e != null) {
            String date = e['enddate'];
            String yy = date.substring(0, 4);
            String mm = date.substring(5, 6).replaceFirst(RegExp('^0'), '');
            String dd = date.substring(7, 8).replaceFirst(RegExp('^0'), '');
            return Picture(
              id: '${e['urlbase']}_1080x1920'.split('?')[1],
              title: '$yy 年 $mm 月 $dd 日',
              info: e['copyright'],
              width: 1080,
              height: 1920,
              user: null,
              url: 'https://cn.bing.com${e['urlbase']}_1080x1920.jpg',
              date: date,
              type: '必应',
            );
          }
        }).toList(),
        status: 'ok',
      );
      setState(() => _pictures = res.data ?? []);
    } catch (err) {
      if (mounted) setState(() => _error = err);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _Tile extends StatelessWidget {
  final Picture data;

  final String heroTag;

  _Tile(this.data, this.heroTag);

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    Color textColor = light ? Colors.black54 : Colors.white70;
    Color accentColor = Theme.of(context).accentColor;
    return Card(
      elevation: 0,
      color: light ? Color(0xFFF5F5F5) : Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailsPage(data, heroTag)),
          );
        },
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: data.width / data.height,
              child: Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: data.url,
                  placeholder: (_, __) => Placeholder(),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(8),
              child: Text.rich(
                TextSpan(
                  text: data.user == null ? '' : '${data.user.trim()}: ',
                  children: <TextSpan>[
                    TextSpan(
                      text: data.info.trim(),
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
                style: TextStyle(color: accentColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
