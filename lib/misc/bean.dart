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

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bean.g.dart';

@JsonSerializable()
class Response {
  List<Picture> data;

  String status;

  Response({this.data, this.status});

  factory Response.fromJson(Map<String, dynamic> json) {
    return _$ResponseFromJson(json);
  }

  String toJson() => jsonEncode(_$ResponseToJson(this));
}

@JsonSerializable()
class Picture {
  @JsonKey(name: 'PID')
  String id;

  @JsonKey(name: 'username')
  String user;

  @JsonKey(name: 'p_title')
  String title;

  @JsonKey(name: 'p_content')
  String content;

  int width;

  int height;

  @JsonKey(name: 'local_url')
  String url;

  @JsonKey(name: 'theme_color', fromJson: _colorFromHex, toJson: _colorToHex)
  Color color;

  @JsonKey(name: 'text_color', fromJson: _colorFromHex, toJson: _colorToHex)
  Color textColor;

  @JsonKey(name: 'TNAME')
  String type;

  @JsonKey(name: 'p_date')
  String date;

  @JsonKey(defaultValue: false)
  bool marked;

  Picture({
    this.id,
    this.user,
    this.title,
    this.content,
    this.width,
    this.height,
    this.url,
    this.color,
    this.textColor,
    this.type,
    this.date,
    this.marked,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return _$PictureFromJson(json);
  }

  String toJson() => jsonEncode(_$PictureToJson(this));

  static _colorFromHex(String hex) {
    hex = hex.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF' + hex;
    } else if (hex.length == 3) {
      hex = 'FF' + hex[0] * 2 + hex[1] * 2 + hex[2] * 2;
    }
    return Color(int.parse(hex, radix: 16));
  }

  static _colorToHex(Color color) {
    return '#' + color.value.toRadixString(16);
  }
}

@JsonSerializable()
class Member {
  String assetName;

  String name;

  String position;

  String url;

  Member({this.assetName, this.name, this.position, this.url});

  factory Member.fromJson(Map<String, dynamic> json) {
    return _$MemberFromJson(json);
  }

  String toJson() => jsonEncode(_$MemberToJson(this));
}

@JsonSerializable()
class User {
  String nickname;

  String username;

  User({this.nickname, this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return _$UserFromJson(json);
  }

  String toJson() => jsonEncode(_$UserToJson(this));
}
