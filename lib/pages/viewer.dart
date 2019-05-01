import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
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
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.8,
          imageProvider: CachedNetworkImageProvider(
            Utils.getCompressed(data),
          ),
          loadingChild: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  void _onLongPress(BuildContext context) async {
    List<Widget> children = <Widget>[
      ListTile(
        title: Text('保存到相册'),
        onTap: () => Navigator.of(context).pop(C.menu_download),
      ),
    ];
    if (Platform.isAndroid) {
      children.add(ListTile(
        title: Text('设置为壁纸'),
        onTap: () => Navigator.of(context).pop(C.menu_set_wallpaper),
      ));
    }
    int index = await showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          children: children,
        );
      },
    );
    if (index == null) return;
    switch (index) {
      case C.menu_download:
        Utils.fetchImage(context, data, false);
        break;
      case C.menu_set_wallpaper:
        Utils.fetchImage(context, data, true);
        break;
    }
  }
}
