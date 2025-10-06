// This is a generated file - do not edit.
//
// Generated from im_connect.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/any.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class IMConnectMessage extends $pb.GeneratedMessage {
  factory IMConnectMessage({
    $core.int? code,
    $core.String? token,
    $0.Any? data,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $core.String? message,
    $core.String? requestId,
    $fixnum.Int64? timestamp,
    $core.String? clientIp,
    $core.String? userAgent,
    $core.String? deviceName,
    $core.String? deviceType,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (token != null) result.token = token;
    if (data != null) result.data = data;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (message != null) result.message = message;
    if (requestId != null) result.requestId = requestId;
    if (timestamp != null) result.timestamp = timestamp;
    if (clientIp != null) result.clientIp = clientIp;
    if (userAgent != null) result.userAgent = userAgent;
    if (deviceName != null) result.deviceName = deviceName;
    if (deviceType != null) result.deviceType = deviceType;
    return result;
  }

  IMConnectMessage._();

  factory IMConnectMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  factory IMConnectMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IMConnectMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'im'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aOM<$0.Any>(3, _omitFieldNames ? '' : 'data', subBuilder: $0.Any.create)
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'IMConnectMessage.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('im'))
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..aOS(6, _omitFieldNames ? '' : 'requestId')
    ..aInt64(7, _omitFieldNames ? '' : 'timestamp')
    ..aOS(8, _omitFieldNames ? '' : 'clientIp')
    ..aOS(9, _omitFieldNames ? '' : 'userAgent')
    ..aOS(10, _omitFieldNames ? '' : 'deviceName')
    ..aOS(11, _omitFieldNames ? '' : 'deviceType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IMConnectMessage clone() => IMConnectMessage()..mergeFromMessage(this);

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IMConnectMessage copyWith(void Function(IMConnectMessage) updates) =>
      super.copyWith((message) => updates(message as IMConnectMessage))
          as IMConnectMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IMConnectMessage create() => IMConnectMessage._();

  @$core.override
  IMConnectMessage createEmptyInstance() => create();

  static $pb.PbList<IMConnectMessage> createRepeated() =>
      $pb.PbList<IMConnectMessage>();

  @$core.pragma('dart2js:noInline')
  static IMConnectMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IMConnectMessage>(create);
  static IMConnectMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);

  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);

  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);

  @$pb.TagNumber(2)
  set token($core.String value) => $_setString(1, value);

  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);

  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Any get data => $_getN(2);

  @$pb.TagNumber(3)
  set data($0.Any value) => $_setField(3, value);

  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);

  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);

  @$pb.TagNumber(3)
  $0.Any ensureData() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(3);

  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);

  @$pb.TagNumber(5)
  set message($core.String value) => $_setString(4, value);

  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);

  @$pb.TagNumber(5)
  void clearMessage() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get requestId => $_getSZ(5);

  @$pb.TagNumber(6)
  set requestId($core.String value) => $_setString(5, value);

  @$pb.TagNumber(6)
  $core.bool hasRequestId() => $_has(5);

  @$pb.TagNumber(6)
  void clearRequestId() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get timestamp => $_getI64(6);

  @$pb.TagNumber(7)
  set timestamp($fixnum.Int64 value) => $_setInt64(6, value);

  @$pb.TagNumber(7)
  $core.bool hasTimestamp() => $_has(6);

  @$pb.TagNumber(7)
  void clearTimestamp() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get clientIp => $_getSZ(7);

  @$pb.TagNumber(8)
  set clientIp($core.String value) => $_setString(7, value);

  @$pb.TagNumber(8)
  $core.bool hasClientIp() => $_has(7);

  @$pb.TagNumber(8)
  void clearClientIp() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get userAgent => $_getSZ(8);

  @$pb.TagNumber(9)
  set userAgent($core.String value) => $_setString(8, value);

  @$pb.TagNumber(9)
  $core.bool hasUserAgent() => $_has(8);

  @$pb.TagNumber(9)
  void clearUserAgent() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get deviceName => $_getSZ(9);

  @$pb.TagNumber(10)
  set deviceName($core.String value) => $_setString(9, value);

  @$pb.TagNumber(10)
  $core.bool hasDeviceName() => $_has(9);

  @$pb.TagNumber(10)
  void clearDeviceName() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get deviceType => $_getSZ(10);

  @$pb.TagNumber(11)
  set deviceType($core.String value) => $_setString(10, value);

  @$pb.TagNumber(11)
  $core.bool hasDeviceType() => $_has(10);

  @$pb.TagNumber(11)
  void clearDeviceType() => $_clearField(11);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
