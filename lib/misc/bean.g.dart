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
      json['PID'] as String,
      json['p_title'] as String,
      json['p_content'] as String,
      json['width'] as int,
      json['height'] as int,
      json['username'] as String,
      json['p_link'] as String,
      json['p_date'] as String,
      json['TNAME'] as String);
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
