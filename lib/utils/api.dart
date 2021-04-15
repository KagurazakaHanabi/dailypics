// Copyright 2019-2021 KagurazakaHanabi<i@hanabi.su>
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
import 'dart:convert';
import 'dart:io';

import 'package:dailypics/misc/bean.dart';
import 'package:dailypics/utils/http.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class TujianApiException implements Exception {
  const TujianApiException(this.message);

  final String message;

  @override
  String toString() => 'TujianApiException: $message';
}

class TujianApi {
  static const String _kBaseUrl = 'https://v2.api.dailypics.cn';

  static Future<Map<String, String>> getTypes() async {
    Response response = await http.getUri(Uri.parse('$_kBaseUrl/sort'));
    Map<String, String> result = {};
    (response.data['result'] as List).forEach((e) {
      result.addAll({e['TID']: e['T_NAME']});
    });
    return result;
  }

  static Future<List<Picture>> getToday() async {
    Response response = await http.getUri(Uri.parse('$_kBaseUrl/today'));
    return Picture.parseList(response.data) ?? [];
  }

  static Future<List<Picture>> getRandom({int count = 1}) async {
    Response response = await http.getUri(Uri.parse('$_kBaseUrl/random?count=$count'));
    return Picture.parseList(response.data) ?? [];
  }

  /// 获取分页归档
  ///
  /// page 页数，不得超过 [Recents.maximum]
  /// size 每页容量，位于区间 [3, 20]
  /// sort 分类 ID
  /// option 排序方式，取值为'asc'或'desc'
  static Future<Recents> getRecents({
    int page = 1,
    int size = 3,
    @required String sort,
    String option = 'desc',
  }) async {
    String url = '$_kBaseUrl/list?page=$page&size=$size&sort=$sort&op=$option';
    Response response = await http.getUri(Uri.parse(url));
    return Recents.fromJson(response.data);
  }

  static Future<Picture> getDetails(String pid) async {
    Response response = await http.getUri(Uri.parse('$_kBaseUrl/member?id=$pid'));
    Map<String, dynamic> json = response.data;
    if (json['error_code'] != null) {
      throw TujianApiException(json['msg']);
    } else {
      return Picture.fromJson(json);
    }
  }

  static Future<List<Picture>> search(String keyword) async {
    String encodedQuery = Uri.encodeQueryComponent(keyword);
    Response response = await http.getUri(Uri.parse('$_kBaseUrl/search/s/$encodedQuery'));
    return Picture.parseList(response.data['result']);
  }

  static Future<Splash> getSplash() async {
    Response response = await http.getUri(Uri.parse('$_kBaseUrl/app/splash'));
    return Splash.fromJson(response.data);
  }

  static Future<dynamic> uploadFile(
    File file,
    ProgressCallback onProgress,
  ) async {
    Uri uri = Uri.parse('https://img.dpic.dev/upload');
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.postUrl(uri);
    String subType = file.path.substring(file.path.lastIndexOf('.') + 1);
    request.headers.set('content-type', 'image/$subType');
    int contentLength = file.statSync().size;
    int byteCount = 0;
    Stream<List<int>> stream = file.openRead();
    await request.addStream(stream.transform(StreamTransformer.fromHandlers(
      handleDone: (sink) => sink.close(),
      handleError: (_, __, ___) {},
      handleData: (data, sink) {
        byteCount += data.length;
        sink.add(data);
        if (onProgress != null) {
          onProgress(byteCount, contentLength);
        }
      },
    )));
    HttpClientResponse response = await request.close();
    return jsonDecode(await response.cast<List<int>>().transform(utf8.decoder).join());
  }

  static Future<dynamic> submit({
    String title,
    String content,
    String url,
    String user,
    String type,
    String email,
  }) async {
    final Map<String, String> data = {
      'title': title,
      'content': content,
      'url': url,
      'user': user,
      'sort': type,
      'hz': email,
    };
    Response response = await http.postUri(Uri.parse('$_kBaseUrl/tg'), data: data);
    return response.data;
  }
}
