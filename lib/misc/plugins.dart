import 'dart:io';

import 'package:flutter/services.dart';

class Plugins {
  static MethodChannel _channel = MethodChannel('ml.cerasus.pics');

  /// 将图片文件设置为壁纸
  static Future<void> setWallpaper(File file) {
    return _channel.invokeMethod('setWallpaper', <String, dynamic>{
      'file': file.path
    });
  }

  /// 将图片文件从缓存移至相册
  /// @return 移动后的位置
  static Future<String> syncGallery(File file) async {
    return _channel.invokeMethod('syncGallery', <String, dynamic>{
      'file': file.path
    });
  }
}
