import 'dart:convert';

import '../../constants/app_message.dart';
import 'group_message.dart';
import 'single_message.dart';

class MessageVideoCallDto {
  String? fromId; // 发送者ID
  String? toId; // 接收者ID
  int? type; // 消息类型

  MessageVideoCallDto({this.fromId, this.toId, this.type});

  factory MessageVideoCallDto.fromJson(Map<String, dynamic> json) {
    return MessageVideoCallDto(
      fromId: json['fromId'],
      toId: json['toId'],
      type: json['type'],
    );
  }
}

/// 消息接收数据传输对象
/// 用于处理接收到的各类消息，包括单聊、群聊和系统消息
class MessageReceiveDto {
  /// 发送者ID
  String? fromId;

  /// 消息唯一标识
  String? messageId;

  /// 消息体，根据messageContentType确定具体类型
  MessageBody? messageBody;

  /// 消息内容类型
  /// 1: 文本消息
  /// 2: 图片消息
  /// 3: 视频消息
  /// 10: 系统消息
  int? messageContentType;

  /// 消息时间戳（毫秒）
  int? messageTime;

  /// 消息读取状态
  /// 0: 未读
  /// 1: 已读
  int? readStatus;

  /// 消息序列号
  int? sequence;

  /// 额外信息
  String? extra;

  /// 单聊接收者ID（仅在单聊时使用）
  String? toId;

  /// 群组ID（仅在群聊时使用）
  String? groupId;

  /// 消息类型
  /// MessageType.singleMessage.code: 单聊消息
  /// MessageType.groupMessage.code: 群聊消息
  /// 999: 系统消息
  int? messageType;

  MessageReceiveDto({
    this.fromId,
    this.messageId,
    this.messageBody,
    this.messageContentType,
    this.messageTime,
    this.readStatus,
    this.sequence,
    this.extra,
    this.toId,
    this.groupId,
    this.messageType,
  });

  /// 从JSON映射创建MessageReceiveDto实例
  factory MessageReceiveDto.fromJson(Map<String, dynamic> json) {
    return MessageReceiveDto(
      fromId: json['fromId'],
      messageId: json['messageId'],
      messageBody:
          _parseMessageBody(json['messageBody'], json['messageContentType']),
      messageContentType: json['messageContentType'],
      messageTime: json['messageTime'],
      readStatus: json['readStatus'] ?? 0,
      sequence: json['sequence'] ?? 0,
      extra: json['extra'] ?? '',
      toId: json['messageType'] == MessageType.singleMessage.code
          ? json['toId']
          : null,
      groupId: json['messageType'] == MessageType.groupMessage.code
          ? json['groupId']
          : null,
      messageType: json['messageType'],
    );
  }

  /// 将对象转换为JSON映射
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fromId': fromId,
      'messageId': messageId,
      'messageBody': messageBody?.toJson(),
      'messageContentType': messageContentType,
      'messageTime': messageTime,
      'readStatus': readStatus,
      'sequence': sequence,
      'extra': extra,
      'messageType': messageType,
    };

    // 根据消息类型添加对应的ID
    if (messageType == MessageType.singleMessage.code) {
      data['toId'] = toId;
    } else if (messageType == MessageType.groupMessage.code) {
      data['groupId'] = groupId;
    }

    return data;
  }

  /// 根据消息内容类型解析消息体
  static MessageBody? _parseMessageBody(Map<String, dynamic>? json, int? type) {
    if (json == null || type == null) return null;

    switch (type) {
      case 1:
        return TextMessageBody.fromJson(json);
      case 2:
        return ImageMessageBody.fromJson(json);
      case 3:
        return VideoMessageBody.fromJson(json);
      case 10:
        return SystemMessageBody.fromJson(json);
      default:
        return null;
    }
  }

  // /// 将 MessageReceiveDto 转换为 Message 对象
  // static Map<String, dynamic> toMessage(MessageReceiveDto dto) {
  //   if(dto.messageContentType == ''){}

  // }

  /// 将 MessageReceiveDto 转换为 SingleMessage 对象
  static SingleMessage toSingleMessage(MessageReceiveDto dto, String ownerId) {
    if (dto.messageType != MessageType.singleMessage.code) {
      throw Exception('Cannot convert non-private message to SingleMessage');
    }

    return SingleMessage(
      messageId: dto.messageId ?? '',
      fromId: dto.fromId ?? '',
      toId: dto.toId ?? '',
      ownerId: ownerId,
      messageBody: jsonEncode(dto.messageBody?.toJson() ?? {}),
      messageContentType: dto.messageContentType ?? 1,
      messageTime: dto.messageTime ?? 0,
      messageType: dto.messageType ?? MessageType.singleMessage.code,
      readStatus: dto.readStatus ?? 0,
      sequence: dto.sequence ?? 0,
      extra: dto.extra ?? '',
    );
  }

  /// 将 MessageReceiveDto 转换为 GroupMessage 对象
  static GroupMessage toGroupMessage(MessageReceiveDto dto, String ownerId) {
    if (dto.messageType != MessageType.groupMessage.code) {
      throw Exception('Cannot convert non-group message to GroupMessage');
    }

    return GroupMessage(
      messageId: dto.messageId ?? '',
      fromId: dto.fromId ?? '',
      ownerId: ownerId,
      groupId: dto.groupId ?? '',
      messageBody: jsonEncode(dto.messageBody?.toJson() ?? {}),
      messageContentType: dto.messageContentType ?? 1,
      messageTime: dto.messageTime ?? 0,
      messageType: dto.messageType ?? MessageType.groupMessage.code,
      readStatus: dto.readStatus ?? 0,
      sequence: dto.sequence ?? 0,
      extra: dto.extra ?? '',
    );
  }

  /// 将 SingleMessage 转换为 MessageReceiveDto 对象
  static MessageReceiveDto fromSingleMessage(SingleMessage message) {
    return MessageReceiveDto(
      messageId: message.messageId,
      fromId: message.fromId,
      toId: message.toId,
      messageType: message.messageType,
      messageContentType: message.messageContentType,
      messageBody: _parseMessageBody(
          jsonDecode(message.messageBody), message.messageContentType),
      messageTime: message.messageTime,
      readStatus: message.readStatus,
      sequence: message.sequence,
      extra: message.extra,
    );
  }

  /// 将 GroupMessage 转换为 MessageReceiveDto 对象
  static MessageReceiveDto fromGroupMessage(GroupMessage message) {
    return MessageReceiveDto(
      messageId: message.messageId,
      fromId: message.fromId,
      groupId: message.groupId,
      messageType: message.messageType,
      messageContentType: message.messageContentType,
      messageBody: _parseMessageBody(
          jsonDecode(message.messageBody), message.messageContentType),
      messageTime: message.messageTime,
      readStatus: message.readStatus,
      sequence: message.sequence,
      extra: message.extra,
    );
  }

// /// 解析消息体 JSON 字符串为对应的 MessageBody 对象
// static MessageBody? _parseMessageBodys(String messageBodyJson) {
//   try {
//     final Map<String, dynamic> json = jsonDecode(messageBodyJson);
//     final String? type = json['type'] as String?;

//     switch (type) {
//       case 'text':
//         return TextMessageBody.fromJson(json);
//       case 'image':
//         return ImageMessageBody.fromJson(json);
//       case 'video':
//         return VideoMessageBody.fromJson(json);
//       case 'system':
//         return SystemMessageBody.fromJson(json);
//       default:
//         return null;
//     }
//   } catch (e) {
//     print('解析消息体失败: $e');
//     return null;
//   }
// }
}

/// 消息体基类
abstract class MessageBody {
  Map<String, dynamic> toJson();
}

/// 文本消息体
class TextMessageBody extends MessageBody {
  /// 文本消息内容
  String? message;

  TextMessageBody({this.message});

  factory TextMessageBody.fromJson(Map<String, dynamic> json) {
    return TextMessageBody(
      message: json['message'],
    );
  }

  /// 将 MessageBody 转换为 TextMessageBody
  static TextMessageBody? fromMessageBody(MessageBody? messageBody) {
    if (messageBody == null) return null;
    if (messageBody is TextMessageBody) return messageBody;

    try {
      final json = messageBody.toJson();
      return TextMessageBody.fromJson(json);
    } catch (e) {
      print('转换TextMessageBody失败: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

/// 图片消息体
class ImageMessageBody extends MessageBody {
  /// 图片名称
  String? name;

  /// 图片URL
  String? url;

  /// 图片大小（字节）
  int? size;

  ImageMessageBody({this.name, this.url, this.size});

  factory ImageMessageBody.fromJson(Map<String, dynamic> json) {
    return ImageMessageBody(
      name: json['name'],
      url: json['url'],
      size: json['size'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'size': size,
    };
  }
}

/// 视频消息体
class VideoMessageBody extends MessageBody {
  /// 视频URL
  String? url;

  VideoMessageBody({this.url});

  factory VideoMessageBody.fromJson(Map<String, dynamic> json) {
    return VideoMessageBody(
      url: json['url'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}

/// 系统消息体
class SystemMessageBody extends MessageBody {
  /// 系统消息内容
  String? message;

  SystemMessageBody({this.message});

  factory SystemMessageBody.fromJson(Map<String, dynamic> json) {
    return SystemMessageBody(
      message: json['message'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

/// 消息类型扩展方法
extension MessageTypeExtension on MessageReceiveDto {
  /// 是否为单聊消息
  bool get isSingleMessage => messageType == MessageType.singleMessage.code;

  /// 是否为群聊消息
  bool get isGroupMessage => messageType == MessageType.groupMessage.code;

  /// 是否为视频消息
  bool get isVideoMessage => messageType == MessageType.videoMessage.code;

  /// 是否为系统消息
  //bool get isSystemMessage => messageType == '999';

  /// 获取目标ID（单聊返回toId，群聊返回groupId）
  String? get targetId {
    if (isSingleMessage) return toId;
    if (isGroupMessage) return groupId;
    return null;
  }
}
