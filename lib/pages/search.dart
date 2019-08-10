import 'dart:async';
import 'dart:convert';
import 'dart:ui' show ImageFilter, window;

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

const double kSearchBarHeight = 49;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();

  static Future<void> push(BuildContext context, {String query}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SearchPage(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return _FadeUpwardsPageTransition(animation: animation, child: child);
        },
      ),
    );
  }
}

class _SearchPageState extends State<SearchPage> {
  ScrollController controller = ScrollController();

  List<Picture> data = [];
  bool doing = false;
  String query = '';

  @override
  Widget build(BuildContext context) {
    EdgeInsets windowPadding = MediaQuery.of(context).padding;
    Color barBackgroundColor = CupertinoTheme.of(context).barBackgroundColor;
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: Column(
        children: <Widget>[
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(top: windowPadding.top),
                color: barBackgroundColor,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: SearchBar(
                          autofocus: true,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              query = value;
                              _fetchData();
                            }
                          },
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: Text('取消'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: doing ? 2 : 1 / window.devicePixelRatio,
            child: LinearProgressIndicator(
              backgroundColor: barBackgroundColor,
              valueColor: AlwaysStoppedAnimation(Color(0x4C000000)),
              value: (doing ?? false) ? null : 1,
            ),
          ),
          Flexible(
            child: SafeArea(
              top: false,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: CupertinoScrollbar(
                  controller: controller,
                  child: StaggeredGridView.countBuilder(
                    controller: controller,
                    padding: Device.isIPad(context)
                        ? EdgeInsets.fromLTRB(12, 12, 12, 0)
                        : EdgeInsets.only(left: 4, right: 4),
                    crossAxisCount: Device.isIPad(context) ? 2 : 1,
                    staggeredTileBuilder: (_) => StaggeredTile.fit(1),
                    itemCount: data.length == 0 ? 1 : data.length,
                    itemBuilder: (_, i) {
                      if (data.length != 0) {
                        return ImageCard(data[i], '$query-${data[i].id}');
                      } else if (query.isNotEmpty && !doing) {
                        return Container(
                          padding: EdgeInsets.only(top: 16),
                          alignment: Alignment.center,
                          child: Text(
                            '未找到相关内容',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xB3000000),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() => doing = true);
    String encodedQuery = Uri.encodeQueryComponent(query);
    String url = 'https://v2.api.dailypics.cn/search/s/$encodedQuery';
    Response response = Response.fromJson({
      'data': jsonDecode((await http.get(url)).body)['result'],
    });
    await controller.animateTo(
      0,
      curve: Curves.ease,
      duration: Duration(milliseconds: 300),
    );
    setState(() {
      doing = false;
      data = response.data;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class SearchBar extends StatefulWidget {
  final bool autofocus;

  final double shrinkOffset;

  final VoidCallback onTap;

  final ValueChanged<String> onChanged;

  final ValueChanged<String> onSubmitted;

  const SearchBar({
    Key key,
    this.autofocus = false,
    this.shrinkOffset = 1,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'SearchBar',
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xDDE3E3E8),
          ),
          child: AnimatedOpacity(
            opacity: widget.shrinkOffset < 0.9 ? 0 : 1,
            duration: Duration(milliseconds: 100),
            child: CupertinoTextField(
              autofocus: widget.autofocus,
              placeholder: '搜索',
              decoration: null,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 18),
              placeholderStyle: TextStyle(
                color: CupertinoColors.inactiveGray,
                fontSize: 16,
              ),
              prefix: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  CupertinoIcons.search,
                  color: CupertinoColors.inactiveGray,
                  size: 21,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeUpwardsPageTransition extends StatelessWidget {
  _FadeUpwardsPageTransition({
    Key key,
    @required Animation<double> animation,
    @required this.child,
  })  : _positionAnimation = animation.drive(
          _bottomUpTween.chain(_fastOutSlowInTween),
        ),
        _opacityAnimation = animation.drive(_easeInTween),
        super(key: key);

  static final Tween<Offset> _bottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, 0.25),
    end: Offset.zero,
  );
  static final Animatable<double> _fastOutSlowInTween = CurveTween(
    curve: Curves.fastOutSlowIn,
  );
  static final Animatable<double> _easeInTween = CurveTween(
    curve: Curves.easeIn,
  );

  final Animation<Offset> _positionAnimation;
  final Animation<double> _opacityAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      ),
    );
  }
}
