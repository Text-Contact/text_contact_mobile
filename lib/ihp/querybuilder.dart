import "package:text_contact_mobile/ihp/datasync.dart";
import "package:json_annotation/json_annotation.dart";

part "querybuilder.g.dart";

class ConditionBuildable {}

@JsonSerializable()
class Query {
  String table;
  Map<String, dynamic> selectedColumns = {"tag": String};
  String? whereCondition;
  late List<Map<String, String>> orderByClause;
  String? distinctOnColumn;
  int? limit;
  int? offset;

  Query(this.table) {
    selectedColumns = {"tag": "SelectAll"};
    orderByClause = [];
  }

  factory Query.fromJson(Map<String, dynamic> json) => _$QueryFromJson(json);
  Map<String, dynamic> toJson() => _$QueryToJson(this);
}

class QueryBuilder extends ConditionBuildable {
  String table;
  List<String>? columns;
  late Query query;
  String? transactionId;

  QueryBuilder(this.table, [this.columns]) {
    query = Query(table);
    if (columns != null) select(columns!);
  }

  QueryBuilder select(List<String> columns) {
    query.selectedColumns["tag"] = "SelectSpecific";

    query.selectedColumns["contents"] = [];
    final contents = List<String>.from(query.selectedColumns["contents"]);
    for (final column in columns) {
      if (!contents.contains(column)) {
        contents.add(column);
      }
    }
    query.selectedColumns["contents"] = contents;

    return this;
  }

  QueryBuilder distinctOn(String column) {
    query.distinctOnColumn = column;

    return this;
  }

  QueryBuilder orderBy(String column) {
    return orderByAsc(column);
  }

  QueryBuilder orderByAsc(String column) {
    query.orderByClause
        .add({"orderByColumn": column, "orderByDirection": "Asc"});

    return this;
  }

  QueryBuilder orderByDesc(String column) {
    query.orderByClause
        .add({"orderByColumn": column, "orderByDirection": "Desc"});

    return this;
  }

  QueryBuilder limit(limit) {
    query.limit = limit;

    return this;
  }

  QueryBuilder offset(offset) {
    query.offset = offset;

    return this;
  }

  Future<dynamic> fetch() async {
    final response = await DataSyncController.getInstance().sendMessage({
      "tag": "DataSyncQuery",
      "query": query.toJson(),
      "transactionId": transactionId,
    });

    return response.result;
  }

  Future<dynamic> fetchOne() async {
    query.limit = 1;
    final result = await fetch();
    if (result.length > 0) {
      return result[0];
    } else {
      return null;
    }
  }
}

QueryBuilder query(String table) {
  return QueryBuilder(table);
}
