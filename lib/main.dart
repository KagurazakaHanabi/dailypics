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

import 'package:daily_pics/misc/constants.dart';
import 'package:daily_pics/model/app.dart';
import 'package:daily_pics/pages/splash.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:daily_pics/widget/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.initial();
  ErrorWidget.builder = (details) {
    return CustomErrorWidget(details);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppModel model = AppModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: model,
      child: CupertinoApp(
        title: '图鉴日图',
        home: SplashPage(),
        // FIXME: 2019/9/19 等待 CupertinoApp 加入 darkTheme 字段
        builder: (BuildContext context, Widget child) {
          Brightness brightness = MediaQuery.platformBrightnessOf(context);
          bool isDark = brightness == Brightness.dark;
          CupertinoThemeData theme = isDark ? Themes.dark : Themes.light;
          return CupertinoTheme(
            data: theme,
            child: DefaultTextStyle(
              style: theme.textTheme.textStyle,
              child: child,
            ),
          );
        },
        supportedLocales: [
          Locale('zh'),
          Locale('en'),
        ],
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}
