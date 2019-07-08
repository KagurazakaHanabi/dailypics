import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:daily_pics/misc/bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static MethodChannel _channel = MethodChannel('ml.cerasus.pics');

  static Future<void> download(String url, void Function(int, int) cb) async {
    String dest = (await getTemporaryDirectory()).path;
    File file;
    String name;
    if (url.contains('bing.com/')) {
      name = url.substring(url.lastIndexOf('=') + 1);
    } else {
      name = url.substring(url.lastIndexOf('/') + 1) + '.jpg';
      url += '?p=0&f=jpg';
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
    }).onDone(() async {
      await _channel.invokeMethod('syncAlbum', file.path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });
  }

  static Future<void> share(File imageFile) async {
    await _channel.invokeMethod('share', imageFile.path);
  }

  static String getCompressed(Picture data) {
    int w;
    if (data.width > data.height) {
      w = data.width > 1280 ? 1280 : data.width;
    } else {
      w = data.width > 720 ? 720 : data.width;
    }
    if (data.url.contains('bing.com/')) {
      return data.url;
    }
    return data.url + '?f=jpg&q=70&w=$w';
  }

  static T abs<T extends num>(T a) {
    if (a < 0) {
      return -a;
    }
    return a;
  }

  static List<double> colorToHsv(Color c) {
    double r = c.red / 255;
    double g = c.green / 255;
    double b = c.blue / 255;
    double max = math.max(math.max(r, g), math.max(g, b));
    double min = math.min(math.min(r, g), math.min(g, b));
    double v = max;
    double s = (max - min) / max;
    double h;
    if (r == max) {
      h = (g - b) / (max - min) * 60;
    } else if (g == max) {
      h = 120 + (b - r) / (max - min) * 60;
    } else if (b == max) {
      h = 240 + (r - g) / (max - min) * 60;
    }
    if (h < 0) h = h + 360;
    return [h, s, v];
  }

  static bool isColorSimilar(Color c1, Color c2) {
    if (c1 == null || c2 == null) {
      return false;
    }
    return abs(colorToHsv(c1)[2] - colorToHsv(c2)[2]) < 0.1;
  }

  static Future<String> getRemote(String url) async {
    Uri uri = Uri.parse(url);
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    Stream stream = response.cast<List<int>>();
    return await stream.transform(utf8.decoder).join();
  }
}
