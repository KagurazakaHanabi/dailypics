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
import 'package:dailypics/utils/http.dart';
import 'package:dailypics/utils/windows.dart';
import 'package:dio/dio.dart';
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
    switch (Platform.operatingSystem) {
      case "android":
        await _channel.invokeMethod('useAsWallpaper', file.path);
        break;
      case "windows":
        Windows.useAsWallpaper(file);
        break;
    }
  }

  static Future<void> useAsWallpaperForWindows(File file) async {

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

  /*static Future<void> makeH2Wallpaper(
    Size size,
    Offset offset,
    Color backgroundColor,
    File backgroundImage,
    double backgroundBlurRadius,
    Color dockBarColor,
    Color shadowColor,
    double shadowRadius,
    Offset shadowOffset,
    double borderRadius,
  ) async {
    await _channel.invokeMethod('makeH2Wallpaper', {
      'width': size.width,
      'height': size.height,
      'offsetX': offset.dx,
      'offsetY': offset.dy,
      'background': backgroundColor != null ? backgroundColor.hexString : backgroundImage.path,
      'backgroundBlurRadius': backgroundColor != null ? null : backgroundBlurRadius,
      'dockBarColor': dockBarColor.hexString,
      'shadowColor': shadowColor.hexString,
      'shadowRadius': shadowRadius,
      'shadowOffsetX': shadowOffset.dx,
      'shadowOffsetY': shadowOffset.dy,
      'borderRadius': borderRadius,
    });
  }*/

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

class Settings {
  static SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<String> get marked => _prefs.getStringList('marked') ?? [];

  static set marked(List<String> list) => _prefs.setStringList('marked', list);
}

class DownloadManager {
  static DownloadManager _instance;

  static DownloadManager get instance {
    if (_instance == null) {
      _instance = DownloadManager();
    }
    return _instance;
  }

  List<DownloadTask> _tasks = [];

  Future<DownloadTask> runTask(Picture data, ValueNotifier<double> onProgress) async {
    String url = data.url ?? data.cdnUrl;
    String dest = Platform.isWindows ? (await getDownloadsDirectory()).path : (await getTemporaryDirectory()).path;
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

    CancelToken token = CancelToken();
    DownloadTask task = DownloadTask(
      url: url,
      destFile: file,
      progress: onProgress,
      cancelToken: token,
    );
    _tasks.add(task);
    http.downloadUri(
      Uri.parse(url),
      file.path,
      cancelToken: token,
      onReceiveProgress: (int count, int total) {
        // DownloadTask task = tasks.singleWhere((e) => e.url == url);
        task.progress.value = count / total;
      },
    ).then((value) async {
      if (!Platform.isWindows) {
        await _channel.invokeMethod('syncAlbum', {
          'file': file.path,
          'title': data.title,
          'content': data.content,
        });
      }
      task.progress.value = -1;
      _tasks.remove(task);
    }, onError: (err) => _tasks.remove(task));
    return task;
  }

  List<DownloadTask> queryTask(String url) {
    return _tasks.where((e) => e.url == url).toList();
  }

  void cancel(String url) {
    Iterable<DownloadTask> tasks = _tasks.where((e) => e.url == url);
    for (DownloadTask task in tasks) {
      task.cancelToken.cancel("Abort by user!");
    }
  }
}

class DownloadTask {
  DownloadTask({this.url, this.destFile, this.progress, this.cancelToken});

  String url;
  File destFile;
  ValueNotifier<double> progress;
  CancelToken cancelToken;
}
