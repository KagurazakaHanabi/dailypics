import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/pages/view.dart';

class ArchiveComponent extends StatefulWidget {
  final String type;

  const ArchiveComponent(this.type);

  @override
  ArchiveComponentState createState() => ArchiveComponentState();
}

class ArchiveComponentState extends State<ArchiveComponent> {
  bool _debug = false;
  List<Picture> _pictures = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((pref) => _debug = pref.getBool('debug') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    String type = Uri.decodeQueryComponent(widget.type);
    int crossAxisCount = type == '电脑壁纸' ? 1 : 2;
    return FutureBuilder(
      future: _fetch(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              dynamic error = snapshot.error;
              String trace = '';
              if (error is Error) {
                trace = error.stackTrace.toString() + '\n';
              }
              return GestureDetector(
                onTap: () => setState(() {}),
                child: Center(
                  child: Text(
                    '${snapshot.error}\n${_debug ? trace : ''}加载失败，点击重试',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              );
            }
            return Scrollbar(
              child: StaggeredGridView.countBuilder(
                crossAxisCount: crossAxisCount,
                itemCount: _pictures.length,
                itemBuilder: (context, index) => _Tile(_pictures[index]),
                staggeredTileBuilder: (_) => StaggeredTile.fit(1),
              ),
            );
          default:
            return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> _fetch() async {
    Uri uri = Uri.parse('https://wallpaper.yaerin.com/api?type=${widget.type}');
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    Response res = Response.fromJson(jsonDecode(body));
    _pictures = res.data ?? [];
  }
}

class _Tile extends StatelessWidget {
  final Picture data;

  _Tile(this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Color(0xFFF5F5F5),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ViewPage(data)),
          );
        },
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: data.width / data.height,
              child: CachedNetworkImage(
                imageUrl: data.url,
                placeholder: Placeholder(), // TODO: 2019/3/1 Yaerin: 等待提供占位图
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(8),
              child: Text(
                data.info.trim(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
