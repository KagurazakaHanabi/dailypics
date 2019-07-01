import 'dart:convert';
import 'dart:io';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:flutter/cupertino.dart';

class TodayComponent extends StatefulWidget {
  @override
  _TodayComponentState createState() => _TodayComponentState();
}

class _TodayComponentState extends State<TodayComponent>
    with AutomaticKeepAliveClientMixin {
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
    } else {
      return CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          CupertinoSliverRefreshControl(onRefresh: _fetchData),
          SliverSafeArea(
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, int i) {
                  if (i == 0) {
                    return _buildHeader();
                  } else {
                    return ImageCard(data[i - 1], '#$i');
                  }
                },
                childCount: (data?.length ?? 0) + 1,
              ),
            ),
          ),
        ],
      );
    }
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
          Row(
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
                child: GestureDetector(
                  onTap: () {}, // TODO: 2019/6/28 用户头像
                  child: Icon(CupertinoIcons.profile_circled, size: 36),
                ),
              ),
            ],
          ),
          Text(
            text ?? '',
            style: TextStyle(
              color: CupertinoColors.inactiveGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getDate() {
    DateTime date = DateTime.now();
    List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '${date.month} 月 ${date.day} 日 星期${weekdays[date.weekday - 1]}';
  }

  Future<void> _fetchData() async {
    _fetchText();
    Uri uri = Uri.parse('https://v2.api.dailypics.cn/today');
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    String source = await response.transform(utf8.decoder).join();
    Response res = Response.fromJson({'data': jsonDecode(source)});
    data = res.data ?? [];
    await _fetchBing();
    setState(() {});
  }

  Future<void> _fetchText() async {
    Uri uri = Uri.parse('http://yijuzhan.com/api/word.php?m=json');
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    String source = await response.transform(utf8.decoder).join();
    if (source.startsWith('{') && source.endsWith('}')) {
      setState(() => text = jsonDecode(source)['content']);
    } else {
      setState(() => text = source);
    }
  }

  Future<void> _fetchBing() async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(
      'https://cn.bing.com/HPImageArchive.aspx?format=js&n=1&idx=0',
    ));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    Map<String, dynamic> json = jsonDecode(body)['images'][0];
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
    return[split[0], split[1].substring(0, split[1].length - 2)];
  }

  @override
  bool get wantKeepAlive => data != null;
}
