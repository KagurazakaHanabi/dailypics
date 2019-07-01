import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:daily_pics/widget/qrcode.dart';
import 'package:flutter/cupertino.dart';

class ImageCard extends StatelessWidget {
  final Picture data;

  final String heroTag;

  final bool showQrCode;

  final GlobalKey repaintKey;

  ImageCard(
    this.data,
    this.heroTag, {
    this.showQrCode = false,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    bool dark = true;
    if (Utils.isColorSimilar(data.color, Color(0xffffffff))) {
      dark = false;
    }
    return AspectRatio(
      aspectRatio: 4 / 5,
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
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => DetailsPage(data, heroTag),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: RepaintBoundary(
            key: repaintKey,
            child: Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: heroTag,
                      child: CachedNetworkImage(
                        placeholder: (_, __) =>
                            Image.asset('res/placeholder.jpg'),
                        imageUrl: Utils.getCompressed(data),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.title,
                        style: TextStyle(
                          color: dark ? Color(0xffffffff) : Color(0xff000000),
                          fontSize: 28,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, right: 32),
                        child: Text(
                          data.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: dark ? Color(0xb3ffffff) : Color(0xb3000000),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(right: 8, bottom: 8),
                    child: Offstage(
                      offstage: !showQrCode,
                      child: QrCodeView(
                        'https://www.dailypics.cn/member/id/${data.id}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
