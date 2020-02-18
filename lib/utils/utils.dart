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

import 'dart:async';
import 'dart:io';

import 'package:dailypics/misc/bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel _channel = MethodChannel('ml.cerasus.pics');

class SystemUtils {
  static Future<void> share(File file, [Rect originRect]) async {
    Map<String, dynamic> params = {'file': file.path};
    if (originRect != null) {
      params['originX'] = originRect.left;
      params['originY'] = originRect.top;
      params['originWidth'] = originRect.width;
      params['originHeight'] = originRect.height;
    }
    await _channel.invokeMethod('share', params);
  }

  static Future<void> useAsWallpaper(File file) async {
    await _channel.invokeMethod('useAsWallpaper', file.path);
  }

  static Future<void> requestReview(bool inApp) async {
    await _channel.invokeMethod('requestReview', inApp);
  }

  static Future<bool> isAlbumAuthorized() {
    return _channel.invokeMethod('isAlbumAuthorized');
  }

  static Future<void> openAppSettings() async {
    await _channel.invokeMethod('openAppSettings');
  }

  static Future<void> openUrl(String url) {
    return launch(url, forceSafariVC: false, forceWebView: false);
  }

  static bool isIPad(BuildContext context, [bool strict = false]) {
    Size size = MediaQuery.of(context).size;
    if (strict) {
      return size.shortestSide >= 600;
    }
    return size.width >= 600;
  }

  static bool isPortrait(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.width < size.height;
  }
}

class Utils {
  static Future<File> download(
    Picture data, [
    void Function(int count, int total) cb,
  ]) async {
    Completer<File> completer = Completer();
    String url = data.url ?? data.cdnUrl;
    String dest = (await getTemporaryDirectory()).path;
    File file;
    String name;
    if (url.contains('bing.com/')) {
      name = url.substring(url.lastIndexOf('=') + 1);
    } else {
      name = url.substring(url.lastIndexOf('/') + 1);
    }
    file = File('$dest/$name');
    if (file.existsSync()) {
      file.deleteSync();
    }
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    int count = 0;
    response.listen((data) {
      file.writeAsBytesSync(data, mode: FileMode.writeOnlyAppend);
      if (cb != null) {
        cb(count += data.length, response.contentLength);
      }
    }, onDone: () async {
      await _channel.invokeMethod('syncAlbum', {
        'file': file.path,
        'title': data.title,
        'content': data.content,
      });
      completer.complete(file);
    });
    return completer.future;
  }

  static String getCompressed(Picture data, [String style = 'w720']) {
    if (data.url != null) return data.url;
    return '${data.cdnUrl}!$style';
  }

  static bool isDarkColor(Color c) {
    if (c == null) return false;
    // See https://github.com/FooStudio/tinycolor
    return (c.red * 299 + c.green * 587 + c.blue * 114) / 1000 < 128;
  }

  static bool isUuid(String input) {
    RegExp regExp = RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$',
      caseSensitive: false,
    );
    return regExp.hasMatch(input);
  }
}

class Settings {
  static SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<String> get marked => _prefs.getStringList('marked') ?? [];

  static set marked(List<String> list) => _prefs.setStringList('marked', list);
}
