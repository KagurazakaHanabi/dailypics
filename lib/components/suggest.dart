import 'dart:convert';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SuggestComponent extends StatefulWidget {
  @override
  _SuggestComponentState createState() => _SuggestComponentState();
}

class _SuggestComponentState extends State<SuggestComponent>
    with AutomaticKeepAliveClientMixin {
  List<Picture> data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (data == null) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    } else {
      return CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('推荐'),
          ),
          CupertinoSliverRefreshControl(onRefresh: _fetchData),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: Device.isIPad()
                  ? EdgeInsets.fromLTRB(12, 12, 12, 0)
                  : EdgeInsets.zero,
              sliver: SliverStaggeredGrid.countBuilder(
                crossAxisCount: Device.isIPad() ? 2 : 1,
                itemCount: data?.length ?? 0,
                staggeredTileBuilder: (i) => StaggeredTile.fit(1),
                itemBuilder: (_, int i) => ImageCard(data[i], '###$i'),
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<void> _fetchData() async {
    String uri = 'https://v2.api.dailypics.cn/random?count=20';
    String source = await Http.get(uri);
    Response res = Response.fromJson({'data': jsonDecode(source)});
    setState(() => data = res.data);
  }

  @override
  bool get wantKeepAlive => data != null;
}
