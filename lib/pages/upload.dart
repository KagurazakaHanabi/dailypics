import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('提交你的新发现')),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Text(
            '你的每一次提交都将经过我们的人工审核，审核通过的图片我们会保留贡献者 ID，可以在我们'
                '的推送上看到，推荐使用 Telegram 用户名。',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          TextField(
            decoration: InputDecoration(labelText: '用户名'),
          ),
          TextField(
            decoration: InputDecoration(labelText: '上传图片'),
          ),
          TextField(
            decoration: InputDecoration(labelText: '图片标题'),
          ),
          TextField(
            decoration: InputDecoration(labelText: '图片描述 / 一言'),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '回执信息（可选，用于接收审核结果）',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('提交', style: TextStyle(color: Colors.white)),
                color: Theme.of(context).accentColor,
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }
}
