import 'package:daily_pics/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ThemeModel>(
      model: ThemeModel(),
      child: ScopedModelDescendant<ThemeModel>(
        builder: (_, child, model) {
          return MaterialApp(
            title: 'Tujian R',
            theme: model.theme,
            home: HomePage(),
          );
        },
      ),
    );
  }
}

class ThemeModel extends Model {
  ThemeData _theme = ThemeData(
    primaryColor: Colors.white,
    primaryColorDark: Colors.black45,
    accentColor: Colors.black87,
  );

  ThemeData get theme => _theme;

  set theme(ThemeData newVal) {
    _theme = newVal;
    notifyListeners();
  }

  static ThemeModel of(BuildContext context) {
    return ScopedModel.of<ThemeModel>(context);
  }
}

class C {
  static const String type_chowder = '%E6%9D%82%E7%83%A9';
  static const String type_illus = '%E6%8F%92%E7%94%BB';
  static const String type_desktop = '%E7%94%B5%E8%84%91%E5%A3%81%E7%BA%B8';
  static const String pref_page = 'page';
  static const String pref_debug = 'debug';
  static const String pref_theme = 'theme';
  static const int menu_view_archive = 0;
  static const int menu_download = 1;
  static const int menu_set_wallpaper = 2;
  static const int menu_share = 3;
}
