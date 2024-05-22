// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserAuthImpl _$$UserAuthImplFromJson(Map<String, dynamic> json) =>
    _$UserAuthImpl(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$$UserAuthImplToJson(_$UserAuthImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
    };
