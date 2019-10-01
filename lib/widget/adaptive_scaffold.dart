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

import 'dart:ui';

import 'package:daily_pics/utils/utils.dart';
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
    if (SystemUtils.isIPad(context)) {
      Size size = MediaQuery.of(context).size;
      double left = padding.left, right = padding.right;
      if (!SystemUtils.isPortrait(context)) {
        left = (size.width - size.height) / 2;
        right = (size.width - size.height) / 2;
      }
      if (SystemUtils.isIPad(context, true)) {
        left += left / 3;
        right += right / 3;
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
              padding: EdgeInsets.only(
                left: left,
                top: padding.top,
                right: right,
                bottom: padding.bottom,
              ),
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
