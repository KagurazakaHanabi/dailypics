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

import 'dart:async';
import 'dart:ui' show ImageFilter, window;

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/utils/api.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const double kSearchBarHeight = 49;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();

  static Future<void> push(BuildContext context, {String query}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SearchPage(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _SearchPageState extends State<SearchPage> {
  ScrollController controller = ScrollController();

  List<Picture> data = [];
  bool doing = false;
  String query = '';

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    EdgeInsets windowPadding = queryData.padding;
    windowPadding = windowPadding.copyWith(top: 90);
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: MediaQuery(
        data: queryData.copyWith(padding: windowPadding),
        child: Stack(
          children: <Widget>[
            CupertinoScrollbar(
              controller: controller,
              child: StaggeredGridView.countBuilder(
                controller: controller,
                padding: SystemUtils.isIPad(context)
                    ? EdgeInsets.fromLTRB(12, 12, 12, 0) + windowPadding
                    : EdgeInsets.fromLTRB(4, 0, 4, 0) + windowPadding,
                crossAxisCount: SystemUtils.isIPad(context) ? 2 : 1,
                staggeredTileBuilder: (_) => StaggeredTile.fit(1),
                itemCount: data.length == 0 ? 1 : data.length,
                itemBuilder: (_, i) {
                  if (data.length != 0) {
                    return ImageCard(data[i], '$query-${data[i].id}');
                  } else if (query.isNotEmpty && !doing) {
                    return Container(
                      padding: EdgeInsets.only(top: 16),
                      alignment: Alignment.center,
                      child: Text(
                        '未找到相关内容',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xB3000000),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: _buildSearchBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    EdgeInsets padding = MediaQuery.of(context).padding;
    Color barBackgroundColor = CupertinoTheme.of(context).barBackgroundColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: padding.top),
          color: barBackgroundColor,
          child: SizedBox(
            width: 500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SearchBar(
                      autofocus: true,
                      onSubmitted: (value) {
                        if (Utils.isUuid(value)) {
                          _fetchData(value);
                        } else if (value.isNotEmpty) {
                          query = value;
                          _fetchData();
                        }
                      },
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
                  child: Text('取消'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: doing ? 2 : 1 / window.devicePixelRatio,
          child: LinearProgressIndicator(
            backgroundColor: barBackgroundColor,
            valueColor: AlwaysStoppedAnimation(Color(0x4C000000)),
            value: (doing ?? false) ? null : 1,
          ),
        ),
      ],
    );
  }

  Future<void> _fetchData([String uuid]) async {
    setState(() => doing = true);
    List<Picture> result = [];
    if (uuid != null) {
      Picture detail = await TujianApi.getDetails(uuid);
      if (detail.id != null) {
        result = [detail];
      }
    } else {
      result = await TujianApi.search(query);
    }
    setState(() {
      doing = false;
      data = result;
    });
    if (controller.position.pixels > 320) {
      controller.jumpTo(0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class SearchBar extends StatelessWidget {
  final bool autofocus;

  final double shrinkOffset;

  final VoidCallback onTap;

  final ValueChanged<String> onChanged;

  final ValueChanged<String> onSubmitted;

  const SearchBar({
    Key key,
    this.autofocus = false,
    this.shrinkOffset = 1,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'SearchBar',
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: CupertinoDynamicColor.withBrightness(
              color: Color(0xDDE3E3E8),
              darkColor: Color(0xFF303030),
            ).resolveFrom(context),
          ),
          child: AnimatedOpacity(
            opacity: shrinkOffset < 0.9 ? 0 : 1,
            duration: Duration(milliseconds: 100),
            child: CupertinoTextField(
              autofocus: autofocus,
              placeholder: '搜索',
              decoration: null,
              onTap: onTap,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 18),
              placeholderStyle: TextStyle(
                color: CupertinoColors.inactiveGray,
                fontSize: 16,
              ),
              prefix: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  CupertinoIcons.search,
                  color: CupertinoColors.inactiveGray,
                  size: 21,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
