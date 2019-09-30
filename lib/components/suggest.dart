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

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/utils/api.dart';
import 'package:daily_pics/widget/slivers.dart';
import 'package:flutter/cupertino.dart';

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
          physics: AlwaysScrollableScrollPhysics(),
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
    data = await TujianApi.getRandom(count: 20);
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => data != null;
}
