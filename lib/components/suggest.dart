import 'dart:convert';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:flutter/cupertino.dart';

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
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, int i) => ImageCard(data[i], '###$i'),
                childCount: data?.length ?? 0,
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<void> _fetchData() async {
    String uri = 'https://v2.api.dailypics.cn/random?count=20';
    String source = await Utils.getRemote(uri);
    Response res = Response.fromJson({'data': jsonDecode(source)});
    setState(() => data = res.data);
  }

  @override
  bool get wantKeepAlive => data != null;
}
