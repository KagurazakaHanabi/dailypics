import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;

class DetailsPage extends StatefulWidget {
  final Picture data;

  final String heroTag;

  DetailsPage(this.data, [this.heroTag = '##']);

  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool popped = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: <Widget>[
          CupertinoScrollbar(
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: (ScrollUpdateNotification n) {
                if (n.metrics.outOfRange && n.metrics.pixels < -90 && !popped) {
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
                        placeholder: (_, __) => Placeholder(),
                        imageUrl: Utils.getCompressed(widget.data),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          widget.data.title,
                          style: TextStyle(fontSize: 22),
                        ),
                        SaveButton(url: widget.data.url),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.data.content,
                      style: TextStyle(
                        color: Color(0x8a000000),
                        fontSize: 14,
                        height: 1.2,
                      ),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(CupertinoIcons.share),
                            Text('分享'),
                          ],
                        ),
                        onPressed: () {
                          // TODO: 2019/6/29 Utils.share(imageFile);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topRight,
                padding: MediaQuery.of(context).padding,
                child: CloseButton(),
              ),
            ],
          ),
        ],
      ),
    );
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
