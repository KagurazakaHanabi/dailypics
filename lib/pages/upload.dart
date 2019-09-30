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
import 'dart:io';
import 'dart:ui';

import 'package:daily_pics/misc/constants.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();

  static Future<void> push(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (_) => UploadPage()),
    );
  }
}

class _UploadPageState extends State<UploadPage> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();

  File imageFile;
  String type;
  double progress;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        leading: CupertinoButton(
          child: Icon(CupertinoIcons.back),
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('投稿'),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                children: <Widget>[
                  _buildImageCard(),
                  _TextField(
                    minLines: 2,
                    controller: title,
                    placeholder: '标题*',
                    textInputAction: TextInputAction.next,
                  ),
                  _TextField(
                    minLines: 4,
                    controller: content,
                    placeholder: '描述*',
                    textInputAction: TextInputAction.next,
                  ),
                  CupertinoSegmentedControl<String>(
                    selectedColor: Color(0xFF9C9C9C),
                    borderColor: Color(0xFF9C9C9C),
                    pressedColor: Color(0xFF9C9C9C).withOpacity(0.2),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    groupValue: type,
                    children: {
                      C.type_photo: Text('杂烩'),
                      C.type_illus: Text('插画'),
                      C.type_deskt: Text('桌面'),
                    },
                    onValueChanged: (String newValue) {
                      setState(() => type = newValue);
                    },
                  ),
                  _TextField(
                    minLines: 2,
                    controller: username,
                    placeholder: '用户名*',
                    textInputAction: TextInputAction.next,
                  ),
                  _TextField(
                    minLines: 2,
                    controller: email,
                    placeholder: '邮箱地址',
                    textInputAction: TextInputAction.done,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CupertinoButton(
                      pressedOpacity: 0.7,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      color: Color(0xFF353A40),
                      child: Text('提交'),
                      onPressed: _onSubmitted,
                    ),
                  ),
                  Opacity(
                    opacity: progress != null ? 1 : 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Color(0xFF9C9C9C),
                          valueColor: AlwaysStoppedAnimation(Color(0xFF353A40)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !FocusScope.of(context).hasFocus,
              child: _buildActionBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    DecorationImage image;
    if (imageFile != null) {
      image = DecorationImage(
        image: FileImage(imageFile),
        fit: BoxFit.cover,
      );
    }
    return GestureDetector(
      onTap: () async {
        File file = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (file != null) {
          setState(() => imageFile = file);
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFFE0E0E0),
            image: image,
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD9D9D9),
                blurRadius: 12,
              )
            ],
          ),
          child: Offstage(
            offstage: imageFile != null,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text('上传须知'),
                          content: Text(
                            '1. 图片分辨率不小于 1080P，需备注出处\n'
                            '2. 禁止上传含年龄限制、暴力倾向、宗教性质、政治相关等图片\n'
                            '3. 不得有侵犯他人合法版权的行为',
                            textAlign: TextAlign.left,
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('好'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(
                      Ionicons.ios_informat_circle_outline,
                      color: Color(0xFF919191),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Ionicons.ios_add_circle_outline,
                    color: Color(0xFF9C9C9C),
                    size: 64,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Color(0x4C000000),
            width: 0,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(Ionicons.ios_arrow_up),
            onPressed: () => FocusScope.of(context).previousFocus(),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(Ionicons.ios_arrow_down),
            onPressed: () => FocusScope.of(context).nextFocus(),
          ),
          Expanded(child: Container()),
          CupertinoButton(
            padding: EdgeInsets.only(right: 16),
            child: Text('完成'),
            onPressed: () => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialog(String title) {
    return showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(title),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('好'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  void _onSubmitted() async {
    if (progress != null) return;
    List<String> errors = [];
    if (imageFile == null) {
      errors.add('图片');
    }
    if (title.text.isEmpty) {
      errors.add('标题');
    }
    if (content.text.isEmpty) {
      errors.add('描述');
    }
    if (username.text.isEmpty) {
      errors.add('用户名');
    }
    if (type == null) {
      errors.add('分类');
    }
    if (errors.length > 0) {
      String errorText = '';
      for (int i = 0; i < errors.length; i++) {
        if (i != 0 && i != errors.length - 1) {
          errorText += '、';
        }
        if (i != 0 && i == errors.length - 1) {
          errorText += '和';
        }
        errorText += errors[i];
      }
      errorText += '不可为空';
      await showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(errorText),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('好'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
      return;
    }
    dynamic json = jsonDecode(await Utils.upload(
      imageFile,
      {
        'title': title.text,
        'content': content.text,
        'url': null,
        'user': username.text,
        'sort': type,
        'hz': email.text,
      },
      (int count, int total) {
        setState(() => progress = count / total);
      },
    ));
    await _showDialog(json['msg']);
    if (json['code'] != 200) {
      setState(() => progress = null);
    } else {
      Navigator.of(context).pop();
    }
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;

  final String placeholder;

  final int minLines;

  final TextInputAction textInputAction;

  final ValueChanged<String> onSubmitted;

  _TextField({
    this.controller,
    this.placeholder,
    this.minLines,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        minLines: minLines,
        maxLines: null,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        cursorColor: Color(0xFF353A40),
        style: TextStyle(fontSize: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF919191), width: 0),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
