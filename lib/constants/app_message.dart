// 定义消息类型枚举
enum MessageType {
  error(-1, '信息异常'),
  loginOver(900, '登录过期'),
  systemMessage(999, '系统消息'),
  login(1000, '登陆'),
  heartBeat(1001, '心跳'),
  forceLogout(1002, '强制下线'),
  singleMessage(1003, '私聊消息'),
  groupMessage(1004, '群发消息'),
  videoMessage(1005, '视频消息'),
  robot(1006, '机器人'),
  public(1007, '公众号');

  // 定义字段
  final int code;
  final String description;

  int getCode() {
    return code;
  }

  // 构造函数
  const MessageType(this.code, this.description);

  // 通过code获取MessageType的工厂方法
  static MessageType? fromCode(int code) {
    return MessageType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => MessageType.error,
    );
  }
}

// 定义消息内容类型枚举
enum MessageContentType {
  text(1, '文字'),
  image(2, '图片'),
  video(3, '视频'),
  audio(4, '语音'),
  file(5, '文件'),
  location(6, '位置'),
  tip(10, '系统提示'),
  rtcCall(101, '呼叫'),
  rtcAccept(102, '接受'),
  rtcReject(103, '拒绝'),
  rtcCancel(104, '取消呼叫'),
  rtcFailed(105, '呼叫失败'),
  rtcHangup(106, '挂断'),
  rtcCandidate(107, '同步candidate');

  // 定义字段
  final int code;
  final String type;

  // 构造函数
  const MessageContentType(this.code, this.type);

  // 通过code获取MessageContentType的工厂方法
  static MessageContentType? fromCode(int code) {
    return MessageContentType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => throw ArgumentError('未找到对应的消息内容类型: $code'),
    );
  }
}
