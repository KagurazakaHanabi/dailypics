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

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:daily_pics/widget/buttons.dart';
import 'package:daily_pics/widget/hightlight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar, Colors, Divider;
import 'package:image_picker/image_picker.dart';

class UserSpacePage extends StatefulWidget {
  final User data;

  final String uid;

  const UserSpacePage({this.data, this.uid});

  @override
  _UserSpacePageState createState() => _UserSpacePageState();

  static Future<void> push(BuildContext context, [User data, String uid]) {
    return Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (_) => UserSpacePage(data: data, uid: uid)),
    );
  }
}

class _UserSpacePageState extends State<UserSpacePage> {
  ScrollController controller = ScrollController();
  ScrollPosition position;

  @override
  void initState() {
    super.initState();
    controller.addListener(_handleScroll);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: <Widget>[
          _buildHeaderImage(),
          _buildListView(),
          _buildAppBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    MediaQueryData queryData = MediaQuery.of(context);
    double pixels = position?.pixels ?? 0;
    bool landscape = !SystemUtils.isPortrait(context);
    return Stack(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: 'https://via.placeholder.com/750x500',
          height: pixels < -76 ? 162 - pixels : pixels > 162 ? 0 : 162 - pixels,
          fit: pixels < -76 && !(SystemUtils.isIPad(context) && landscape)
              ? BoxFit.fill
              : BoxFit.fitWidth,
          width: queryData.size.width,
        ),
        Container(
          height: queryData.padding.top + 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0x60000000), Color(0x00000000)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    Color backgroundColor = CupertinoTheme.of(context).scaffoldBackgroundColor;
    return CupertinoScrollbar(
      controller: controller,
      child: ListView(
        controller: controller,
        padding: EdgeInsets.zero,
        physics: AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 154),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Column(
                  children: <Widget>[
                    _buildHeader(),
                    Divider(),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _showActionSheet('设置封面图片'),
                child: Container(height: 154),
              ),
              Container(
                margin: EdgeInsets.only(left: 12, top: 106),
                child: GestureDetector(
                  onTap: () => _showActionSheet('设置头像'),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://via.placeholder.com/128x128',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Button(
                child: Text('编辑资料'),
                onPressed: () {},
              )
            ],
          ),
          Text(
            'Nickname',
            style: TextStyle(fontSize: 22),
          ),
          Text(
            '@Username',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              '这里是个人简介，签名什么的',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Highlight(
            text: '132 正在关注  67 关注我的',
            defaultStyle: TextStyle(color: Colors.black54, fontSize: 13),
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
              fontSize: 17,
            ),
            patterns: {
              RegExp('[0-9]+'): HighlightedText(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    double offset = (position?.pixels ?? 0) / 154;
    offset = offset < 0 ? 0 : offset > 1 ? 1 : offset;
    EdgeInsets padding = MediaQuery.of(context).padding;
    Color primaryColor = CupertinoTheme.of(context).primaryColor;
    Color iconColor = Color.lerp(Colors.white, primaryColor, offset);
    return Container(
      padding: padding,
      height: padding.top + 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(offset),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withAlpha((offset * 0x4C).toInt()),
            width: 0.0,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.back, color: iconColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Opacity(
              opacity: offset,
              child: Text('Nickname'),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.ellipsis, color: iconColor),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  void _handleScroll() {
    setState(() => position = controller.position);
  }

  Future<File> _showActionSheet(String title) {
    return showCupertinoModalPopup<File>(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          title: Text(title),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('查看大图'),
              onPressed: () {},
            ),
            CupertinoActionSheetAction(
              child: Text('从相册选择'),
              onPressed: () async => Navigator.of(context).pop(
                await ImagePicker.pickImage(source: ImageSource.gallery),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.removeListener(_handleScroll);
    super.dispose();
  }
}
