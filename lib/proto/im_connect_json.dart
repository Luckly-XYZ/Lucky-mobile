import 'dart:convert';
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';
import '../app/models/message_receive.dart';
import 'im_connect.pb.dart';
import 'google/protobuf/any.pb.dart';

extension IMConnectMessageJson on IMConnectMessage {
  /// 将 IMConnectMessage 实例转换为 JSON `Map<String, dynamic>`.
  ///
  /// - `Int64` 字段会被转换为字符串以防止精度丢失.
  /// - `Any` 字段会使用官方的 toProto3Json() 方法进行转换.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // 使用 has...() 方法可以确保只序列化存在值的字段
    if (hasCode()) {
      json['code'] = code;
    }
    if (hasToken()) {
      json['token'] = token;
    }
    // 特别处理 Any 类型
    if (hasData()) {
      // toProto3Json() 会生成包含 "@type" 字段的
      // 标准 JSON 对象，非常适合动态解析
      json['data'] = data.toProto3Json();
    }
    if (metadata.isNotEmpty) {
      json['metadata'] = metadata;
    }
    if (hasMessage()) {
      json['message'] = message;
    }
    if (hasRequestId()) {
      json['requestId'] = requestId;
    }
    // 特别处理 Int64 类型，转换为字符串
    if (hasTimestamp()) {
      json['timestamp'] = timestamp.toString();
    }
    if (hasClientIp()) {
      json['clientIp'] = clientIp;
    }
    if (hasUserAgent()) {
      json['userAgent'] = userAgent;
    }
    if (hasDeviceName()) {
      json['deviceName'] = deviceName;
    }
    if (hasDeviceType()) {
      json['deviceType'] = deviceType;
    }

    return json;
  }
}