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

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/constants.dart';
import 'package:daily_pics/model/app.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:daily_pics/pages/search.dart';
import 'package:daily_pics/utils/api.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:daily_pics/widget/optimized_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/rendering.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scoped_model/scoped_model.dart';

class RecentPage extends StatefulWidget {
  final String tid;

  const RecentPage({
    this.tid = C.type_photo,
  });

  @override
  _RecentPageState createState() => _RecentPageState();

  static Future<void> push(
    BuildContext context, {
    String tid,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (_) => RecentPage(tid: tid)),
    );
  }
}

class _RecentPageState extends State<RecentPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final List<String> types = [C.type_photo, C.type_illus, C.type_deskt];

  ScrollController controller;

  bool doing = false;
  int index = 0;
  Map<int, int> cur = {0: 1, 1: 1, 2: 1};
  Map<int, int> max = {0: null, 1: null, 2: null};

  @override
  void initState() {
    super.initState();
    controller = ScrollController(
      initialScrollOffset: kSearchBarHeight,
    )..addListener(_onScrollUpdate);
    if (types.contains(widget.tid)) {
      index = types.indexOf(widget.tid);
    }
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double windowHeight = MediaQuery.of(context).size.height;
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: ScopedModelDescendant<AppModel>(builder: (_, __, model) {
        List<Picture> data = _where(types[index]);
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            NotificationListener<UserScrollNotification>(
              onNotification: (UserScrollNotification notification) {
                if (notification.direction == ScrollDirection.idle) {
                  _onScrollEnd();
                }
                return false;
              },
              child: CustomScrollView(
                controller: controller,
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverHeaderDelegate(
                      index: index,
                      vsync: this,
                      onValueChanged: (newValue) {
                        if (!doing) {
                          setState(() => index = newValue);
                          if (_where(types[index]).length == 0) {
                            _fetchData();
                          }
                        }
                      },
                    ),
                  ),
                  CupertinoSliverRefreshControl(onRefresh: _fetchData),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: data.length == 0 ? windowHeight : 0,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                    sliver: SliverStaggeredGrid.countBuilder(
                      crossAxisCount: SystemUtils.isIPad(context) ? 3 : 2,
                      itemCount: data.length,
                      itemBuilder: (_, i) => _Tile(data[i], i),
                      staggeredTileBuilder: (_) => StaggeredTile.fit(1),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                  ),
                ],
              ),
            ),
            data.length == 0 ? CupertinoActivityIndicator() : Container(),
          ],
        );
      }),
    );
  }

  Future<void> _fetchData() async {
    doing = true;
    List<String> types = [C.type_photo, C.type_illus, C.type_deskt];
    Recents recents = await TujianApi.getRecents(
      sort: types[index],
      page: cur[index],
      size: 20,
    );
    List<Picture> data = recents.data;
    List<String> list = Settings.marked;
    for (int i = 0; i < data.length; i++) {
      data[i].marked = list.contains(data[i].id);
    }
    max[index] = recents.maximum;
    doing = false;
    AppModel model = AppModel.of(context);
    model.recent.addAll(data);
    model.notifyListeners();
  }

  List<Picture> _where(String tid) {
    return AppModel.of(context).recent.where((e) => e.tid == tid).toList();
  }

  void _onScrollUpdate() {
    ScrollPosition pos = controller.position;

    bool shouldFetch = pos.maxScrollExtent - pos.pixels < 256 && !doing;
    if (shouldFetch && max[index] - cur[index] > 0) {
      cur[index] += 1;
      _fetchData();
    }
  }

  void _onScrollEnd() {
    ScrollPosition pos = controller.position;

    Duration duration = Duration(milliseconds: 300);
    double half = kSearchBarHeight / 2;
    bool shouldExpand = pos.pixels > 0 && pos.pixels <= half;
    if (shouldExpand) {
      controller.animateTo(0, duration: duration, curve: Curves.ease);
    }

    bool shouldFold = pos.pixels > half && pos.pixels < kSearchBarHeight;
    if (shouldFold) {
      controller.animateTo(
        kSearchBarHeight,
        duration: duration,
        curve: Curves.ease,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onScrollUpdate);
    controller.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<int> onValueChanged;

  final TickerProvider vsync;

  final int index;

  _SliverHeaderDelegate({
    @required this.onValueChanged,
    @required this.vsync,
    @required this.index,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, _) {
    double extent = math.min<double>(shrinkOffset, kSearchBarHeight);
    double barHeight = kSearchBarHeight - extent;
    EdgeInsets padding = MediaQuery.of(context).padding;
    bool canPop = Navigator.of(context).canPop();
    CupertinoThemeData theme = CupertinoTheme.of(context);
    TextStyle navTitleTextStyle = theme.textTheme.navTitleTextStyle;
    return OverflowBox(
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: padding.top, bottom: 8),
            decoration: BoxDecoration(
              color: theme.barBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Color(0x4C000000),
                  width: 0,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 44,
                  padding: EdgeInsets.only(left: canPop ? 0 : 44, right: 44),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Offstage(
                        offstage: !canPop,
                        child: CupertinoButton(
                          child: Icon(CupertinoIcons.back),
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '往期精选',
                          textAlign: TextAlign.center,
                          style: navTitleTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 500,
                  height: barHeight,
                  child: SearchBar(
                    shrinkOffset: barHeight / kSearchBarHeight,
                    onTap: () => SearchPage.push(context),
                  ),
                ),
                SizedBox(
                  width: 500,
                  child: DefaultTextStyle(
                    style: TextStyle(fontWeight: FontWeight.w500),
                    child: CupertinoSegmentedControl<int>(
                      onValueChanged: onValueChanged,
                      groupValue: index,
                      children: {
                        0: Text('杂烩'),
                        1: Text('插画'),
                        2: Text('桌面'),
                      },
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

  @override
  double get maxExtent => 154;

  @override
  double get minExtent => 105;

  @override
  bool shouldRebuild(_) => true;
}

class _Tile extends StatefulWidget {
  final Picture data;

  final int index;

  _Tile(this.data, this.index);

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  @override
  Widget build(BuildContext context) {
    double aspectRatio = widget.data.width / widget.data.height;
    if (aspectRatio > 4 / 5 && !SystemUtils.isIPad(context)) {
      aspectRatio = 4 / 5;
    }
    return GestureDetector(
      onTap: () async {
        await DetailsPage.push(
          context,
          data: widget.data,
          heroTag: '${widget.index}-${widget.data.id}',
        );
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.withBrightness(
            color: Colors.white,
            darkColor: Color(0xFF1C1C1E),
          ).resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 12),
              blurRadius: 24,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: aspectRatio,
                child: OptimizedImage(
                  Utils.getCompressed(widget.data),
                  heroTag: '${widget.index}-${widget.data.id}',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.data.title,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Offstage(
                      offstage: !widget.data.marked,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Ionicons.ios_star, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text(widget.data.date, style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
