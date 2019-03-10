// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response(
      data: (json['data'] as List)
          ?.map((e) =>
              e == null ? null : Picture.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      status: json['status'] as String);
}

Map<String, dynamic> _$ResponseToJson(Response instance) =>
    <String, dynamic>{'data': instance.data, 'status': instance.status};

Picture _$PictureFromJson(Map<String, dynamic> json) {
  return Picture(
      json['id'] as String,
      json['title'] as String,
      json['info'] as String,
      json['width'] as int,
      json['height'] as int,
      json['user'] as String,
      json['url'] as String,
      json['date'] as String,
      json['type'] as String);
}

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'info': instance.info,
      'width': instance.width,
      'height': instance.height,
      'user': instance.user,
      'url': instance.url,
      'date': instance.date,
      'type': instance.type
    };
