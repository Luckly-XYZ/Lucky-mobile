// This is a generated file - do not edit.
//
// Generated from im_connect.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use iMConnectMessageDescriptor instead')
const IMConnectMessage$json = {
  '1': 'IMConnectMessage',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'data',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'data'
    },
    {
      '1': 'metadata',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.im.IMConnectMessage.MetadataEntry',
      '10': 'metadata'
    },
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
    {'1': 'request_id', '3': 6, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'timestamp', '3': 7, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'client_ip', '3': 8, '4': 1, '5': 9, '10': 'clientIp'},
    {'1': 'user_agent', '3': 9, '4': 1, '5': 9, '10': 'userAgent'},
    {'1': 'device_name', '3': 10, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'device_type', '3': 11, '4': 1, '5': 9, '10': 'deviceType'},
  ],
  '3': [IMConnectMessage_MetadataEntry$json],
};

@$core.Deprecated('Use iMConnectMessageDescriptor instead')
const IMConnectMessage_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `IMConnectMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iMConnectMessageDescriptor = $convert.base64Decode(
    'ChBJTUNvbm5lY3RNZXNzYWdlEhIKBGNvZGUYASABKAVSBGNvZGUSFAoFdG9rZW4YAiABKAlSBX'
    'Rva2VuEigKBGRhdGEYAyABKAsyFC5nb29nbGUucHJvdG9idWYuQW55UgRkYXRhEj4KCG1ldGFk'
    'YXRhGAQgAygLMiIuaW0uSU1Db25uZWN0TWVzc2FnZS5NZXRhZGF0YUVudHJ5UghtZXRhZGF0YR'
    'IYCgdtZXNzYWdlGAUgASgJUgdtZXNzYWdlEh0KCnJlcXVlc3RfaWQYBiABKAlSCXJlcXVlc3RJ'
    'ZBIcCgl0aW1lc3RhbXAYByABKANSCXRpbWVzdGFtcBIbCgljbGllbnRfaXAYCCABKAlSCGNsaW'
    'VudElwEh0KCnVzZXJfYWdlbnQYCSABKAlSCXVzZXJBZ2VudBIfCgtkZXZpY2VfbmFtZRgKIAEo'
    'CVIKZGV2aWNlTmFtZRIfCgtkZXZpY2VfdHlwZRgLIAEoCVIKZGV2aWNlVHlwZRo7Cg1NZXRhZG'
    'F0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');
