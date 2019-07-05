import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/rendering.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:path_provider/path_provider.dart';

class DetailsPage extends StatefulWidget {
  final Picture data;

  final String heroTag;

  DetailsPage(this.data, [this.heroTag = '##']);

  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  GlobalKey repaintKey = GlobalKey();
  bool popped = false;
  bool offstage = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: <Widget>[
          ImageCard(widget.data, '#', showQrCode: true, repaintKey: repaintKey),
          Container(color: Color(0xffffffff)),
          CupertinoScrollbar(
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: (ScrollUpdateNotification n) {
                if (n.metrics.outOfRange && n.metrics.pixels < -75 && !popped) {
                  Navigator.of(context).pop();
                  popped = true;
                }
                return false;
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: widget.data.width / widget.data.height,
                    child: Hero(
                      tag: widget.heroTag,
                      child: CachedNetworkImage(
                        placeholder: (_, __) {
                          return Image.asset('res/placeholder.jpg');
                        },
                        imageUrl: Utils.getCompressed(widget.data),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.data.title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.data.content,
                                style: TextStyle(
                                  color: Color(0x8a000000),
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Column(
                            children: <Widget>[
                              SaveButton(url: widget.data.url),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: 2019/7/5 收藏
                                  },
                                  child: Icon(
                                    Ionicons.ios_star_outline,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 48),
                    padding: EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0x1f000000))),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Color(0xfff2f2f7),
                      ),
                      child: CupertinoButton(
                        pressedOpacity: 0.4,
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                        onPressed: share,
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
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: MediaQuery.of(context).padding,
            child: CloseButton(),
          ),
        ],
      ),
    );
  }

  void share() async {
    double pixelRatio = ui.window.devicePixelRatio;
    RenderRepaintBoundary render = repaintKey.currentContext.findRenderObject();
    ui.Image image = await render.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = byteData.buffer.asUint8List();
    String temp = (await getTemporaryDirectory()).path;
    File file = File('$temp/${DateTime.now().millisecondsSinceEpoch}.png');
    file.writeAsBytesSync(bytes);
    await Utils.share(file);
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
          CupertinoIcons.clear_circled_solid,
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
  bool started = false;
  double progress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xfff2f2f7),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            '获取',
            style: TextStyle(
              fontSize: 13,
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
        ),
        secondChild: Container(
          width: 58,
          height: 21,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 19),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress,
            backgroundColor: progress != null ? Color(0xffdadade) : null,
            valueColor: progress == null
                ? AlwaysStoppedAnimation(Color(0xffdadade))
                : null,
          ),
        ),
        crossFadeState: progress == null && !started
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: Duration(milliseconds: 200),
      ),
    );
  }
}
