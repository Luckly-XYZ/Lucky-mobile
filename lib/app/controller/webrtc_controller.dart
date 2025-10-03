import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as flutter_webrtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/api_service.dart';

/// WebRTC 控制器（优化版）
/// 主要改进：
/// 1. 为本地预览创建单独的流，仅包含视频轨道，避免本地音频回路产生啸声。
/// 2. 统一配置音频采集参数，确保开启回声消除、自动增益和噪声抑制。
class WebRtcController extends GetxController {
  /// 视频输出设备id
  String? selectedVideoInputId;

  MediaStream? _localStream;
  VideoSize? videoSize;

  /// 用户自身推流状态 0 未开始  1 成功 2 失败
  final isConnectState = 0.obs;
  late ApiService _apiService;

  // 统一音频采集约束，确保启用回声消除、自动增益控制和噪声抑制
  Map<String, dynamic> mediaConstraints = {
    'audio': {
      "echoCancellation": true, // 回声消除
      "autoGainControl": true, // 自动增益控制
      "noiseSuppression": true, // 噪声抑制
    },
    'video': {
      'facingMode': 'user', // 使用前置摄像头
      'mirror': true,
    },
  };

  List<RTCRtpSender> senders = <RTCRtpSender>[];

  /// rtc 视频流数组
  final rtcList = [].obs;

  /// 设备信息
  List devices = [];

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
  }

  /// 添加远程视频（逻辑保持不变）
  Future<bool> addRemoteLive(String url, String webrtcUrl,
      {Function(bool)? callback}) async {
    try {
      int maxRetries = 3;
      int currentRetry = 0;
      bool success = false;

      while (currentRetry < maxRetries && !success) {
        try {
          int renderId = DateTime.now().millisecondsSinceEpoch;
          RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
          await remoteRenderer.initialize();

          var pc2 = await createPeerConnection({
            'sdpSemantics': 'unified-plan',
            'iceServers': [
              {'urls': 'stun:stun.l.google.com:19302'},
            ],
            'bundlePolicy': 'max-bundle',
            'rtcpMuxPolicy': 'require',
          });

          pc2.onTrack = (event) {
            if (event.track.kind == 'video') {
              remoteRenderer.srcObject = event.streams[0];
            }
          };

          var offer = await pc2.createOffer({
            'mandatory': {
              'OfferToReceiveAudio': true,
              'OfferToReceiveVideo': true,
            },
          });
          await pc2.setLocalDescription(offer);

          pc2.onConnectionState = (state) {
            onConnectionState(state, renderId);
            if (state ==
                RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
              success = true;
            }
          };

          pc2.onIceConnectionState = (state) {
            onIceConnectionState(state, renderId);
          };

          var answer = await _apiService.webRtcHandshake(
              url, webrtcUrl, offer.sdp ?? '');
          if (answer == null) throw Exception('Failed to get remote answer');
          await pc2.setRemoteDescription(answer);

          Map webRtcData = {
            "renderId": renderId,
            "pc": pc2,
            "renderer": remoteRenderer,
            "self": false,
          };

          rtcList.value = [...rtcList, webRtcData];
          success = true;
          callback?.call(true);
          return true;
        } catch (e) {
          currentRetry++;
          if (currentRetry >= maxRetries) {
            Get.log('拉流重试失败，错误: $e');
            callback?.call(false);
            return false;
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }
      return success;
    } catch (e) {
      Get.log('添加远程视频失败: $e');
      callback?.call(false);
      return false;
    }
  }

  /// 开启摄像头预览（优化版）
  /// 1. 获取完整的音视频流用于推流；
  /// 2. 为本地预览创建只包含视频轨道的新流，避免音频回传导致啸声问题。
  Future<void> openVideo() async {
    // 建立 PeerConnection 用于本地推流
    var locatPc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
    });
    int renderId = DateTime.now().millisecondsSinceEpoch;
    RTCVideoRenderer localRenderer = RTCVideoRenderer();
    await localRenderer.initialize();

    // 如果设置了视频尺寸，则加入到视频约束中
    if (videoSize != null) {
      mediaConstraints['video']['width'] = videoSize?.width;
      mediaConstraints['video']['height'] = videoSize?.height;
    }
    // 获取包含音频和视频的本地流（用于推流）
    _localStream = await flutter_webrtc.navigator.mediaDevices
        .getUserMedia(mediaConstraints);

    // 将所有轨道添加到 PeerConnection 中
    _localStream?.getTracks().forEach((MediaStreamTrack track) async {
      var rtpSender = await locatPc.addTrack(track, _localStream!);
      senders.add(rtpSender);
    });

    // 创建一个新的媒体流，只添加视频轨道，作为本地预览流，防止回音和啸声问题
    MediaStream videoPreviewStream =
        await createLocalMediaStream('videoPreview');
    for (var track in _localStream!.getVideoTracks()) {
      videoPreviewStream.addTrack(track);
    }
    // 将只包含视频轨道的流赋值给本地渲染器
    localRenderer.srcObject = videoPreviewStream;

    Map webRtcData = {
      "renderId": renderId,
      "pc": locatPc,
      "renderer": localRenderer,
      "self": true,
    };

    rtcList.value = [
      webRtcData,
      ...rtcList,
    ];
  }

  /// 切换摄像头（代码保持不变）
  Future<void> selectVideoInput(String? deviceId) async {
    selectedVideoInputId = deviceId;

    mediaConstraints = {
      'audio': true,
      'video': {
        if (selectedVideoInputId != null && kIsWeb)
          'deviceId': selectedVideoInputId,
        if (selectedVideoInputId != null && !kIsWeb)
          'optional': [
            {'sourceId': selectedVideoInputId}
          ],
        'frameRate': 60,
      },
    };

    setMediaConstraints(deviceId, mediaConstraints);
  }

  /// 设置视频大小（代码保持不变）
  Future<void> setVideoSize(width, height) async {
    videoSize = VideoSize(width, height);
    mediaConstraints = {
      'audio': true,
      'video': {
        if (selectedVideoInputId != null && kIsWeb)
          'deviceId': selectedVideoInputId,
        if (selectedVideoInputId != null && !kIsWeb)
          'optional': [
            {'sourceId': selectedVideoInputId}
          ],
        'width': videoSize?.width,
        'height': videoSize?.height,
        'frameRate': 60,
      },
    };

    setMediaConstraints(selectedVideoInputId, mediaConstraints);
  }

  /// 切换推流视频配置（代码保持不变）
  Future<void> setMediaConstraints(String? deviceId, mediaConstraints) async {
    selectedVideoInputId = deviceId;

    var localRenderer = rtcList[0]['renderer'];
    localRenderer.srcObject = null;

    _localStream?.getTracks().forEach((track) async {
      await track.stop();
    });

    var newLocalStream = await flutter_webrtc.navigator.mediaDevices
        .getUserMedia(mediaConstraints);
    _localStream = newLocalStream;
    localRenderer.srcObject = _localStream;

    var newTrack = _localStream?.getVideoTracks().first;
    var sender =
        senders.firstWhereOrNull((sender) => sender.track?.kind == 'video');
    var params = sender!.parameters;
    params.degradationPreference = RTCDegradationPreference.MAINTAIN_RESOLUTION;
    await sender.setParameters(params);
    await sender.replaceTrack(newTrack);
  }

  /// 建立本地视频推流（代码保持不变）
  Future<bool> addLocalMedia(String url, String webrtcUrl,
      {Function(bool)? callback}) async {
    try {
      var locatPc = rtcList[0]['pc'];
      var renderId = rtcList[0]['renderId'];

      locatPc.onConnectionState = (state) {
        onConnectionState(state, renderId);
      };
      locatPc.onIceConnectionState = (state) {
        onIceConnectionState(state, renderId);
      };
      locatPc.getStats().then(peerConnectionState);

      var offer = await locatPc.createOffer();
      await locatPc.setLocalDescription(offer);
      var answer = await _apiService
          .webRtcHandshake(url, webrtcUrl, offer.sdp ?? '', type: 'publish');

      if (answer == null) {
        callback?.call(false);
        return false;
      }
      await locatPc.setRemoteDescription(answer);
      callback?.call(true);
      return true;
    } catch (e) {
      Get.log('开启本地 推流出错$e');
      callback?.call(false);
      return false;
    }
  }

  /// 关闭指定的推流（代码保持不变）
  Future<void> closeRenderId(int renderId) async {
    var _inx = rtcList.indexWhere((item) => item['renderId'] == renderId);
    if (_inx == -1) {
      Get.log('直播不存在');
      return;
    }
    rtcList[_inx]['pc'].close();
    rtcList[_inx]['renderer'].srcObject = null;
    rtcList.removeAt(_inx);
  }

  /// 关闭全部推流（代码保持不变）
  Future<void> close() async {
    _localStream?.getTracks().forEach((track) async {
      await track.stop();
    });
    _localStream?.dispose();
    _localStream = null;

    for (var i = 0; i < rtcList.length; i++) {
      await rtcList[i]['renderer'].dispose();
      await rtcList[i]['pc'].dispose();
    }

    rtcList.clear();
    rtcList.value = [];

    isConnectState.value = 0;
    selectedVideoInputId = null;
  }

  /// 获取设备列表信息（代码保持不变）
  Future<void> loadDevices() async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      var status = await Permission.bluetooth.request();
      if (status.isPermanentlyDenied) {
        Get.log('BLEpermdisabled');
      }
      status = await Permission.bluetoothConnect.request();
      if (status.isPermanentlyDenied) {
        Get.log('ConnectPermdisabled');
      }
    }
    devices = await flutter_webrtc.navigator.mediaDevices.enumerateDevices();
    selectedVideoInputId = getVideoDevice();
    Get.log('selectedVideoInputId: $selectedVideoInputId');
  }

  /// webrtc 链接状态回调（代码保持不变）
  dynamic onConnectionState(RTCPeerConnectionState state, int index) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        Get.log('$index 链接 成功');
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        Get.log('$index 链接 失败');
        break;
      default:
        Get.log('$index 链接 还未建立成功');
    }
  }

  /// webrtc ice 建立状态（代码保持不变）
  dynamic onIceConnectionState(RTCIceConnectionState state, int index) {
    switch (state) {
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        Get.log('$index ice对等 链接 失败');
        break;
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
        Get.log('$index ice对等 链接 成功 开始推流');
        break;
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        Get.log('$index ice对等 链接断开 可以尝试重新连接');
        break;
      default:
    }
  }

  /// 推流状态回调（代码保持不变）
  dynamic peerConnectionState(state) {
    Get.log('当前推流状态 $state');
  }

  /// 获取前置或后置摄像头（代码保持不变）
  String getVideoDevice({bool front = true}) {
    for (final device in devices) {
      if (device.kind == 'videoinput') {
        if (front && device.label.contains('front')) {
          return device.deviceId;
        } else if (!front && device.label.contains('back')) {
          return device.deviceId;
        }
      }
    }
    return "";
  }

  /// 切换麦克风状态（代码保持不变）
  Future<void> toggleAudio() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      for (var track in audioTracks) {
        track.enabled = !track.enabled;
      }
      if (mediaConstraints['audio'] is Map) {
        mediaConstraints['audio']['enabled'] = audioTracks.first.enabled;
      } else {
        mediaConstraints['audio'] = audioTracks.first.enabled;
      }
    }
  }
}

/// webrtc 拉流地址解析（代码保持不变）
class WebRTCUri {
  late String api;
  late String streamUrl;

  static WebRTCUri parse(String url, {type = 'play'}) {
    Uri uri = Uri.parse(url);

    String schema = 'https';
    if (uri.queryParameters.containsKey('schema')) {
      schema = uri.queryParameters['schema']!;
    } else {
      schema = 'https';
    }

    var port = (uri.port > 0) ? uri.port : 443;
    if (schema == 'https') {
      port = (uri.port > 0) ? uri.port : 443;
    } else if (schema == 'http') {
      port = (uri.port > 0) ? uri.port : 1985;
    }

    String api = '/rtc/v1/play/';
    if (type == 'publish') {
      api = '/rtc/v1/publish/';
    }
    if (uri.queryParameters.containsKey('play')) {
      api = uri.queryParameters['play']!;
    }

    var apiParams = [];
    for (var key in uri.queryParameters.keys) {
      if (key != 'api' && key != 'play' && key != 'schema') {
        apiParams.add('${key}=${uri.queryParameters[key]}');
      }
    }

    var apiUrl = '${schema}://${uri.host}:${port}${api}';
    if (apiParams.isNotEmpty) {
      apiUrl += '?' + apiParams.join('&');
    }

    WebRTCUri r = WebRTCUri();
    r.api = apiUrl;
    r.streamUrl = url;
    Get.log('Url ${url} parsed to api=${r.api}, stream=${r.streamUrl}');
    return r;
  }
}

/// 视频大小辅助类（代码保持不变）
class VideoSize {
  VideoSize(this.width, this.height);

  factory VideoSize.fromString(String size) {
    final parts = size.split('x');
    return VideoSize(int.parse(parts[0]), int.parse(parts[1]));
  }

  final int width;
  final int height;

  @override
  String toString() {
    return '$width x $height';
  }
}