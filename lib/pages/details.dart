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

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:daily_pics/widget/adaptive_scaffold.dart';
import 'package:daily_pics/widget/image_card.dart';
import 'package:daily_pics/widget/optimized_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    show CircularProgressIndicator, Colors, Divider;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const double _kBackGestureWidth = 20.0;
const double _kMinFlingVelocity = 1.0; // Screen widths per second.

const int _kMaxAnimationTime = 400; // Milliseconds.

class DetailsPage extends StatefulWidget {
  final Picture data;

  final String pid;

  final String heroTag;

  DetailsPage({this.data, this.pid, this.heroTag});

  @override
  State<StatefulWidget> createState() => _DetailsPageState();

  static Future<void> push(
    BuildContext context, {
    Picture data,
    String pid,
    String heroTag,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      _PageRouteBuilder(
        enableSwipeBack: !SystemUtils.isIPad(context),
        builder: (_, animation, __) {
          return DetailsPage(heroTag: heroTag, data: data, pid: pid);
        },
      ),
    );
  }
}

class _DetailsPageState extends State<DetailsPage> {
  GlobalKey repaintKey = GlobalKey();
  GlobalKey shareBtnKey = GlobalKey();
  bool popped = false;
  Picture data;
  String error;

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (widget.data == null && data == null && error == null) {
      _fetchData();
      result = Center(
        child: CupertinoActivityIndicator(),
      );
    } else if (error != null) {
      result = Center(
        child: Text(
          error,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      );
    } else if (widget.data != null) {
      data = widget.data;
    }
    if (result != null) {
      return AdaptiveScaffold(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            result,
            Align(
              alignment: Alignment.topRight,
              child: _buildCloseButton(),
            ),
          ],
        ),
      );
    }
    CupertinoThemeData theme = CupertinoTheme.of(context);
    Radius radius = Radius.circular(SystemUtils.isIPad(context) ? 16 : 0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Utils.isDarkColor(data.color) && !SystemUtils.isIPad(context)
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: AdaptiveScaffold(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 64),
              child: ImageCard(
                data,
                '#',
                showQrCode: true,
                repaintKey: repaintKey,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 80),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: radius),
              ),
            ),
            NotificationListener<ScrollUpdateNotification>(
              onNotification: _onScrollUpdate,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: data.width / data.height,
                    child: OptimizedImage(
                      Utils.getCompressed(data),
                      heroTag: widget.heroTag ?? DateTime.now(),
                      borderRadius: BorderRadius.vertical(top: radius),
                    ),
                  ),
                  Container(
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: _buildTitle(),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                          child: _buildContent(),
                        ),
                        _buildDivider(),
                        _buildShareButton(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            data.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: _mark,
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              data.marked ? Ionicons.ios_star : Ionicons.ios_star_outline,
              color: CupertinoColors.activeBlue,
              size: 22,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: _SaveButton(data),
        ),
      ],
    );
  }

  Widget _buildContent() {
    CupertinoThemeData theme = CupertinoTheme.of(context);
    TextStyle textStyle = theme.textTheme.textStyle.copyWith(
      fontSize: 15,
      height: 1.2,
    );
    return MarkdownBody(
      data: data.content,
      onTapLink: (String href) => launch(href),
      styleSheet: MarkdownStyleSheet(
        a: TextStyle(color: CupertinoColors.link),
        p: textStyle.copyWith(
          color: CupertinoDynamicColor.withBrightness(
            color: Colors.black54,
            darkColor: Colors.white70,
          ).resolveFrom(context),
        ),
        code: TextStyle(
          color: CupertinoColors.label,
          fontFamily: "monospace",
          fontSize: textStyle.fontSize * 0.85,
        ),
        h1: textStyle.copyWith(
          fontSize: textStyle.fontSize + 10,
        ),
        h2: textStyle.copyWith(
          fontSize: textStyle.fontSize + 8,
        ),
        h3: textStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: textStyle.fontSize + 6,
        ),
        h4: textStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: textStyle.fontSize + 4,
        ),
        h5: textStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: textStyle.fontSize + 2,
        ),
        h6: textStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: textStyle.fontSize,
        ),
        em: TextStyle(fontStyle: FontStyle.italic),
        strong: TextStyle(fontWeight: FontWeight.bold),
        blockquote: textStyle,
        img: textStyle,
        blockSpacing: 8,
        listIndent: 24,
        blockquotePadding: 16,
        blockquoteDecoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          border: Border(
            left: BorderSide(
              color: CupertinoColors.systemGrey4,
              width: 4,
            ),
          ),
        ),
        codeblockPadding: 8,
        codeblockDecoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: CupertinoColors.systemGrey4,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    Color dividerColor = CupertinoDynamicColor.withBrightness(
      color: Colors.black38,
      darkColor: Colors.white54,
    ).resolveFrom(context);
    String username = data.user.isNotEmpty ? '@${data.user} · ' : '';
    String date = _parseDate(data.date);
    TextPainter painter = TextPainter(
      text: TextSpan(text: username + date),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    double width = painter.width / (username.length + date.length);
    Size size = MediaQuery.of(context).size;
    if (painter.width >= size.width) {
      int count = (painter.width - size.width) ~/ width + 2;
      int start = username.length - count;
      username = username.replaceRange(start, username.length, '…');
    }
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 14,
        color: CupertinoDynamicColor.withBrightness(
          color: Colors.black45,
          darkColor: Colors.white60,
        ).resolveFrom(context),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: dividerColor)),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(username),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text(date),
          ),
          Expanded(child: Divider(color: dividerColor)),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    Color color = CupertinoDynamicColor.withBrightness(
      color: CupertinoColors.activeBlue,
      darkColor: Colors.white,
    ).resolveFrom(context);
    return Container(
      key: shareBtnKey,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 29),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CupertinoDynamicColor.withBrightness(
            color: Color(0xFFF2F2F7),
            darkColor: Color(0xFF313135),
          ).resolveFrom(context),
        ),
        child: CupertinoButton(
          pressedOpacity: 0.4,
          padding: EdgeInsets.fromLTRB(30, 12, 30, 12),
          onPressed: _share,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(CupertinoIcons.share, color: color),
              Text(
                '分享',
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Icon(
          CupertinoIcons.clear_circled_solid,
          color: Colors.black38,
          size: 32,
        ),
      ),
    );
  }

  bool _onScrollUpdate(ScrollUpdateNotification n) {
    if (n.metrics.outOfRange && n.metrics.pixels < -64 && !popped) {
      Navigator.of(context).pop();
      popped = true;
    }
    return false;
  }

  Future<void> _fetchData() async {
    String url = 'https://v2.api.dailypics.cn/member?id=${widget.pid}';
    Map<String, dynamic> json = jsonDecode((await http.get(url)).body);
    if (json['error_code'] != null) {
      setState(() => error = json['msg'].toString());
    } else {
      setState(() => data = Picture.fromJson(json));
    }
  }

  String _parseDate(String s) {
    DateTime date = DateTime.parse(s);
    String result = '${date.month} 月 ${date.day} 日';
    if (date.year != DateTime.now().year) {
      result = '${date.year} 年 $result';
    }
    return result;
  }

  void _mark() async {
    if (widget.data != null) {
      widget.data.marked = !widget.data.marked;
    } else {
      data.marked = !data.marked;
    }
    HashSet<String> hashSet = HashSet.from(Settings.marked);
    if (data.marked) {
      hashSet.add(data.id);
    } else {
      hashSet.remove(data.id);
    }
    Settings.marked = hashSet.toList();
    setState(() {});
  }

  void _share() async {
    double pixelRatio = ui.window.devicePixelRatio;
    RenderRepaintBoundary render = repaintKey.currentContext.findRenderObject();
    ui.Image image = await render.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = byteData.buffer.asUint8List();
    String temp = (await getTemporaryDirectory()).path;
    File file = File('$temp/${DateTime.now().millisecondsSinceEpoch}.png');
    file.writeAsBytesSync(bytes);

    RenderBox renderBox = shareBtnKey.currentContext.findRenderObject();
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    Rect rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    await SystemUtils.share(file, rect);
  }
}

class _SaveButton extends StatefulWidget {
  final Picture data;

  _SaveButton(this.data);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool started = false;
  bool denied = false;
  double progress;
  File file;

  @override
  void initState() {
    super.initState();
    SystemUtils.isAlbumAuthorized().then((granted) {
      setState(() => denied = !granted);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = CupertinoDynamicColor.withBrightness(
      color: Color(0xFFF2F2F7),
      darkColor: Color(0xFF313135),
    ).resolveFrom(context);
    Color primaryColor = CupertinoColors.activeBlue;
    return GestureDetector(
      onTap: () async {
        if (denied) {
          SystemUtils.openAppSettings();
        } else if (!started) {
          setState(() => started = true);
          try {
            file = await Utils.download(widget.data, (count, total) {
              if (mounted) {
                setState(() => progress = count / total);
              }
            });
          } on PlatformException catch (e) {
            if (e.code == '-1') setState(() => denied = true);
          }
        } else if (progress == 1 && Platform.isAndroid) {
          SystemUtils.useAsWallpaper(file);
        }
      },
      child: AnimatedCrossFade(
        firstChild: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
          decoration: BoxDecoration(
            color: denied ? CupertinoColors.destructiveRed : backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            denied
                ? '授权'
                : progress != 1 ? '获取' : Platform.isAndroid ? '设定' : '完成',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: denied ? backgroundColor : primaryColor,
            ),
          ),
        ),
        secondChild: Container(
          width: 70,
          height: 26,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 26),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress,
            backgroundColor: progress != null ? backgroundColor : null,
            valueColor: progress == null
                ? AlwaysStoppedAnimation(backgroundColor)
                : AlwaysStoppedAnimation(primaryColor),
          ),
        ),
        crossFadeState: progress == null && !started || progress == 1
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: Duration(milliseconds: 200),
      ),
    );
  }
}

class _PageRouteBuilder<T> extends PageRoute<T> {
  _PageRouteBuilder({
    this.enableSwipeBack = true,
    @required this.builder,
  }) : super();

  final bool enableSwipeBack;

  final RoutePageBuilder builder;

  @override
  final bool opaque = false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 400);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Widget result = FadeTransition(
      opacity: animation,
      child: child,
    );
    if (enableSwipeBack) {
      result = _BackGestureDetector(
        controller: controller,
        navigator: navigator,
        child: result,
      );
    }
    return result;
  }

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => false;
}

class _BackGestureDetector extends StatefulWidget {
  const _BackGestureDetector({
    Key key,
    @required this.child,
    @required this.navigator,
    @required this.controller,
  })  : assert(child != null),
        assert(navigator != null),
        assert(controller != null),
        super(key: key);

  final Widget child;

  final NavigatorState navigator;

  final AnimationController controller;

  @override
  _BackGestureDetectorState createState() => _BackGestureDetectorState();
}

class _BackGestureDetectorState extends State<_BackGestureDetector> {
  HorizontalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer()
      ..onStart = _handleStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handleStart(DragStartDetails details) {
    widget.navigator.didStartUserGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta / context.size.width * 2;
    widget.controller.value -= delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    double velocity = details.velocity.pixelsPerSecond.dx / context.size.width;
    _dragEnd(velocity);
  }

  void _handleDragCancel() => _dragEnd(0.0);

  void _handlePointerDown(PointerDownEvent event) {
    _recognizer.addPointer(event);
  }

  /// The drag gesture has ended with a horizontal motion of
  /// [fractionalVelocity] as a fraction of screen width per second.
  void _dragEnd(double velocity) {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.linear;
    bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = widget.controller.value > 0.75;
    }

    if (animateForward) {
      final int animationTime =
          ui.lerpDouble(_kMaxAnimationTime, 0, widget.controller.value).floor();
      widget.controller.animateTo(
        1.0,
        duration: Duration(milliseconds: animationTime),
        curve: animationCurve,
      );
    } else {
      widget.navigator.pop();

      if (widget.controller.isAnimating) {
        final int animationTime = ui
            .lerpDouble(0, _kMaxAnimationTime, widget.controller.value)
            .floor();
        widget.controller.animateBack(
          0.0,
          duration: Duration(milliseconds: animationTime),
          curve: animationCurve,
        );
      }
    }

    if (widget.controller.isAnimating) {
      AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        widget.navigator.didStopUserGesture();
        widget.controller.removeStatusListener(animationStatusCallback);
      };
      widget.controller.addStatusListener(animationStatusCallback);
    } else {
      widget.navigator.didStopUserGesture();
    }
  }

  @override
  Widget build(BuildContext context) {
    double dragAreaWidth = MediaQuery.of(context).padding.left;
    dragAreaWidth = math.max(dragAreaWidth, _kBackGestureWidth);
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: dragAreaWidth,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}
