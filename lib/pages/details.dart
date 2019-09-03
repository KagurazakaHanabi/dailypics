// Copyright 2019 KagurazakaHanabi<i@yaerin.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/widget/adaptive_scaffold.dart';
import 'package:daily_pics/widget/hightlight.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:daily_pics/widget/optimized_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator, Colors;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String _prefix = 'https://www.pixiv.net/member_illust.php?illust_id=';

class DetailsPage extends StatefulWidget {
  final Picture data;

  final String pid;

  final String heroTag;

  DetailsPage({this.data, this.pid, this.heroTag});

  @override
  State<StatefulWidget> createState() => _DetailsPageState();

  static Future<void> push(
    BuildContext context, {
    Picture data,
    String pid,
    String heroTag,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: DetailsPage(
              data: data,
              pid: pid,
              heroTag: heroTag,
            ),
          );
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
          style: TextStyle(color: Colors.black54, fontSize: 14),
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
            Align(
              alignment: Alignment.topRight,
              child: CloseButton(),
            ),
          ],
        ),
      );
    }
    Radius radius = Radius.circular(Device.isIPad(context) ? 16 : 0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Utils.isDarkColor(data.color) && !Device.isIPad(context)
          ? OverlayStyles.light
          : OverlayStyles.dark,
      child: AdaptiveScaffold(
        backgroundColor: Colors.transparent,
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
              margin: EdgeInsets.only(top: 80),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: radius),
              ),
            ),
            NotificationListener<ScrollUpdateNotification>(
              onNotification: _onScrollUpdate,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: data.width / data.height,
                    child: OptimizedImage(
                      imageUrl: Utils.getCompressed(data),
                      heroTag: widget.heroTag ?? DateTime.now(),
                      borderRadius: BorderRadius.vertical(top: radius),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Icon(
                                    data.marked
                                        ? Ionicons.ios_star
                                        : Ionicons.ios_star_outline,
                                    size: 22,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: SaveButton(data),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(18, 0, 18, 48),
                          child: _buildContent(),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 29),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0x4C000000),
                                width: 0,
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xFFF2F2F7),
                            ),
                            child: CupertinoButton(
                              pressedOpacity: 0.4,
                              padding: EdgeInsets.fromLTRB(30, 12, 30, 12),
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
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Offstage(
              offstage: Device.isIPad(context),
              child: Align(
                alignment: Alignment.topRight,
                child: CloseButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Highlight(
      text: widget.data.content,
      style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
      defaultStyle: TextStyle(color: Colors.black54, fontSize: 15, height: 1.2),
      patterns: {
        RegExp(
          r"(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+",
        ): HighlightedText(
          recognizer: (RegExpMatch e, int i) {
            return TapGestureRecognizer()
              ..onTap = () {
                launch(e.input.substring(e.start, e.end));
              };
          },
        ),
        RegExp('Pixiv#[^0][0-9]+', caseSensitive: false): HighlightedText(
          recognizer: (RegExpMatch e, int i) {
            RegExp number = RegExp('[0-9]+');
            int start = e.start, end = e.end;
            String match = e.input.substring(start, end);
            String id = number.stringMatch(match);
            return TapGestureRecognizer()..onTap = () => launch('$_prefix$id');
          },
        ),
      },
    );
  }

  bool _onScrollUpdate(ScrollUpdateNotification n) {
    if (n.metrics.outOfRange && n.metrics.pixels < -64 && !popped) {
      Navigator.of(context).pop();
      popped = true;
    }
    return false;
  }

  Future<void> _fetchData() async {
    String url = 'https://v2.api.dailypics.cn/member?id=${widget.pid}';
    Map<String, dynamic> json = jsonDecode((await http.get(url)).body);
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
    if (widget.data != null) {
      widget.data.marked = !widget.data.marked;
    } else {
      data.marked = !data.marked;
    }
    HashSet<String> hashSet = HashSet.from(Settings.marked);
    if (data.marked) {
      hashSet.add(data.id);
    } else {
      hashSet.remove(data.id);
    }
    Settings.marked = hashSet.toList();
    setState(() {});
  }
}

class CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Icon(
          CupertinoIcons.clear_circled_solid,
          color: Colors.black38,
          size: 32,
        ),
      ),
    );
  }
}

class SaveButton extends StatefulWidget {
  final Picture data;

  SaveButton(this.data);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool started = false;
  bool denied = false;
  double progress;
  File file;

  @override
  void initState() {
    super.initState();
    Utils.isAlbumAuthorized().then((granted) {
      setState(() => denied = !granted);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = CupertinoTheme.of(context).primaryColor;
    return GestureDetector(
      onTap: () async {
        if (denied) {
          Utils.openAppSettings();
        } else if (!started) {
          setState(() => started = true);
          try {
            file = await Utils.download(widget.data, (count, total) {
              if (mounted) {
                setState(() => progress = count / total);
              }
            });
          } on PlatformException catch (e) {
            if (e.code == '-1') setState(() => denied = true);
          }
        } else if (progress == 1 && Platform.isAndroid) {
          Utils.useAsWallpaper(file);
        }
      },
      child: AnimatedCrossFade(
        firstChild: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
          decoration: BoxDecoration(
            color: denied
                ? CupertinoColors.destructiveRed
                : progress == 1 && Platform.isAndroid
                    ? primaryColor
                    : Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            denied
                ? '授权'
                : progress != 1 ? '获取' : Platform.isAndroid ? '设定' : '完成',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: denied
                  ? Color(0xFFF2F2F7)
                  : progress == 1 && Platform.isAndroid
                      ? Color(0xFFF2F2F7)
                      : primaryColor,
            ),
          ),
        ),
        secondChild: Container(
          width: 70,
          height: 26,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 26),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress,
            backgroundColor: progress != null ? Color(0xFFDADADE) : null,
            valueColor: progress == null
                ? AlwaysStoppedAnimation(Color(0xFFDADADE))
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
