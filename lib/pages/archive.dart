import 'package:flutter/material.dart';
import 'package:daily_pics/components/archive.dart';

class ArchivePage extends StatelessWidget {
  final String type;

  ArchivePage(this.type);

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    String decodedType = Uri.decodeQueryComponent(type);
    String title = '归档: ${decodedType == '电脑壁纸' ? '桌面' : decodedType}';
    return Scaffold(
      backgroundColor: brightness == Brightness.light ? Colors.white : null,
      appBar: AppBar(title: Text(title)),
      body: ArchiveComponent(type),
    );
  }
}
