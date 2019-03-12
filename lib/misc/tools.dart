import 'dart:convert';
import 'dart:io';

import 'package:daily_pics/misc/bean.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Tools {
  static Future<File> cacheImage(Picture source) async {
    Uri uri = Uri.parse(source.url);
    String dest = (await getTemporaryDirectory()).path;
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    String filename;
    String s = response.headers.value('Content-Disposition') ?? '';
    if (s.isEmpty) {
      s = source.url;
      filename = s.split('?')[0].substring(s.lastIndexOf('/') + 1);
    } else {
      filename = s.replaceRange(0, s.indexOf('filename=') + 9, '');
    }
    String suffix = filename.substring(filename.lastIndexOf('.'));
    File file = File('$dest/${source.id}$suffix');
    await response.pipe(file.openWrite());
    return file;
  }

  static void safeLaunch(String url) async {
    if (await canLaunch(url)) await launch(url);
  }

  static Future<String> fetchText() async {
    Uri uri = Uri.parse('https://dp.chimon.me/api/hitokoto.php');
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    return await response.transform(utf8.decoder).join();
  }
}