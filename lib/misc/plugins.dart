import 'dart:io';

import 'package:flutter/services.dart';

class Plugins {
  static MethodChannel _channel = MethodChannel('ml.cerasus.pics');

  static Future<void> setWallpaper(String url) {
    return _channel.invokeMethod('setWallpaper', url);
  }

  static Future<void> syncGallery(File file) async {
    return _channel.invokeMethod('syncGallery', file.path);
  }
}
