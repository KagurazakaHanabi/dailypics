import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'bean.g.dart';

@JsonSerializable()
class Response {
  List<Picture> data;
  String status;

  Response({this.data, this.status});

  factory Response.fromJson(Map<String, dynamic> json) => _$ResponseFromJson(json);

  String toJson() => jsonEncode(_$ResponseToJson(this));

}

@JsonSerializable()
class Picture {
  String id;
  String title;
  String info;
  int width;
  int height;
  String user;
  String url;
  String date;
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

  factory Picture.fromJson(Map<String, dynamic> json) => _$PictureFromJson(json);

  String toJson() => jsonEncode(_$PictureToJson(this));
}
