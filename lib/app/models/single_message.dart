import 'package:floor/floor.dart';

@Entity(tableName: 'single_message') // Entity 注解，指定表名为 'Chats'
class SingleMessage {
  @primaryKey
  String messageId;
  String fromId;
  String toId;
  String ownerId;
  String messageBody;
  int messageContentType;
  int messageTime;
  int messageType;
  int readStatus;
  int sequence;
  String extra;

  SingleMessage({
    required this.messageId,
    required this.fromId,
    required this.toId,
    required this.ownerId,
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
      'toId': toId,
      'ownerId': ownerId,
      'messageBody': messageBody,
      'messageContentType': messageContentType,
      'messageTime': messageTime,
      'messageType': messageType,
      'readStatus': readStatus,
      'sequence': sequence,
      'extra': extra,
    };
  }

  factory SingleMessage.fromJson(Map<String, dynamic> json) {
    return SingleMessage(
      messageId: json['messageId'] as String,
      fromId: json['fromId'] as String,
      toId: json['toId'] as String,
      ownerId: json['ownerId'] as String,
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
