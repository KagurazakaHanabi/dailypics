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

import 'package:dailypics/misc/bean.dart';
import 'package:dailypics/model/app.dart';
import 'package:dailypics/utils/api.dart';
import 'package:dailypics/utils/utils.dart';
import 'package:dailypics/widget/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:http/http.dart' as http;

class TuHitokoto {
  String source;
  String hitokoto;

  TuHitokoto({this.source, this.hitokoto});

  TuHitokoto.fromJson(Map<String, dynamic> json) {
    source = json['source'];
    hitokoto = json['hitokoto'];
  }
}

class TodayComponent extends StatefulWidget {
  @override
  _TodayComponentState createState() => _TodayComponentState();
}

class _TodayComponentState extends State<TodayComponent> with AutomaticKeepAliveClientMixin {
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
    if (AppModel.of(context).today.isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }
    return Stack(
      children: <Widget>[
        CupertinoScrollbar(
          controller: controller,
          child: CustomScrollView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              CupertinoSliverRefreshControl(onRefresh: _fetchData),
              SliverSafeArea(
                sliver: SliverImageCardList(
                  header: _buildHeader(),
                  adaptiveTablet: true,
                  data: AppModel.of(context).today,
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
              color: const CupertinoDynamicColor.withBrightness(
                color: Color(0xCCFFFFFF),
                darkColor: Color(0xB7000000),
              ).resolveFrom(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    TextStyle textStyle = TextStyle(
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_getDate(), style: textStyle),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Today',
                  style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                ),
                const Offstage(
                  offstage: true,
                  child: Icon(CupertinoIcons.profile_circled, size: 42),
                ),
              ],
            ),
          ),
          GestureDetector(
            child: Text(text ?? '　', style: textStyle),
            onLongPress: () async {
              await Clipboard.setData(ClipboardData(text: text));
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    icon: Ionicons.ios_checkmark,
                    text: Text('已复制'),
                  );
                },
              );
            },
          ),
        ],
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
    List<Picture> data = await TujianApi.getToday();
    data.add(await _fetchBing());
    List<String> list = Settings.marked;
    for (int i = 0; i < data.length; i++) {
      data[i].marked = list.contains(data[i].id);
    }
    AppModel.of(context).today = data;
  }

  Future<void> _fetchText() async {
    String url = 'https://cloudgw.api.dailypics.cn/release/tu_hitokoto';
    String body = (await http.get(url)).body;
    String source = TuHitokoto.fromJson(jsonDecode(body)).hitokoto;
    if (mounted) setState(() => text = source);
  }

  Future<Picture> _fetchBing() async {
    String url = 'https://cn.bing.com/HPImageArchive.aspx?format=js&n=1&idx=0';
    String source = (await http.get(url)).body;
    Map<String, dynamic> json = jsonDecode(source)['images'][0];
    String copyright = json['copyright'];
    return Picture(
      id: '${json['urlbase']}_1080x1920'.split('?')[1],
      title: _parseBing(copyright)[0],
      content: _parseBing(copyright)[1],
      width: 1080,
      height: 1920,
      user: '',
      url: 'https://cn.bing.com${json['urlbase']}_1080x1920.jpg',
      date: json['enddate'],
    );
  }

  List<String> _parseBing(String copyright) {
    List<String> split = copyright.split('，');
    if (split.length > 1) {
      return split;
    }

    split = copyright.replaceAll(RegExp('[【|】]'), '').split(' (');
    return [split[0], split[1].substring(0, split[1].length - 2)];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class AlertDialog extends StatefulWidget {
  const AlertDialog({this.icon, this.text});

  final IconData icon;

  final Widget text;

  @override
  State<StatefulWidget> createState() => _AlertDialogState();
}

class _AlertDialogState extends State<AlertDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: const Size(128, 96),
        child: CupertinoPopupSurface(
          child: Center(
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Text(
                  String.fromCharCode(widget.icon.codePoint),
                  style: TextStyle(
                    fontFamily: widget.icon.fontFamily,
                    package: widget.icon.fontPackage,
                    fontSize: 48,
                    height: 0.7,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: widget.text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
