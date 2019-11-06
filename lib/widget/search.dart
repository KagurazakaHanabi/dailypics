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

const CupertinoDynamicColor _kClearColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

class CupertinoSearchBar extends StatelessWidget {
  CupertinoSearchBar({
    Key key,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 10),
    this.readOnly = false,
    this.autofocus = false,
    this.showCancelButton = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  }) : super(key: key);

  final TextEditingController controller;

  final EdgeInsets padding;

  final bool readOnly;

  final bool autofocus;

  final bool showCancelButton;

  final ValueChanged<String> onChanged;

  final ValueChanged<String> onSubmitted;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoTheme.of(context).barBackgroundColor,
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'CupertinoSearchBar',
              child: CupertinoTextField(
                controller: controller,
                readOnly: readOnly,
                autofocus: autofocus,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onTap: onTap,
                clearButtonMode: OverlayVisibilityMode.editing,
                textInputAction: TextInputAction.search,
                keyboardAppearance: CupertinoTheme.of(context).brightness,
                placeholder: '搜索',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoColors.tertiarySystemFill,
                ),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    color: _kClearColor.resolveFrom(context),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Hero(
            tag: 'CupertinoSearchBar.showCancelButton',
            child: Offstage(
              offstage: !showCancelButton,
              child: CupertinoButton(
                padding: const EdgeInsets.only(left: 16),
                child: const Text('取消', softWrap: false),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
