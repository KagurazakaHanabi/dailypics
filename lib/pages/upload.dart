import 'dart:io';

import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final String _require = """1. 图片务必清晰，使用新浪图床或 SM.MS 上传源文件
2. 禁止上传含年龄限制、暴力倾向、宗教性质、政治相关等侵害身心健康的图片
3. 不得有侵犯他人合法版权的行为""";

  TextEditingController _imageCtrl = TextEditingController();
  File _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text('上传要求'),
            content: Text(_require),
            actions: <Widget>[
              FlatButton(
                child: Text('了解'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投稿'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done_all),
            tooltip: '提交你的新发现',
            onPressed: _submit,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Text(
            '　　你的每一次提交都将经过我们的人工审核，审核通过的图片我们会保留贡献者 ID，'
            '可以在我们的推送上看到，推荐使用 Telegram 用户名。',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          TextField(
            decoration: InputDecoration(labelText: '用户名'),
          ),
          TextField(
            controller: _imageCtrl,
            decoration: InputDecoration(labelText: '上传图片'),
            onTap: () async {
              _image = await ImagePicker.pickImage(source: ImageSource.gallery);
              _imageCtrl.text = _image.path;
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: '图片标题'),
          ),
          TextField(
            decoration: InputDecoration(labelText: '图片描述 / 一言'),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '联系方式（可选，如邮箱 / Telegram 帐号）',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: RaisedButton(
                  child: Text('提交', style: TextStyle(color: Colors.white)),
                  color: Theme.of(context).accentColor,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    Toast(context, '功能未完成').show();
  }
}
