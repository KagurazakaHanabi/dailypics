import 'dart:convert';
import 'dart:io';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static MethodChannel _channel = MethodChannel('ml.cerasus.pics');

  static Future<void> _setWallpaper(String url) {
    return _channel.invokeMethod('setWallpaper', url);
  }

  static Future<String> _syncGallery(File file) async {
    return _channel.invokeMethod('syncGallery', file.path);
  }

  static Future<File> cacheImage(Picture source) async {
    Uri uri = Uri.parse(source.url + '?p=0&f=jpg');
    String dest = (await getTemporaryDirectory()).path;
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    File file;
    if (source.url.contains('bing.com/')) {
      String name = source.url.substring(source.url.lastIndexOf('=') + 1);
      file = File('$dest/$name');
    } else {
      file = File('$dest/${source.id}.jpg');
    }
    await response.pipe(file.openWrite());
    return file;
  }

  static void safeLaunch(String url) async {
    if (await canLaunch(url)) await launch(url);
  }

  static Future<String> fetchText() async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(
      'https://api.lwl12.com/hitokoto/v1?encode=text&charset=utf-8',
    ));
    HttpClientResponse response = await request.close();
    return await response.transform(utf8.decoder).join();
  }

  static Future<void> fetchImage(
      BuildContext context,
      Picture data,
      bool wallpaper
  ) async {
    try {
      Toast(context, '正在开始下载...').show();
      File file = await Utils.cacheImage(data);
      String path = await _syncGallery(file);
      if (wallpaper) {
        await _setWallpaper(path);
      }
    } catch (err) {
      Toast(context, '$err').show();
    }
  }

  static Future<void> share(Picture data) async {
    return Share.share('推荐一张图片，「${data.title}」\n图片信息：\n${data.content}\n'
        '查看链接：${data.url}\n来自 Tujian R');
  }

  static String getCompressed(Picture data) {
    int w;
    if (data.width > data.height) {
      w = data.width > 1920 ? 1920 : data.width;
    } else {
      w = data.width > 1080 ? 1080 : data.width;
    }
    if (data.url.contains('bing.com/')) {
      return data.url;
    }
    return data.url + '?f=jpg&q=50&w=$w';
  }
}
