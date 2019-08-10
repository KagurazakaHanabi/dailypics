import 'package:daily_pics/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '图鉴日图',
      home: HomePage(),
      supportedLocales: [
        Locale('zh'),
        Locale('en'),
      ],
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}

class C {
  static const String type_illus = '4ac1c07f-a9f7-11e8-a8ea-0202761b0892';
  static const String type_photo = '5398f27b-a9f7-11e8-a8ea-0202761b0892';
  static const String type_deskt = 'e5771003-b4ed-11e8-a8ea-0202761b0892';
}
