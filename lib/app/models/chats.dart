import 'package:floor/floor.dart';

import 'base_object.dart';
import 'message_receive.dart';

@Entity(tableName: 'chats', indices: [
  Index(value: ['chatId', 'name'])
]) // Entity 注解，指定表名为 'Chats'  Index 索引
class Chats extends BaseObject {
  @primaryKey
  String chatId;

  //@ColumnInfo(name: 'custom_name') 自定义列名
  //@ignore // Ignore 注解，指定字段将被忽略
  int chatType; // 消息类型
  String ownerId; // 归属人
  String toId; // 接收人
  int isMute; // 免打扰
  int isTop; // 置顶
  int sequence; // 新增字段
  String name; // 名称
  String avatar; // 头像
  int unread = 0; // 消息数
  String id; // id
  String message; // 消息
  int messageTime; // 消息时间

  Chats(
      this.chatId,
      this.chatType,
      this.ownerId,
      this.toId,
      this.isMute,
      this.isTop,
      this.sequence,
      this.name,
      this.avatar,
      this.unread,
      this.id,
      this.message,
      this.messageTime); // 消息时间

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'chatType': chatType,
      'ownerId': ownerId,
      'toId': toId,
      'isMute': isMute,
      'isTop': isTop,
      'sequence': sequence,
      'name': name,
      'avatar': avatar,
      'unread': unread,
      'id': id,
      'message': message,
      'messageTime': messageTime,
    };
  }

  factory Chats.fromJson(Map<String, dynamic> json) {
    return Chats(
      json['chatId']?.toString() ?? '',
      _parseIntSafely(json['chatType']),
      json['ownerId']?.toString() ?? '',
      json['toId']?.toString() ?? '',
      _parseIntSafely(json['isMute']),
      _parseIntSafely(json['isTop']),
      _parseIntSafely(json['sequence']),
      json['name']?.toString() ?? '',
      json['avatar']?.toString() ?? '',
      _parseIntSafely(json['unread']),
      json['id']?.toString() ?? '',
      json['message']?.toString() ?? '',
      _parseIntSafely(json['messageTime']),
    );
  }

  // 添加安全的整数解析方法
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String toChatMessage(MessageReceiveDto dto) {
    String message = '';
    if (dto.messageBody is TextMessageBody) {
      message = (dto.messageBody as TextMessageBody).message ?? '';
    } else if (dto.messageBody is ImageMessageBody) {
      message = '[图片]';
    } else if (dto.messageBody is VideoMessageBody) {
      message = '[视频]';
    } else if (dto.messageBody is SystemMessageBody) {
      message = '[系统消息]';
    }
    return message;
  }
}
