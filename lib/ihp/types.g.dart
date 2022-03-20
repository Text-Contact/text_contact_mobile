// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      json['id'] as String,
      json['createdAt'] as String,
      json['updatedAt'] as String,
      json['sentAt'] as String?,
      json['completedAt'] as String?,
      json['receivedAt'] as String,
      json['messageTo'] as String,
      json['messageFrom'] as String,
      json['messageBody'] as String,
      json['status'] as String,
      json['direction'] as String,
      json['threadId'] as String,
      json['userId'] as String,
      json['userHasViewed'] as bool,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'sentAt': instance.sentAt,
      'completedAt': instance.completedAt,
      'receivedAt': instance.receivedAt,
      'messageTo': instance.messageTo,
      'messageFrom': instance.messageFrom,
      'messageBody': instance.messageBody,
      'status': instance.status,
      'direction': instance.direction,
      'threadId': instance.threadId,
      'userId': instance.userId,
      'userHasViewed': instance.userHasViewed,
    };
