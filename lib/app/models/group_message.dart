import 'package:floor/floor.dart';

@Entity(tableName: 'group_message') // Entity 注解，指定表名为 'Chats'
class GroupMessage {
  @primaryKey
  String messageId;
  String fromId;
  String ownerId;
  String groupId;
  String messageBody;
  int messageContentType;
  int messageTime;
  int messageType;
  int readStatus;
  int sequence;
  String extra;

  GroupMessage({
    required this.messageId,
    required this.fromId,
    required this.ownerId,
    required this.groupId,
    required this.messageBody,
    required this.messageContentType,
    required this.messageTime,
    required this.messageType,
    required this.readStatus,
    required this.sequence,
    required this.extra,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'fromId': fromId,
      'ownerId': ownerId,
      'groupId': groupId,
      'messageBody': messageBody,
      'messageContentType': messageContentType,
      'messageTime': messageTime,
      'messageType': messageType,
      'readStatus': readStatus,
      'sequence': sequence,
      'extra': extra,
    };
  }

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      messageId: json['messageId'] as String,
      fromId: json['fromId'] as String,
      ownerId: json['ownerId'] as String,
      groupId: json['groupId'] as String,
      messageBody: json['messageBody'] as String,
      messageContentType: json['messageContentType'] as int,
      messageTime: json['messageTime'] as int,
      messageType: json['messageType'] as int,
      readStatus: json['readStatus'] as int,
      sequence: json['sequence'] as int,
      extra: json['extra'] as String,
    );
  }
}
