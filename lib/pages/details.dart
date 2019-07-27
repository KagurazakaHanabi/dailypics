import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/widget/adaptive_scaffold.dart';
import 'package:daily_pics/widget/divider.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:daily_pics/widget/rounded_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/rendering.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailsPage extends StatefulWidget {
  final Picture data;

  final String pid;

  final String heroTag;

  DetailsPage({this.data, this.pid, this.heroTag = '##'});

  @override
  State<StatefulWidget> createState() => _DetailsPageState();

  static void push(
    BuildContext context, {
    Picture data,
    String pid,
    String heroTag,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return DetailsPage(data: data, pid: pid, heroTag: heroTag);
        },
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _DetailsPageState extends State<DetailsPage> {
  GlobalKey repaintKey = GlobalKey();
  bool popped = false;
  Picture data;
  String error;

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (widget.data == null && data == null && error == null) {
      _fetchData();
      result = Center(
        child: CupertinoActivityIndicator(),
      );
    } else if (error != null) {
      result = Center(
        child: Text(
          error,
          style: TextStyle(color: Color(0x8a000000), fontSize: 14),
        ),
      );
    } else if (widget.data != null) {
      data = widget.data;
    }
    if (result != null) {
      return AdaptiveScaffold(
        child: Stack(
          children: <Widget>[
            result,
            Container(
              alignment: Alignment.topRight,
              padding: MediaQuery.of(context).padding,
              child: CloseButton(),
            ),
          ],
        ),
      );
    }
    Radius radius = Radius.circular(Device.isIPad(context) ? 16 : 0);
    return AdaptiveScaffold(
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 64),
            child: ImageCard(
              data,
              '#',
              showQrCode: true,
              repaintKey: repaintKey,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 64),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.vertical(top: radius),
            ),
          ),
          NotificationListener<ScrollUpdateNotification>(
            onNotification: (ScrollUpdateNotification n) {
              if (n.metrics.outOfRange && n.metrics.pixels < -64 && !popped) {
                Navigator.of(context).pop();
                popped = true;
              }
              return false;
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: data.width / data.height,
                  child: Hero(
                    tag: widget.heroTag ?? DateTime.now(),
                    child: RoundedImage(
                      imageUrl: Utils.getCompressed(data),
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.vertical(top: radius),
                      placeholder: (_, __) {
                        return Container(
                          color: Color(0xffe0e0e0),
                          child: Image.asset('res/placeholder.jpg'),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Color(0xffffffff),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTitle(),
                      _buildContent(),
                      Divider(),
                      _buildShareButton(),
                    ],
                  ),
                )
              ],
            ),
          ),
          Offstage(
            offstage: Device.isIPad(context),
            child: Container(
              alignment: Alignment.topRight,
              padding: MediaQuery.of(context).padding,
              child: CloseButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              data.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _mark,
            child: Icon(
              data.marked ? Ionicons.ios_star : Ionicons.ios_star_outline,
              size: 22,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: SaveButton(url: data.url),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: EdgeInsets.only(bottom: 48),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        data.content,
        style: TextStyle(
          color: Color(0x8a000000),
          fontSize: 15,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Color(0xfff2f2f7),
        ),
        child: CupertinoButton(
          pressedOpacity: 0.4,
          padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
          onPressed: _share,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(CupertinoIcons.share),
              Text('分享'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchData() async {
    String url = 'https://v2.api.dailypics.cn/member?id=${widget.pid}';
    Map<String, dynamic> json = jsonDecode(await Http.get(url));
    if (json['error_code'] != null) {
      setState(() => error = json['msg'].toString());
    } else {
      setState(() => data = Picture.fromJson(json));
    }
  }

  Future<ui.Image> _screenshot() async {
    double pixelRatio = ui.window.devicePixelRatio;
    RenderRepaintBoundary render = repaintKey.currentContext.findRenderObject();
    return await render.toImage(pixelRatio: pixelRatio);
  }

  void _share() async {
    ui.Image image = await _screenshot();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = byteData.buffer.asUint8List();
    String temp = (await getTemporaryDirectory()).path;
    File file = File('$temp/${DateTime.now().millisecondsSinceEpoch}.png');
    file.writeAsBytesSync(bytes);
    await Utils.share(file);
  }

  void _mark() async {
    data.marked = !data.marked;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    HashSet<String> list = HashSet.from(prefs.getStringList('marked') ?? []);
    if (data.marked) {
      list.add(data.id);
    } else {
      list.remove(data.id);
    }
    await prefs.setStringList('marked', list.toList());
    setState(() {});
  }
}

class CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          Ionicons.ios_close_circle,
          color: Color(0x61000000),
        ),
      ),
    );
  }
}

class SaveButton extends StatefulWidget {
  final String url;

  SaveButton({Key key, @required this.url}) : super(key: key);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  GlobalKey _key = GlobalKey();
  bool started = false;
  double progress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(_key.currentContext.size);
        if (!started) {
          setState(() => started = true);
          Utils.download(widget.url, (int count, int total) {
            if (mounted) {
              setState(() => progress = count / total);
            }
          });
        }
      },
      child: AnimatedCrossFade(
        firstChild: Container(
          key: _key,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          decoration: BoxDecoration(
            color: Color(0xfff2f2f7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            progress != 1 ? '获取' : '完成',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
        ),
        secondChild: Container(
          width: 70,
          height: 28,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 25),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress,
            backgroundColor: progress != null ? Color(0xffdadade) : null,
            valueColor: progress == null
                ? AlwaysStoppedAnimation(Color(0xffdadade))
                : null,
          ),
        ),
        crossFadeState: progress == null && !started || progress == 1
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: Duration(milliseconds: 200),
      ),
    );
  }
}
