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
    tid: json['TID'] as String,
    user: json['username'] as String,
    title: json['p_title'] as String,
    content: json['p_content'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
    url: Picture._replaceHost(json['local_url'] as String),
    color: Picture._colorFromHex(json['theme_color'] as String),
    date: json['p_date'] as String,
    marked: json['marked'] as bool ?? false,
  );
}

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
      'PID': instance.id,
      'TID': instance.tid,
      'username': instance.user,
      'p_title': instance.title,
      'p_content': instance.content,
      'width': instance.width,
      'height': instance.height,
      'local_url': instance.url,
      'theme_color': Picture._colorToHex(instance.color),
      'p_date': instance.date,
      'marked': instance.marked,
    };

Contributor _$ContributorFromJson(Map<String, dynamic> json) {
  return Contributor(
    assetName: json['assetName'] as String,
    name: json['name'] as String,
    position: json['position'] as String,
    url: json['url'] as String,
  );
}

Map<String, dynamic> _$ContributorToJson(Contributor instance) =>
    <String, dynamic>{
      'assetName': instance.assetName,
      'name': instance.name,
      'position': instance.position,
      'url': instance.url,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    nickname: json['nickname'] as String,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'nickname': instance.nickname,
      'username': instance.username,
    };
