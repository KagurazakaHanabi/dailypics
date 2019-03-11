import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'bean.g.dart';

@JsonSerializable()
class Response {
  @JsonKey(name: 'pictures')
  List<Picture> data;

  String status;

  Response({this.data, this.status});

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  String toJson() => jsonEncode(_$ResponseToJson(this));
}

@JsonSerializable()
class Picture {
  @JsonKey(name: 'PID')
  String id;

  @JsonKey(name: 'p_title')
  String title;

  @JsonKey(name: 'p_content')
  String info;

  int width;

  int height;

  @JsonKey(name: 'username')
  String user;

  @JsonKey(name: 'p_link')
  String url;

  @JsonKey(name: 'p_date')
  String date;

  @JsonKey(name: 'TNAME')
  String type;

  Picture(
    this.id,
    this.title,
    this.info,
    this.width,
    this.height,
    this.user,
    this.url,
    this.date,
    this.type,
  );

  factory Picture.fromJson(Map<String, dynamic> json) =>
      _$PictureFromJson(json);

  String toJson() => jsonEncode(_$PictureToJson(this));
}
