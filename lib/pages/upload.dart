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

import 'dart:io';
import 'dart:ui';

import 'package:dailypics/misc/ionicons.dart';
import 'package:dailypics/model/app.dart';
import 'package:dailypics/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';

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
  double progress = -1;

  ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        leading: CupertinoButton(
          child: const Icon(CupertinoIcons.back),
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: const Text('投稿'),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    placeholder: '描述（支持 Markdown 格式）*',
                    textInputAction: TextInputAction.newline,
                  ),
                  ScopedModelDescendant<AppModel>(builder: (_, __, model) {
                    return CupertinoSegmentedControl<String>(
                      selectedColor: const Color(0xFF9C9C9C),
                      borderColor: const Color(0xFF9C9C9C),
                      pressedColor: const Color(0xFF9C9C9C).withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      groupValue: type,
                      children: model.types.map<String, Widget>((key, value) {
                        return MapEntry(key, Text(value));
                      }),
                      onValueChanged: (String newValue) {
                        setState(() => type = newValue);
                      },
                    );
                  }),
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
                    padding: const EdgeInsets.only(top: 8),
                    child: CupertinoButton(
                      pressedOpacity: 0.7,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFF353A40),
                      child: const Text('提交'),
                      onPressed: _onSubmitted,
                    ),
                  ),
                  Opacity(
                    opacity: progress != -1 ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFF9C9C9C),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF353A40),
                          ),
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
        PickedFile file = await picker.getImage(source: ImageSource.gallery);
        if (file != null) {
          setState(() => imageFile = File(file.path));
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFE0E0E0),
            image: image,
            boxShadow: const [
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
                  margin: const EdgeInsets.all(8),
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: const Text('上传须知'),
                            content: const Text(
                              '1. 分辨率不小于 1080P，需备注出处\n'
                              '2. 禁止上传含年龄限制、暴力倾向、宗教性质、政治相关等图片\n'
                              '3. 不得有侵犯他人合法版权的行为',
                              textAlign: TextAlign.left,
                            ),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: const Text('好'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(
                      Ionicons.information_circle_outline,
                      color: Color(0xFF919191),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Ionicons.add_circle_outline,
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
        border: const Border(
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
            child: const Icon(Ionicons.arrow_up),
            onPressed: () => FocusScope.of(context).previousFocus(),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(Ionicons.arrow_down),
            onPressed: () => FocusScope.of(context).nextFocus(),
          ),
          Expanded(child: Container()),
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            child: const Text('完成'),
            onPressed: () => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
    );
  }

  Future<void> _showAlertDialog(String title) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('好'),
              onPressed: () {
                setState(() => progress = -1);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _onSubmitted() async {
    if (progress != -1) return;
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
    if (errors.isNotEmpty) {
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
      await _showAlertDialog(errorText);
      return;
    }

    setState(() => progress = null);
    dynamic json = await TujianApi.uploadFile(
      imageFile,
      (int count, int total) {
        setState(() => progress = count / total);
      },
    );
    if (!json['ret']) {
      await _showAlertDialog(json['error']['message']);
      return;
    }
    dynamic result = await TujianApi.submit(
      title: title.text,
      content: content.text,
      url: 'https://img.dpic.dev/' + json['info']['md5'],
      user: username.text,
      type: type,
      email: email.text,
    );
    if (result['code'] != 200) {
      setState(() => progress = -1);
      await _showAlertDialog('投稿失败，因为：' + result['msg']);
    } else {
      await _showAlertDialog('投稿成功，请等待管理员审核');
      Navigator.of(context).pop();
    }
  }
}

class _TextField extends StatelessWidget {
  _TextField({
    this.controller,
    this.placeholder,
    this.minLines,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;

  final String placeholder;

  final int minLines;

  final TextInputAction textInputAction;

  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        minLines: minLines,
        maxLines: null,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        cursorColor: const Color(0xFF353A40),
        style: const TextStyle(fontSize: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF919191), width: 0),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
