import 'package:flutter/material.dart';
import 'package:daily_pics/components/archive.dart';

class ArchivePage extends StatelessWidget {
  final String type;

  ArchivePage(this.type);

  @override
  Widget build(BuildContext context) {
    String decodedType = Uri.decodeQueryComponent(type);
    String title = '归档: ${decodedType == '电脑壁纸' ? '桌面' : decodedType}';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(title)),
      body: ArchiveComponent(type),
    );
  }
}
