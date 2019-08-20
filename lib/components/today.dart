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
import 'package:daily_pics/pages/recent.dart';
import 'package:daily_pics/widget/animated_transform.dart';
import 'package:daily_pics/widget/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:http/http.dart' as http;

class TodayComponent extends StatefulWidget {
  @override
  _TodayComponentState createState() => _TodayComponentState();
}

class _TodayComponentState extends State<TodayComponent>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();

  String text;
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
    }
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
                sliver: SliverImageCardList(
                  header: _buildHeader(),
                  footer: _buildFooter(),
                  adaptiveTablet: true,
                  data: data,
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
              color: Colors.transparent,
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
          _RecentCard(), // FIXME 2019/8/20: 临时，后期删除（大概吧...
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
    data = res.data ?? [];
    await _fetchBing();
    await _parseMark();
    setState(() {});
  }

  Future<void> _fetchText() async {
    String url = 'https://yijuzhan.com/api/word.php?m=json';
    String source = (await http.get(url)).body;
    if (source.startsWith('{') && source.endsWith('}')) {
      setState(() => text = jsonDecode(source)['content']);
    } else {
      setState(() => text = source);
    }
  }

  Future<void> _fetchBing() async {
    String url = 'https://cn.bing.com/HPImageArchive.aspx?format=js&n=1&idx=0';
    String source = (await http.get(url)).body;
    Map<String, dynamic> json = jsonDecode(source)['images'][0];
    String copyright = json['copyright'];
    data.add(Picture(
      id: '${json['urlbase']}_1080x1920'.split('?')[1],
      title: _parseBing(copyright)[0],
      content: _parseBing(copyright)[1],
      width: 1080,
      height: 1920,
      user: '',
      url: 'https://cn.bing.com${json['urlbase']}_1080x1920.jpg',
      date: json['enddate'],
      type: ' 必应',
    ));
  }

  List<String> _parseBing(String copyright) {
    List<String> split = copyright.split('，');
    if (split.length > 1) {
      return split;
    }

    split = copyright.replaceAll(RegExp('[【|】]'), '').split(' (');
    return [split[0], split[1].substring(0, split[1].length - 2)];
  }

  Future<void> _parseMark() async {
    List<String> list = Settings.marked;
    for (int i = 0; i < data.length; i++) {
      data[i].marked = list.contains(data[i].id);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => data != null;
}

class _RecentCard extends StatefulWidget {
  @override
  _RecentCardState createState() => _RecentCardState();
}

class _RecentCardState extends State<_RecentCard> {
  final Duration duration = Duration(milliseconds: 150);

  double scale = 1;
  DateTime tapDown;

  @override
  Widget build(BuildContext context) {
    return AnimatedTransform.scale(
      scale: scale,
      duration: duration,
      curve: Curves.easeInOut,
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              spreadRadius: -24,
              blurRadius: 32,
            )
          ],
        ),
        child: GestureDetector(
          onTapDown: (_) {
            tapDown = DateTime.now();
            setState(() => scale = 0.97);
          },
          onTapCancel: () => setState(() => scale = 1.0),
          onTapUp: (_) async {
            if (DateTime.now().difference(tapDown) < duration) {
              await Future.delayed(duration);
            }
            setState(() => scale = 1.0);
            RecentPage.push(context);
          },
          child: Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 2 / 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('res/926de690.jpg', fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '往期精选',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    Icon(
                      Ionicons.ios_arrow_forward,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
