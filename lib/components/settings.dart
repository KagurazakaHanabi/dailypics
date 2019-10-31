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

import 'package:dailypics/pages/upload.dart';
import 'package:flutter/cupertino.dart';

class SettingsComponent extends StatefulWidget {
  @override
  _SettingsComponentState createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('更多'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('投稿'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(builder: (_) => UploadPage()),
            );
          },
        ),
      ),
      child: ListView(
        children: <Widget>[],
      ),
    );
  }
}
