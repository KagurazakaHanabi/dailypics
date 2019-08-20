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

import 'package:flutter/cupertino.dart';

class Button extends StatelessWidget {
  final Widget child;

  final Color color;

  final GestureTapCallback onPressed;

  const Button({
    Key key,
    @required this.child,
    this.color,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        decoration: BoxDecoration(
          color: color ?? CupertinoTheme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(46),
        ),
        child: DefaultTextStyle(
          child: child,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoTheme.of(context).primaryContrastingColor,
          ),
        ),
      ),
    );
  }
}
