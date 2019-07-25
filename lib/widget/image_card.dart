import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:daily_pics/widget/qrcode.dart';
import 'package:daily_pics/widget/rounded_image.dart';
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
            DetailsPage.push(context, data, heroTag);
          },
          child: RepaintBoundary(
            key: repaintKey,
            child: Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Hero(
                    tag: heroTag,
                    child: RoundedImage(
                      borderRadius: BorderRadius.circular(16),
                      imageUrl: Utils.getCompressed(data),
                      fit: BoxFit.cover,
                      placeholder: (_, __) {
                        return Image.asset('res/placeholder.jpg');
                      },
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
                          fontWeight: FontWeight.w500,
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
                        data.url.contains('bing.com/')
                            ? 'https://cn.bing.com/'
                            : 'https://www.dailypics.cn/member/id/${data.id}',
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
