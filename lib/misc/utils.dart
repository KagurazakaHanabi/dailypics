import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:daily_pics/misc/bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static MethodChannel _channel = MethodChannel('ml.cerasus.pics');

  static Future<File> download(
    String url,
    void Function(int count, int total) cb,
  ) async {
    Completer<File> completer = Completer();
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
    }, onDone: () async {
      await _channel.invokeMethod('syncAlbum', file.path);
      completer.complete(file);
    });
    return completer.future;
  }

  static Future<String> upload(
    File file,
    Map<String, String> data,
    void Function(int count, int total) cb,
  ) async {
    dynamic json = jsonDecode(
      await Http.upload('https://img.dpic.dev/upload', file, cb),
    );
    if (!json['ret']) {
      return jsonEncode({
        'code': 400,
        'msg': json['error']['message'],
      });
    }
    String url = 'https://img.dpic.dev/' + json['info']['md5'];
    data['url'] = url;
    return await Http.post('https://v2.api.dailypics.cn/tg', data);
  }

  static Future<void> share(File imageFile) async {
    await _channel.invokeMethod('share', imageFile.path);
  }

  static Future<void> useAsWallpaper(File imageFile) async {
    await _channel.invokeMethod('useAsWallpaper', imageFile.path);
  }

  static String getCompressed(Picture data) {
    int width;
    if (data.width > data.height) {
      width = data.width > 1280 ? 1280 : data.width;
    } else {
      width = data.width > 720 ? 720 : data.width;
    }
    if (!data.url.contains('img.dpic.dev/')) {
      return data.url;
    }
    return data.url + '?f=jpg&q=50&w=$width';
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
    return abs(colorToHsv(c1)[2] - colorToHsv(c2)[2]) < 0.2;
  }
}

class Http {
  static Future<String> get(String url) async {
    Uri uri = Uri.parse(url);
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    Stream stream = response.cast<List<int>>();
    return await stream.transform(utf8.decoder).join();
  }

  static Future<String> post(String url, Map<String, dynamic> data) async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.postUrl(Uri.parse(url));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(data));
    HttpClientResponse response = await request.close();
    Stream stream = response.cast<List<int>>();
    return await stream.transform(utf8.decoder).join();
  }

  static Future<String> upload(
    String url,
    File file,
    void Function(int, int) cb,
  ) async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.postUrl(Uri.parse(url));
    String subType = file.path.substring(file.path.lastIndexOf('.') + 1);
    request.headers.set('content-type', 'image/$subType');
    int contentLength = file.statSync().size;
    int byteCount = 0;
    Stream<Uint8List> stream = file.openRead();
    await request.addStream(stream.transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        byteCount += data.length;
        sink.add(data);
        if (cb != null) {
          cb(byteCount, contentLength);
        }
      },
      handleError: (_, __, ___) {},
      handleDone: (sink) => sink.close(),
    )));
    HttpClientResponse response = await request.close();
    return await response.cast<List<int>>().transform(utf8.decoder).join();
  }
}

class Device {
  static bool isIPad(BuildContext context, [bool strict = false]) {
    Size size = MediaQuery.of(context).size;
    if (strict) {
      return size.width >= 600 && size.height >= 600;
    }
    return size.width >= 600;
  }

  static bool isPortrait(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.width < size.height;
  }
}
