// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datasync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataSyncResult _$DataSyncResultFromJson(Map<String, dynamic> json) =>
    DataSyncResult(
      json['tag'] as String,
      json['requestId'] as int,
      (json['result'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$DataSyncResultToJson(DataSyncResult instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'requestId': instance.requestId,
      'result': instance.result,
    };

DataSyncError _$DataSyncErrorFromJson(Map<String, dynamic> json) =>
    DataSyncError(
      json['tag'] as String,
      json['requestId'] as int,
      json['errorMessage'] as String,
    );

Map<String, dynamic> _$DataSyncErrorToJson(DataSyncError instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'requestId': instance.requestId,
      'errorMessage': instance.errorMessage,
    };
