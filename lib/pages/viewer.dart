import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/tools.dart';
import 'package:flutter/material.dart';

class ViewerPage extends StatelessWidget {
  final Picture data;

  final String heroTag;

  ViewerPage(this.data, [this.heroTag = '##']);

  @override
  Widget build(BuildContext context) {
    TextStyle hintStyle = TextStyle(color: Theme.of(context).hintColor);
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => Tools.share(data),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Hero(
                  tag: heroTag,
                  child: CachedNetworkImage(imageUrl: data.url),
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(bottom: 8),
                    child: Text(data.info ?? '', style: hintStyle),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${data.width}W${data.height}H',
                          style: hintStyle,
                        ),
                      ),
                      Offstage(
                        offstage: Platform.isIOS,
                        child: FlatButton(
                          child: _buildText(context, '设为壁纸'),
                          onPressed: () {
                            Tools.fetchImage(context, data, true);
                          },
                        ),
                      ),
                      FlatButton(
                        child: _buildText(context, '保存图片'),
                        onPressed: () => Tools.fetchImage(context, data, false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context, String data) {
    return Text(data, style: TextStyle(color: Theme.of(context).accentColor));
  }
}
