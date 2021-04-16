// Copyright 2019-2021 KagurazakaHanabi<i@hanabi.su>
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

import 'package:dailypics/misc/bean.dart';
import 'package:dailypics/misc/ionicons.dart';
import 'package:dailypics/model/app.dart';
import 'package:dailypics/pages/details.dart';
import 'package:dailypics/pages/search.dart';
import 'package:dailypics/utils/api.dart';
import 'package:dailypics/utils/utils.dart';
import 'package:dailypics/widget/optimized_image.dart';
import 'package:dailypics/widget/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scoped_model/scoped_model.dart';

class RecentPage extends StatefulWidget {

  @override
  _RecentPageState createState() => _RecentPageState();

  static Future<void> push(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (_) => RecentPage()),
    );
  }
}

class _RecentPageState extends State<RecentPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List<String> types = [];

  ScrollController controller;

  bool doing = false;
  String current;
  Map<String, int> cur = {};
  Map<String, int> max = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (current == null) {
      _initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    MediaQueryData queryData = MediaQuery.of(context);
    if (AppModel.of(context).types == null) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: ScopedModelDescendant<AppModel>(builder: (_, __, model) {
        List<Picture> data = _where(current);
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
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverHeaderDelegate(
                      groupValue: current,
                      vsync: this,
                      onValueChanged: (String newValue) {
                        if (!doing) {
                          setState(() => current = newValue);
                          if (_where(current).isEmpty) {
                            _fetchData();
                          }
                        }
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: data.isEmpty ? queryData.size.height : 0,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(12).copyWith(
                      top: queryData.padding.top,
                      bottom: queryData.padding.bottom,
                    ),
                    sliver: SliverStaggeredGrid.countBuilder(
                      crossAxisCount: SystemUtils.isIPad(context) ? 3 : 2,
                      itemCount: data.length,
                      itemBuilder: (_, i) {
                        return _Tile(data[i], '$i-${data[i].id}');
                      },
                      staggeredTileBuilder: (_) => const StaggeredTile.fit(1),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (data.isEmpty) const CupertinoActivityIndicator()
          ],
        );
      }),
    );
  }

  Future<void> _initialize() async {
    AppModel model = AppModel.of(context);
    if (model.types == null) {
      model.types = await TujianApi.getTypes();
    }
    types = model.types.keys.toList();
    controller = ScrollController(
      initialScrollOffset: kSearchBarHeight,
    )..addListener(_onScrollUpdate);
    current = types.first;
    for (int i = 0; i < types.length; i++) {
      cur[types[i]] = 1;
      max[types[i]] = null;
    }
    setState(() {});
    _fetchData();
  }

  Future<void> _fetchData() async {
    doing = true;
    Recents recents = await TujianApi.getRecents(
      sort: current,
      page: cur[current],
      size: 20,
    );
    List<Picture> data = recents.data;
    List<String> list = Settings.marked;
    for (int i = 0; i < data.length; i++) {
      data[i].marked = list.contains(data[i].id);
    }
    max[current] = recents.maximum;
    doing = false;
    AppModel.of(context).recent.addAll(data);
    setState(() {});
  }

  List<Picture> _where(String tid) {
    return AppModel.of(context).recent.where((e) => e.tid == tid).toList();
  }

  void _onScrollUpdate() {
    ScrollPosition pos = controller.position;

    bool shouldFetch = pos.maxScrollExtent - pos.pixels < 256 && !doing;
    if (shouldFetch && max[current] - cur[current] > 0) {
      cur[current] += 1;
      _fetchData();
    }
  }

  void _onScrollEnd() {
    ScrollPosition pos = controller.position;

    Duration duration = const Duration(milliseconds: 300);
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
    controller.removeListener(_onScrollUpdate);
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({
    @required this.onValueChanged,
    @required this.groupValue,
    @required this.vsync,
  });

  final ValueChanged<String> onValueChanged;

  final String groupValue;

  final TickerProvider vsync;

  @override
  Widget build(BuildContext context, double shrinkOffset, _) {
    double extent = math.min<double>(shrinkOffset, kSearchBarHeight);
    double barHeight = kSearchBarHeight - extent;
    EdgeInsets padding = MediaQuery.of(context).padding;
    CupertinoThemeData theme = CupertinoTheme.of(context);
    Map<String, String> types = AppModel.of(context).types;
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
              border: const Border(
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
                  alignment: Alignment.center,
                  child: Text(
                    '往期精选',
                    style: theme.textTheme.navTitleTextStyle,
                  ),
                ),
                SizedBox(
                  width: 500,
                  height: barHeight,
                  child: AnimatedOpacity(
                    opacity: barHeight / kSearchBarHeight < 0.9 ? 0 : 1,
                    duration: const Duration(milliseconds: 100),
                    child: CupertinoSearchBar(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      onTap: () => SearchPage.push(context),
                      readOnly: true,
                    ),
                  ),
                ),
                Container(
                  width: 500,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: CupertinoSlidingSegmentedControl<String>(
                    onValueChanged: onValueChanged,
                    groupValue: groupValue,
                    children: types.map<String, Widget>((key, value) {
                      return MapEntry(key, Text(value));
                    }),
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
  double get maxExtent => minExtent + kSearchBarHeight;

  @override
  double get minExtent => 105;

  @override
  bool shouldRebuild(_) => true;
}

class _Tile extends StatefulWidget {
  _Tile(this.data, this.heroTag);

  final Picture data;

  final String heroTag;

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
        await DetailsPage.push(context, data: widget.data, heroTag: widget.heroTag);
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: const CupertinoDynamicColor.withBrightness(
            color: Colors.white,
            darkColor: Color(0xFF1C1C1E),
          ).resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              offset: Offset(0, 3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 3),
              blurRadius: 1,
            ),
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
                  widget.data.getCompressedUrl('w480'),
                  heroTag: widget.heroTag,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.data.title,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Offstage(
                      offstage: !widget.data.marked,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Ionicons.heart, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  widget.data.date,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
