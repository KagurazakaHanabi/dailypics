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
    status: json['status'] as String,
  );
}

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'data': instance.data,
      'status': instance.status,
    };

Picture _$PictureFromJson(Map<String, dynamic> json) {
  return Picture(
    id: json['PID'] as String,
    user: json['username'] as String,
    title: json['p_title'] as String,
    content: json['p_content'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
    url: json['local_url'] as String,
    color: Picture._colorFromHex(json['theme_color'] as String),
    textColor: Picture._colorFromHex(json['text_color'] as String),
    type: json['TNAME'] as String,
    date: json['p_date'] as String,
    marked: json['marked'] as bool ?? false,
  );
}

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
      'PID': instance.id,
      'username': instance.user,
      'p_title': instance.title,
      'p_content': instance.content,
      'width': instance.width,
      'height': instance.height,
      'local_url': instance.url,
      'theme_color': Picture._colorToHex(instance.color),
      'text_color': Picture._colorToHex(instance.textColor),
      'TNAME': instance.type,
      'p_date': instance.date,
      'marked': instance.marked,
    };

Member _$MemberFromJson(Map<String, dynamic> json) {
  return Member(
    assetName: json['assetName'] as String,
    name: json['name'] as String,
    position: json['position'] as String,
    url: json['url'] as String,
  );
}

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'assetName': instance.assetName,
      'name': instance.name,
      'position': instance.position,
      'url': instance.url,
    };
