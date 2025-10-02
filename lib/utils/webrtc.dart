// import 'dart:convert';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:http/http.dart' as http;
//
// /// 推流参数定义，与 JS 代码中的结构对应
// class WebRTCPublishParam {
//   final String httpPublish;
//   final String httpPlay;
//   final String webrtc;
//   final Map<String, dynamic> audio;
//   final Map<String, dynamic> video;
//
//   WebRTCPublishParam({
//     required this.httpPublish,
//     required this.httpPlay,
//     required this.webrtc,
//     required this.audio,
//     required this.video,
//   });
//
//   /// 默认参数，可根据需要调整
//   static WebRTCPublishParam get defaultParam => WebRTCPublishParam(
//         httpPublish: "http://localhost:1985/rtc/v1/publish/",
//         httpPlay: "http://localhost:1985/rtc/v1/play/",
//         webrtc: "webRTC://localhost/live/",
//         audio: {
//           "echoCancellationType": "system",
//           "echoCancellation": true,
//           "noiseSuppression": true,
//           "autoGainControl": false,
//           "sampleRate": 24000,
//           "sampleSize": 16,
//           "channelCount": 2,
//           "volume": 0.5,
//         },
//         video: {
//           "frameRate": {"min": 30},
//           "width": {"min": 640, "ideal": 1080},
//           "height": {"min": 360, "ideal": 720},
//           "aspectRatio": 16 / 9,
//         },
//       );
// }
//
// /// 用于与信令服务器交互的响应数据
// class WebRTCAnswer {
//   final String sdp;
//   final String api;
//   final String streamurl;
//
//   WebRTCAnswer({
//     required this.sdp,
//     required this.api,
//     required this.streamurl,
//   });
//
//   factory WebRTCAnswer.fromJson(Map<String, dynamic> json) {
//     return WebRTCAnswer(
//       sdp: json['sdp'],
//       api: json['api'],
//       streamurl: json['streamurl'],
//     );
//   }
// }
//
// /// Flutter WebRTC 工具类，包含推流、拉流、关闭、摄像头/麦克风切换、分辨率及帧率设置等功能
// class FlutterWebRTC {
//   RTCPeerConnection? _peer; // 用于推流的 RTCPeerConnection
//   final Map<String, RTCPeerConnection> _remotePeers = {}; // 用于拉流的远程连接
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final Map<String, RTCVideoRenderer> _remoteRenderers =
//       {}; // 存放各路拉流的 RTCVideoRenderer
//   final WebRTCPublishParam _publishParam;
//   MediaStream? _localStream;
//   List<MediaStreamTrack>? _localAudioTracks;
//   List<MediaStreamTrack>? _localVideoTracks;
//
//   FlutterWebRTC({WebRTCPublishParam? publishParam})
//       : _publishParam = publishParam ?? WebRTCPublishParam.defaultParam;
//
//   /// 初始化本地视频渲染器，调用此方法后再开始推流
//   Future<void> initLocalRenderer() async {
//     await _localRenderer.initialize();
//   }
//
//   /// 获取本地渲染器供界面使用
//   RTCVideoRenderer get localRenderer => _localRenderer;
//
//   /// 内部方法：使用 HTTP POST 与信令服务器交互
//   Future<Map<String, dynamic>> _httpClient(
//       String url, Map<String, dynamic> data) async {
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(data),
//     );
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       var result = jsonDecode(response.body);
//       if (result["code"] == 0) {
//         return result;
//       } else {
//         throw Exception("服务器返回错误: ${result.toString()}");
//       }
//     } else {
//       throw Exception("HTTP 请求错误，状态码: ${response.statusCode}");
//     }
//   }
//
//   /// 推流方法
//   ///
//   /// [key] 用于标识流，信令服务器会基于此构造推流地址
//   Future<void> publish(String key) async {
//     // 如果已经存在推流连接则直接返回
//     if (_peer != null) {
//       print("推流已启动");
//       return;
//     }
//
//     // 构造媒体约束，这里直接使用 _publishParam 中的视频、音频配置
//     final Map<String, dynamic> mediaConstraints = {
//       'audio': _publishParam.audio,
//       'video': _publishParam.video,
//     };
//
//     try {
//       // 获取本地媒体流
//       _localStream =
//           await navigator.mediaDevices.getUserMedia(mediaConstraints);
//       _localAudioTracks = _localStream?.getAudioTracks();
//       _localVideoTracks = _localStream?.getVideoTracks();
//
//       // 将本地媒体流绑定到本地渲染器
//       _localRenderer.srcObject = _localStream;
//
//       // 创建 RTCPeerConnection（可在此处配置 ICE 服务器等参数）
//       _peer = await createPeerConnection({});
//
//       // 添加媒体流中的所有轨道到 RTCPeerConnection
//       _localStream?.getTracks().forEach((track) async {
//         await _peer!.addTrack(track, _localStream!);
//       });
//
//       // 对于音频轨道（仅接收方向），可以这样写：
//       await _peer!.addTransceiver(
//         kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
//         init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
//       );
//
//       // 对于视频轨道：
//       await _peer!.addTransceiver(
//         kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
//         init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
//       );
//
//       // 创建 offer
//       RTCSessionDescription offer = await _peer!.createOffer();
//       await _peer!.setLocalDescription(offer);
//
//       // 发送 offer 给信令服务器，并获取 answer
//       String httpURL = _publishParam.httpPublish;
//       String webrtcURL = "${_publishParam.webrtc}$key";
//       Map<String, dynamic> res = await _httpClient(httpURL, {
//         "api": httpURL,
//         "streamurl": webrtcURL,
//         "sdp": offer.sdp,
//       });
//       print("publish answer: $res");
//
//       // 设置远程描述
//       await _peer!
//           .setRemoteDescription(RTCSessionDescription(res["sdp"], "answer"));
//       print("推流成功");
//     } catch (e) {
//       print("publish 推流过程出现错误: $e");
//     }
//   }
//
//   /// 拉流方法
//   ///
//   /// [key] 为流标识，信令服务器基于此构造拉流地址；
//   /// [renderer] 为用于显示远程流的 RTCVideoRenderer，使用前请先调用 renderer.initialize()
//   Future<void> pull(String key, RTCVideoRenderer renderer) async {
//     if (_remotePeers.containsKey(key) && _remoteRenderers.containsKey(key)) {
//       print("流 $key 已存在拉流连接");
//       return;
//     }
//
//     try {
//       // 确保渲染器已初始化
//       await renderer.initialize();
//       _remoteRenderers[key] = renderer;
//
//       String httpURL = _publishParam.httpPlay;
//       String webrtcURL = "${_publishParam.webrtc}$key";
//
//       // 创建新的 RTCPeerConnection 用于拉流
//       RTCPeerConnection pc = await createPeerConnection({});
//       _remotePeers[key] = pc;
//
//       // 创建一个 MediaStream 用于接收远程媒体流
//       MediaStream remoteStream = await createLocalMediaStream("remote_$key");
//
//       // 当收到远程轨道时，将其添加到 MediaStream 并显示
//       pc.onTrack = (RTCTrackEvent event) {
//         if (event.track != null) {
//           remoteStream.addTrack(event.track!);
//           renderer.srcObject = remoteStream;
//         }
//       };
//
//       // 对于音频轨道（仅接收方向），可以这样写：
//       await pc.addTransceiver(
//         kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
//         init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
//       );
//
//       // 对于视频轨道：
//       await pc.addTransceiver(
//         kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
//         init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
//       );
//
//       // 创建 offer
//       RTCSessionDescription offer = await pc.createOffer();
//       await pc.setLocalDescription(offer);
//
//       // 发送 offer 给信令服务器并获取 answer
//       Map<String, dynamic> res = await _httpClient(httpURL, {
//         "api": httpURL,
//         "streamurl": webrtcURL,
//         "sdp": offer.sdp,
//       });
//       print("pull answer: $res");
//
//       // 设置远程描述
//       await pc
//           .setRemoteDescription(RTCSessionDescription(res["sdp"], "answer"));
//       print("拉流成功");
//     } catch (e) {
//       print("pull 拉流过程出现错误: $e");
//     }
//   }
//
//   /// 移除并关闭指定拉流
//   void removePull(String key) {
//     if (_remotePeers.containsKey(key)) {
//       RTCPeerConnection pc = _remotePeers[key]!;
//       // 停止所有发送的轨道
//       pc.getSenders()
//         ..asStream().forEach((sender) {
//           sender.first.track?.stop();
//         });
//
//       pc.close();
//       _remotePeers.remove(key);
//
//       print("流 $key 的拉流连接已关闭");
//     }
//     // 清除对应的渲染器（同时停止其中的媒体轨道）
//     if (_remoteRenderers.containsKey(key)) {
//       RTCVideoRenderer renderer = _remoteRenderers[key]!;
//       if (renderer.srcObject != null) {
//         (renderer.srcObject as MediaStream)
//             .getTracks()
//             .forEach((track) => track.stop());
//       }
//       renderer.srcObject = null;
//       _remoteRenderers.remove(key);
//     }
//   }
//
//   /// 开启/关闭摄像头
//   void toggleCamera(bool enable) {
//     if (_localVideoTracks != null) {
//       _localVideoTracks!.forEach((track) {
//         track.enabled = enable;
//       });
//       print("摄像头已 ${enable ? "开启" : "关闭"}");
//     }
//   }
//
//   /// 开启/关闭麦克风
//   void toggleMicrophone(bool enable) {
//     if (_localAudioTracks != null) {
//       _localAudioTracks!.forEach((track) {
//         track.enabled = enable;
//       });
//       print("麦克风已 ${enable ? "开启" : "关闭"}");
//     }
//   }
//
//   /// 控制远程视频的音量（注意：flutter_webrtc 的 RTCVideoRenderer 没有直接设置音量的方法，
//   /// 这部分可能需要借助平台音量控制或自定义播放器实现）
//   void toggleSpeaker(bool enable, String key) {
//     if (_remoteRenderers.containsKey(key)) {
//       // 此处仅作提示，实际项目中需结合具体播放方式调整音量
//       print("流 $key 的扬声器已 ${enable ? "开启" : "关闭"}");
//     }
//   }
//
//   /// 判断某个远程连接是否存在
//   bool remoteConnectExists(String key) {
//     return _remotePeers.containsKey(key);
//   }
//
//   /// 停止推流，关闭所有相关媒体流与连接
//   Future<void> close() async {
//     if (_peer != null) {
//       _peer!.getSenders().asStream().forEach((sender) {
//         sender.first.track?.stop();
//       });
//       await _peer!.close();
//       _peer = null;
//       print("推流已停止");
//     }
//     if (_localRenderer.srcObject != null) {
//       (_localRenderer.srcObject as MediaStream)
//           .getTracks()
//           .forEach((track) => track.stop());
//       _localRenderer.srcObject = null;
//     }
//     if (_localStream != null) {
//       _localStream!.getTracks().forEach((track) => track.stop());
//       _localStream = null;
//     }
//   }
//
//   /// 设置分辨率（修改视频轨道约束）
//   Future<bool> handleResolutionRatio({
//     required int width,
//     required int height,
//     required int frameRate,
//     required MediaStream stream,
//   }) async {
//     List<Future> constraintsFutures = [];
//     for (var track in stream.getVideoTracks()) {
//       constraintsFutures.add(track.applyConstraints({
//         'width': {'ideal': width},
//         'height': {'ideal': height},
//         'frameRate': {'ideal': frameRate},
//       }));
//     }
//     try {
//       await Future.wait(constraintsFutures);
//       print("分辨率设置成功");
//       return true;
//     } catch (e) {
//       print("设置分辨率失败: $e");
//       return false;
//     }
//   }
//
//   /// 设置帧率（修改视频轨道约束）
//   Future<bool> handleMaxFramerate({
//     required int frameRate,
//     required int width,
//     required int height,
//     required MediaStream stream,
//   }) async {
//     List<Future> constraintsFutures = [];
//     for (var track in stream.getVideoTracks()) {
//       constraintsFutures.add(track.applyConstraints({
//         'width': {'ideal': width},
//         'height': {'ideal': height},
//         'frameRate': {'ideal': frameRate},
//       }));
//     }
//     try {
//       await Future.wait(constraintsFutures);
//       print("帧率设置成功");
//       return true;
//     } catch (e) {
//       print("设置帧率失败: $e");
//       return false;
//     }
//   }
// }
