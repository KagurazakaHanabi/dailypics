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

import 'dart:convert';
import 'dart:ui';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/model/app.dart';
import 'package:daily_pics/pages/recent.dart';
import 'package:daily_pics/widget/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';

class TodayComponent extends StatefulWidget {
  @override
  _TodayComponentState createState() => _TodayComponentState();
}

class _TodayComponentState extends State<TodayComponent>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();

  String text;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (AppModel.of(context).today == null) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
    bool isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return Stack(
      children: <Widget>[
        CupertinoScrollbar(
          controller: controller,
          child: CustomScrollView(
            controller: controller,
            physics: AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              CupertinoSliverRefreshControl(onRefresh: _fetchData),
              SliverSafeArea(
                sliver: ScopedModelDescendant<AppModel>(
                  builder: (_, __, model) {
                    return SliverImageCardList(
                      header: _buildHeader(),
                      //footer: _buildFooter(),
                      adaptiveTablet: true,
                      data: model.today,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: MediaQuery.of(context).padding.top,
              color: isDark ? Color(0xB7000000) : Color(0xCCFFFFFF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _getDate(),
            style: TextStyle(
              color: CupertinoColors.inactiveGray,
              fontSize: 12,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Offstage(
                  offstage: true,
                  child: Icon(CupertinoIcons.profile_circled, size: 42),
                ),
              ],
            ),
          ),
          Text(
            text ?? ' ',
            style: TextStyle(
              color: CupertinoColors.inactiveGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0x4C000000),
            width: 0,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () => RecentPage.push(context),
        child: Row(
          children: <Widget>[
            Text(
              '往期精选',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            Icon(
              CupertinoIcons.forward,
              color: Colors.black54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getDate() {
    DateTime date = DateTime.now();
    List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '${date.month} 月 ${date.day} 日 星期${weekdays[date.weekday - 1]}';
  }

  Future<void> _fetchData() async {
    _fetchText();
    String source = (await http.get('https://v2.api.dailypics.cn/today')).body;
    Response res = Response.fromJson({'data': jsonDecode(source)});
    List<Picture> data = res.data ?? [];
    List<String> list = Settings.marked;
    for (int i = 0; i < data.length; i++) {
      data[i].marked = list.contains(data[i].id);
    }
    AppModel.of(context).today = data;
  }

  Future<void> _fetchText() async {
    String url = 'https://v1.hitokoto.cn/?encode=text';
    String source = (await http.get(url)).body;
    setState(() => text = source);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
