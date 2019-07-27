import 'dart:ui';

import 'package:daily_pics/misc/utils.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    Key key,
    this.navigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.padding = const EdgeInsets.fromLTRB(80, 48, 80, 0),
    @required this.child,
  })  : assert(child != null),
        assert(resizeToAvoidBottomInset != null),
        super(key: key);

  final ObstructingPreferredSizeWidget navigationBar;

  final Widget child;

  final Color backgroundColor;

  final bool resizeToAvoidBottomInset;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget result = CupertinoPageScaffold(
      child: child,
      navigationBar: navigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
    if (Device.isIPad(context)) {
      Size size = MediaQuery.of(context).size;
      double left = padding.left, right = padding.right;
      if (!Device.isPortrait(context)) {
        left = (size.width - size.height) / 2;
        right = (size.width - size.height) / 2;
      }
      if (Device.isIPad(context, true)) {
        left += left / 2;
        right += right / 2;
      }
      result = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.only(left: left, top: 48, right: right),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: result,
              ),
            )
          ],
        ),
      );
    }
    return result;
  }
}
