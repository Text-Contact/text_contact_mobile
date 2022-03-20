// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'querybuilder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Query _$QueryFromJson(Map<String, dynamic> json) => Query(
      json['table'] as String,
    )
      ..selectedColumns = json['selectedColumns'] as Map<String, dynamic>
      ..whereCondition = json['whereCondition'] as String?
      ..orderByClause = (json['orderByClause'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList()
      ..distinctOnColumn = json['distinctOnColumn'] as String?
      ..limit = json['limit'] as int?
      ..offset = json['offset'] as int?;

Map<String, dynamic> _$QueryToJson(Query instance) => <String, dynamic>{
      'table': instance.table,
      'selectedColumns': instance.selectedColumns,
      'whereCondition': instance.whereCondition,
      'orderByClause': instance.orderByClause,
      'distinctOnColumn': instance.distinctOnColumn,
      'limit': instance.limit,
      'offset': instance.offset,
    };
