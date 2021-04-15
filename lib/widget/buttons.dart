// Copyright 2019-2021 KagurazakaHanabi<i@hanabi.su>
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
  const Button({
    Key key,
    @required this.child,
    this.color,
    @required this.onPressed,
  }) : super(key: key);

  final Widget child;

  final Color color;

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
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
