import "package:json_annotation/json_annotation.dart";

part "types.g.dart";

@JsonSerializable()
class Message {
  String id;
  String createdAt;
  String updatedAt;
  String? sentAt;
  String? completedAt;
  String receivedAt;
  String messageTo;
  String messageFrom;
  String messageBody;
  String status;
  String direction;
  String threadId;
  String userId;
  bool userHasViewed;

  Message(
      this.id,
      this.createdAt,
      this.updatedAt,
      this.sentAt,
      this.completedAt,
      this.receivedAt,
      this.messageTo,
      this.messageFrom,
      this.messageBody,
      this.status,
      this.direction,
      this.threadId,
      this.userId,
      this.userHasViewed);

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
