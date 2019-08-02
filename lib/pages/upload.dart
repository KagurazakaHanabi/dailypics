import 'dart:convert';
import 'dart:io';

import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter_ionicons/flutter_ionicons.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  FocusScopeNode focusScopeNode = FocusScopeNode();
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();

  File imageFile;
  String type;
  double progress;

  @override
  Widget build(BuildContext context) {
    EdgeInsets windowPadding = MediaQuery.of(context).padding;
    return CupertinoPageScaffold(
      child: ListView(
        padding: windowPadding + EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: <Widget>[
          _buildImageCard(),
          TextField(
            controller: title,
            placeholder: '标题*',
            minLines: 2,
            onSubmitted: _handleSubmitted,
          ),
          TextField(
            controller: content,
            placeholder: '描述*',
            minLines: 4,
            textInputAction: TextInputAction.newline,
            onSubmitted: _handleSubmitted,
          ),
          CupertinoSegmentedControl<String>(
            selectedColor: Color(0xff9c9c9c),
            borderColor: Color(0xff9c9c9c),
            pressedColor: Color(0xff9c9c9c).withOpacity(0.2),
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
          TextField(
            controller: username,
            placeholder: '用户名*',
            minLines: 2,
            onSubmitted: _handleSubmitted,
          ),
          TextField(
            controller: email,
            placeholder: '邮箱地址',
            minLines: 2,
            textInputAction: TextInputAction.done,
            onSubmitted: _handleSubmitted,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: CupertinoButton(
              pressedOpacity: 0.7,
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Color(0xff353a40),
              child: Text('提交'),
              onPressed: () async {
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
              },
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
                  backgroundColor: Color(0xff9c9c9c),
                  valueColor: AlwaysStoppedAnimation(Color(0xff353a40)),
                ),
              ),
            ),
          ),
        ],
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
            color: Color(0xffe0e0e0),
            image: image,
            boxShadow: [
              BoxShadow(
                color: Color(0xffd9d9d9),
                blurRadius: 12,
              )
            ],
          ),
          child: imageFile != null
              ? Container()
              : Stack(
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
                          color: Color(0xff919191),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Ionicons.ios_add_circle_outline,
                        color: Color(0xff9c9c9c),
                        size: 64,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _handleSubmitted(_) => focusScopeNode.nextFocus();

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
}

class TextField extends StatelessWidget {
  final TextEditingController controller;

  final String placeholder;

  final int minLines;

  final TextInputAction textInputAction;

  final ValueChanged<String> onSubmitted;

  TextField({
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
        cursorColor: Color(0xff353a40),
        style: TextStyle(fontSize: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xff919191), width: 0),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
