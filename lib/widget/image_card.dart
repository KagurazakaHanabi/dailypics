import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:daily_pics/widget/animated_transform.dart';
import 'package:daily_pics/widget/qrcode.dart';
import 'package:daily_pics/widget/rounded_image.dart';
import 'package:flutter/cupertino.dart';

class ImageCard extends StatefulWidget {
  final Picture data;

  final String heroTag;

  final double aspectRatio;

  final bool showQrCode;

  final GlobalKey repaintKey;

  ImageCard(
    this.data,
    this.heroTag, {
    this.aspectRatio = 4 / 5,
    this.showQrCode = false,
    this.repaintKey,
  }) : assert(aspectRatio != null);

  @override
  State<StatefulWidget> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  final Duration duration = Duration(milliseconds: 150);

  double scale = 1;
  DateTime tapDown;

  @override
  Widget build(BuildContext context) {
    bool dark = true;
    if (Utils.isColorSimilar(widget.data.color, Color(0xffffffff))) {
      dark = false;
    }
    return AnimatedTransform.scale(
      scale: scale,
      duration: duration,
      curve: Curves.easeInOut,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xffd9d9d9),
                offset: Offset(0, 16),
                blurRadius: 32,
              )
            ],
          ),
          child: GestureDetector(
            onTapDown: (_) {
              tapDown = DateTime.now();
              setState(() => scale = 0.97);
            },
            onTapCancel: () => setState(() => scale = 1.0),
            onTapUp: (_) async {
              if (DateTime.now().difference(tapDown) < duration) {
                await Future.delayed(duration);
              }
              setState(() => scale = 1.0);
              DetailsPage.push(
                context,
                data: widget.data,
                heroTag: widget.heroTag,
              );
            },
            child: RepaintBoundary(
              key: widget.repaintKey,
              child: Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: RoundedImage(
                      fit: BoxFit.cover,
                      heroTag: widget.heroTag,
                      borderRadius: BorderRadius.circular(16),
                      imageUrl: Utils.getCompressed(widget.data),
                      placeholder: (_, __) {
                        return Container(
                          color: Color(0xffe0e0e0),
                          child: Image.asset('res/placeholder.jpg'),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.data.title,
                          style: TextStyle(
                            color: dark ? Color(0xffffffff) : Color(0xff000000),
                            fontWeight: FontWeight.w500,
                            fontSize: 28,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4, right: 32),
                          child: Text(
                            widget.data.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: dark
                                  ? Color(0xffffffff).withAlpha(179)
                                  : Color(0xff000000).withAlpha(179),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !widget.showQrCode,
                    child: AspectRatio(
                      aspectRatio: widget.aspectRatio,
                      child: Container(
                        alignment: Alignment.bottomRight,
                        padding: EdgeInsets.only(right: 8, bottom: 8),
                        child: QrCodeView(
                          widget.data.url.contains('bing.com/')
                              ? 'https://cn.bing.com/'
                              : 'https://dailypics.cn/p/${widget.data.id}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
