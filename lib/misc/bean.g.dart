// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response(
      data: (json['pictures'] as List)
          ?.map((e) =>
              e == null ? null : Picture.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      status: json['status'] as String);
}

Map<String, dynamic> _$ResponseToJson(Response instance) =>
    <String, dynamic>{'pictures': instance.data, 'status': instance.status};

Picture _$PictureFromJson(Map<String, dynamic> json) {
  return Picture(
      id: json['PID'] as String,
      title: json['p_title'] as String,
      info: json['p_content'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      user: json['username'] as String,
      url: json['p_link'] as String,
      date: json['p_date'] as String,
      type: json['TNAME'] as String);
}

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
      'PID': instance.id,
      'p_title': instance.title,
      'p_content': instance.info,
      'width': instance.width,
      'height': instance.height,
      'username': instance.user,
      'p_link': instance.url,
      'p_date': instance.date,
      'TNAME': instance.type
    };
