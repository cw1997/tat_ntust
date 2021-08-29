// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingJson _$SettingJsonFromJson(Map<String, dynamic> json) {
  return SettingJson(
    course: json['course'] == null
        ? null
        : CourseSettingJson.fromJson(json['course'] as Map<String, dynamic>),
    other: json['other'] == null
        ? null
        : OtherSettingJson.fromJson(json['other'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SettingJsonToJson(SettingJson instance) =>
    <String, dynamic>{
      'course': instance.course,
      'other': instance.other,
    };

CourseSettingJson _$CourseSettingJsonFromJson(Map<String, dynamic> json) {
  return CourseSettingJson(
    info: json['info'] == null
        ? null
        : CourseTableJson.fromJson(json['info'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CourseSettingJsonToJson(CourseSettingJson instance) =>
    <String, dynamic>{
      'info': instance.info,
    };

OtherSettingJson _$OtherSettingJsonFromJson(Map<String, dynamic> json) {
  return OtherSettingJson(
    lang: json['lang'] as String,
    autoCheckAppUpdate: json['autoCheckAppUpdate'] as bool,
    useExternalVideoPlayer: json['useExternalVideoPlayer'] as bool,
  );
}

Map<String, dynamic> _$OtherSettingJsonToJson(OtherSettingJson instance) =>
    <String, dynamic>{
      'lang': instance.lang,
      'autoCheckAppUpdate': instance.autoCheckAppUpdate,
      'useExternalVideoPlayer': instance.useExternalVideoPlayer,
    };