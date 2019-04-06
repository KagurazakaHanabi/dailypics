import 'package:daily_pics/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
            supportedLocales: [
              Locale('zh'),
              Locale('en'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

class ThemeModel extends Model {
  ThemeData _theme = Themes.normal;
  ThemeData previous = Themes.normal;

  ThemeData get theme => _theme;

  set theme(ThemeData newVal) {
    if (_theme != Themes.night) {
      previous = _theme;
    }
    _theme = newVal;
    notifyListeners();
  }

  static ThemeModel of(BuildContext context) {
    return ScopedModel.of<ThemeModel>(context);
  }
}

class Themes {
  static final ThemeData normal = ThemeData(
    primaryColor: Colors.white,
    primaryColorDark: Colors.black45,
    accentColor: Colors.black87,
  );
  static final ThemeData amoled = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
  );
  static final ThemeData night = ThemeData(
    brightness: Brightness.dark,
  );
}

class C {
  static const String type_chowder = '%E6%9D%82%E7%83%A9';
  static const String type_illus = '%E6%8F%92%E7%94%BB';
  static const String type_desktop = '%E7%94%B5%E8%84%91%E5%A3%81%E7%BA%B8';
  static const String type_bing = '%E5%BF%85%E5%BA%94';
  static const String pref_page = 'page';
  static const String pref_debug = 'debug';
  static const String pref_theme = 'theme';
  static const String pref_first = 'first';
  static const String pref_night = 'night';
  static const int menu_view_archive = 0;
  static const int menu_download = 1;
  static const int menu_set_wallpaper = 2;
  static const int menu_share = 3;
  static const int theme_normal = 0;
  static const int theme_amoled = 1;
  static const int theme_auto = 2;
}
