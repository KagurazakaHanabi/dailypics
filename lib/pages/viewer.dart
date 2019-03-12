import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/plugins.dart';
import 'package:daily_pics/misc/tools.dart';
import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewerPage extends StatelessWidget {
  final Picture data;

  final String heroTag;

  ViewerPage(this.data, [this.heroTag = '##']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        onLongPress: () => _onLongPress(context),
        child: PhotoView(
          heroTag: heroTag,
          imageProvider: CachedNetworkImageProvider(data.url),
          loadingChild: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  void _onLongPress(BuildContext context) async {
    if (await showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          children: <Widget>[
            ListTile(
              title: Text('保存到相册'),
              onTap: () => Navigator.of(context).pop(true),
            )
          ],
        );
      },
    ) ?? false) {
      Toast(context, '正在开始下载...').show();
      Tools.cacheImage(data)
          .then((file) => Plugins.syncGallery(file))
          .then((val) => Toast(context, '下载完成').show());
    }
  }
}
