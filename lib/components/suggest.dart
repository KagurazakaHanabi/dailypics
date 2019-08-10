import 'dart:convert';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/widget/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class SuggestComponent extends StatefulWidget {
  @override
  _SuggestComponentState createState() => _SuggestComponentState();
}

class _SuggestComponentState extends State<SuggestComponent>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();

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
      return CupertinoScrollbar(
        controller: controller,
        child: CustomScrollView(
          controller: controller,
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('推荐'),
            ),
            CupertinoSliverRefreshControl(onRefresh: _fetchData),
            SliverSafeArea(
              top: false,
              sliver: SliverImageCardList(
                tagBuilder: (i) => '$i-${data[i].id}',
                data: data,
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _fetchData() async {
    String uri = 'https://v2.api.dailypics.cn/random?count=20';
    String source = (await http.get(uri)).body;
    Response res = Response.fromJson({'data': jsonDecode(source)});
    setState(() => data = res.data);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => data != null;
}
