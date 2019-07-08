import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/pages/details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentComponent extends StatefulWidget {
  @override
  _RecentComponentState createState() => _RecentComponentState();
}

class _RecentComponentState extends State<RecentComponent>
    with AutomaticKeepAliveClientMixin {
  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        CupertinoNavigationBar(
          border: null,
          middle: Text('以往'),
        ),
        Container(
          width: 500,
          padding: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).barBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: Color(0x4c000000),
                width: 0,
              ),
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(fontWeight: FontWeight.w500),
            child: CupertinoSegmentedControl<int>(
              groupValue: sharedValue,
              children: {
                0: Text('杂烩'),
                1: Text('插画'),
                2: Text('桌面'),
              },
              onValueChanged: (int newValue) {
                setState(() => sharedValue = newValue);
              },
            ),
          ),
        ),
        Flexible(
          child: IndexedStack(
            index: sharedValue,
            children: <Widget>[_Page(0), _Page(1), _Page(2)],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Page extends StatefulWidget {
  final int index;

  _Page(this.index);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<_Page> with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();
  List<Picture> data = [];
  bool doing = false;
  int cur = 1;
  int max;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onScroll);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (data.length == 0) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
    return SafeArea(
      top: false,
      child: CupertinoScrollbar(
        child: CustomScrollView(
          controller: controller,
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: <Widget>[
            CupertinoSliverRefreshControl(onRefresh: _fetchData),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              sliver: SliverStaggeredGrid.countBuilder(
                crossAxisCount: 2,
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
    );
  }

  Future<void> _fetchData() async {
    doing = true;
    List<String> types = [C.type_photo, C.type_illus, C.type_deskt];
    String uri =
        'https://v2.api.dailypics.cn/list?page=$cur&size=20&op=desc&sor'
        't=${types[widget.index]}';
    dynamic json = jsonDecode(await Utils.getRemote(uri));
    Response res = Response.fromJson({'data': json['result']});
    data.addAll(await _parseMark(res.data));
    max = json['maxpage'];
    doing = false;
    setState(() {});
  }

  Future<List<Picture>> _parseMark(List<Picture> pics) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('marked') ?? [];
    for (int i = 0; i < pics.length; i++) {
      pics[i].marked = list.contains(pics[i].id);
    }
    return pics;
  }

  void _onScroll() {
    ScrollPosition pos = controller.position;
    if (pos.maxScrollExtent - pos.pixels < 256 && !doing && max - cur > 0) {
      cur += 1;
      _fetchData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onScroll);
  }

  @override
  bool get wantKeepAlive => data != null;
}

class _Tile extends StatelessWidget {
  final Picture data;

  final int index;

  _Tile(this.data, this.index);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              return DetailsPage(data, '$index-${data.id}');
            },
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xffd9d9d9),
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
                aspectRatio: 4 / 5,
                child: Hero(
                  tag: '$index-${data.id}',
                  child: CachedNetworkImage(
                    placeholder: (_, __) => Image.asset('res/placeholder.jpg'),
                    imageUrl: Utils.getCompressed(data),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(data.title, style: TextStyle(fontSize: 15)),
                    ),
                    Offstage(
                      offstage: !data.marked,
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
                child: Text(data.date, style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
