import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';

/// WebSocket状态
enum SocketStatus {
  socketStatusConnected, // 已连接
  socketStatusFailed, // 失败
  socketStatusClosed, // 连接关闭
}

class WebSocketUtility {
  /// 单例对象
  static final WebSocketUtility _socket = WebSocketUtility._internal();

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  WebSocketUtility._internal();

  /// 获取单例内部方法
  factory WebSocketUtility() {
    return _socket;
  }

  late WebSocketChannel _webSocket; // WebSocket
  SocketStatus? _socketStatus; // socket状态
  Timer? _heartBeat; // 心跳定时器
  final int _heartTimes = 30000; // 心跳间隔(毫秒)
  final int _reconnectCount = 2; // 重连次数，默认60次
  int _reconnectTimes = 0; // 重连计数器
  Timer? _reconnectTimer; // 重连定时器
  late Function onError; // 连接错误回调
  late Function onOpen; // 连接开启回调
  late Function onMessage; // 接收消息回调

  /// 初始化WebSocket
  void initWebSocket(
      {required Function onOpen,
      required Function onMessage,
      required Function onError}) {
    this.onOpen = onOpen;
    this.onMessage = onMessage;
    this.onError = onError;
    openSocket();
  }

  /// 开启WebSocket连接
  void openSocket() {
    // closeSocket();
    _webSocket = WebSocketChannel.connect(Uri.parse(AppConfig.wsServer));
    print('WebSocket连接成功: $AppConfig.wsServer');
    // 连接成功，返回WebSocket实例
    _socketStatus = SocketStatus.socketStatusConnected;
    // 连接成功，重置重连计数器
    _reconnectTimes = 0;
    if (_reconnectTimer != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
    onOpen();
    // 接收消息
    _webSocket.stream.listen((data) => webSocketOnMessage(data),
        onError: webSocketOnError, onDone: webSocketOnDone);
  }

  /// WebSocket接收消息回调
  webSocketOnMessage(data) {
    onMessage(data);
  }

  /// WebSocket关闭连接回调
  webSocketOnDone() {
    print('webSocketOnDone closed');
    _socketStatus = SocketStatus.socketStatusClosed;
    reconnect();
  }

  /// WebSocket连接错误回调
  webSocketOnError(e) {
    WebSocketChannelException ex = e;
    _socketStatus = SocketStatus.socketStatusFailed;
    onError(ex.message);
    closeSocket();
  }

  /// 初始化心跳
  void initHeartBeat() {
    destroyHeartBeat();
    _heartBeat = Timer.periodic(Duration(milliseconds: _heartTimes), (timer) {
      sentHeart();
    });
  }

  /// 心跳
  void sentHeart() {
    sendMessage('{"module": "HEART_CHECK", "message": "请求心跳"}');
  }

  /// 销毁心跳
  void destroyHeartBeat() {
    if (_heartBeat != null) {
      _heartBeat?.cancel();
      _heartBeat = null;
    }
  }

  /// 关闭WebSocket
  void closeSocket() {
    print('WebSocket连接关闭');
    _webSocket.sink.close();
    destroyHeartBeat();
    _socketStatus = SocketStatus.socketStatusClosed;
  }

  /// 发送WebSocket消息
  void sendMessage(message) {
    switch (_socketStatus) {
      case SocketStatus.socketStatusConnected:
        print('发送中：$message');
        _webSocket.sink.add(message);
        break;
      case SocketStatus.socketStatusClosed:
        print('连接已关闭');
        break;
      case SocketStatus.socketStatusFailed:
        print('发送失败');
        break;
      default:
        break;
    }
  }

  /// 重连机制
  void reconnect() {
    if (_reconnectTimes < _reconnectCount) {
      _reconnectTimes++;
      _reconnectTimer =
          Timer.periodic(Duration(milliseconds: _heartTimes), (timer) {
        openSocket();
      });
    } else {
      if (_reconnectTimer != null) {
        print('重连次数超过最大次数');
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
      }
      return;
    }
  }

  get socketStatus => _socketStatus;

  get webSocketCloseCode => _webSocket.closeCode;
}
