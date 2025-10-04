import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'http_service.dart';

/// **🌐 统一 API 服务**
class ApiService extends HttpService {
  // 单例模式
  // ====================================
  // 🔐 认证相关 API
  // ====================================

  /// 登录
  Future<Map<String, dynamic>?> login(Map<String, dynamic> data) {
    return post('/auth/api/v1/auth/login', data: data);
  }

  /// 退出登录
  Future<Map<String, dynamic>?> logout(Map<String, dynamic> data) {
    return post('/auth/api/v1/auth/logout', data: data);
  }

  /// 刷新 Token
  Future<Map<String, dynamic>?> refreshToken() {
    return get('/auth/api/v1/auth/refresh/token');
  }

  /// 发送短信
  Future<Map<String, dynamic>?> sendSms(Map<String, dynamic> data) {
    return get('/auth/api/v1/auth/sms', params: data);
  }

  /// 获取二维码
  Future<Map<String, dynamic>?> getQRCode(Map<String, dynamic> data) {
    return get('/auth/api/v1/auth/qrcode', params: data);
  }

  /// 扫码登录
  Future<Map<String, dynamic>?> scanQRCode(Map<String, dynamic> data) {
    return post('/auth/api/v1/auth/qrcode/scan', data: data);
  }

  /// 检查二维码状态
  Future<Map<String, dynamic>?> checkQRCodeStatus(Map<String, dynamic> data) {
    return get('/auth/api/v1/auth/qrcode/status', params: data);
  }

  /// 获取公钥
  Future<Map<String, dynamic>?> getPublicKey() {
    return get('/auth/api/v1/auth/publickey');
  }

  /// 获取在线状态
  Future<Map<String, dynamic>?> getOnlineStatus(Map<String, dynamic> data) {
    return get('/auth/api/v1/auth/online', params: data);
  }

  /// 获取个人信息
  Future<Map<String, dynamic>?> getUserInfo(Map<String, dynamic> data) {
    return get('/auth/api/v1/auth/info', params: data);
  }

  // ====================================
  // 👤 用户 / 好友相关 API
  // ====================================

  /// **获取好友列表**
  Future<Map<String, dynamic>?> getFriendList(Map<String, dynamic> data) {
    return get('/service/api/v1/relationship/contacts/list', params: data);
  }

  /// **获取群列表**
  Future<Map<String, dynamic>?> getGroupList(Map<String, dynamic> data) {
    return get('/service/api/v1/relationship/groups/list', params: data);
  }

  /// **获取好友添加请求列表**
  Future<Map<String, dynamic>?> getRequestFriendList(
      Map<String, dynamic> params) {
    return get('/service/api/v1/relationship/newFriends/list', params: params);
  }

  /// **获取好友信息**
  Future<Map<String, dynamic>?> getFriendInfo(Map<String, dynamic> data) {
    return post('/service/api/v1/relationship/getFriendInfo', data: data);
  }

  /// **搜索好友信息**
  Future<Map<String, dynamic>?> searchFriendInfoList(
      Map<String, dynamic> data) {
    return post('/service/api/v1/relationship/search/getFriendInfoList',
        data: data);
  }

  /// **请求添加好友**
  Future<Map<String, dynamic>?> requestContact(Map<String, dynamic> data) {
    return post('/service/api/v1/relationship/requestContact', data: data);
  }

  /// **同意或拒绝好友请求**
  Future<Map<String, dynamic>?> approveContact(Map<String, dynamic> data) {
    return post('/service/api/v1/relationship/approveContact', data: data);
  }

  /// **删除好友**
  Future<Map<String, dynamic>?> deleteContact(Map<String, dynamic> data) {
    return post('/service/api/v1/relationship/deleteFriendById', data: data);
  }

  // ====================================
  // 💬 会话相关 API
  // ====================================

  /// 获取会话列表
  Future<Map<String, dynamic>?> getChatList(Map<String, dynamic> data) {
    return post('/service/api/v1/chat/list', data: data);
  }

  /// 获取单个会话
  Future<Map<String, dynamic>?> getChat(Map<String, dynamic> data) {
    return get('/service/api/v1/chat/one', params: data);
  }

  /// 标记会话已读
  Future<Map<String, dynamic>?> readChat(Map<String, dynamic> data) {
    return post('/service/api/v1/chat/read', data: data);
  }

  /// 创建会话
  Future<Map<String, dynamic>?> createChat(Map<String, dynamic> data) {
    return post('/service/api/v1/chat/create', data: data);
  }

  // ====================================
  // 📩 消息相关 API
  // ====================================

  /// 发送单聊消息
  Future<Map<String, dynamic>?> sendSingleMessage(Map<String, dynamic> data) {
    return post('/service/api/v1/message/single', data: data);
  }

  /// 发送群聊消息
  Future<Map<String, dynamic>?> sendGroupMessage(Map<String, dynamic> data) {
    return post('/service/api/v1/message/group', data: data);
  }

  /// 撤回消息
  Future<Map<String, dynamic>?> recallMessage(Map<String, dynamic> data) {
    return post('/service/api/v1/message/recall', data: data);
  }

  /// 获取群成员
  Future<Map<String, dynamic>?> getGroupMember(Map<String, dynamic> data) {
    return post('/service/api/v1/group/member', data: data);
  }

  /// 同意或拒绝群聊邀请
  Future<Map<String, dynamic>?> approveGroup(Map<String, dynamic> data) {
    return post('/service/api/v1/group/approve', data: data);
  }

  /// 退出群聊
  Future<Map<String, dynamic>?> quitGroup(Map<String, dynamic> data) {
    return post('/service/api/v1/group/quit', data: data);
  }

  /// 邀请群成员
  Future<Map<String, dynamic>?> inviteGroupMember(Map<String, dynamic> data) {
    return post('/service/api/v1/group/invite', data: data);
  }

  /// 获取消息列表
  Future<Map<String, dynamic>?> getMessageList(Map<String, dynamic> data) {
    return post('/service/api/v1/message/list', data: data);
  }

  /// 检查单聊消息
  Future<Map<String, dynamic>?> checkSingleMessage(Map<String, dynamic> data) {
    return post('/service/api/v1/message/singleCheck', data: data);
  }

  /// 发送视频消息
  Future<Map<String, dynamic>?> sendCallMessage(Map<String, dynamic> data) {
    return post('/service/api/v1/message/media/video', data: data);
  }

  // ====================================
  // 📂 文件相关 API
  // ====================================

  /// 文件上传
  Future<Map<String, dynamic>?> uploadFile(FormData data) {
    return post('/service/api/v1/file/formUpload', data: data);
  }

  // ====================================
  // ⚠️ 异常上报
  // ====================================

  Future<Map<String, dynamic>?> exceptionReport(Map<String, dynamic> data) {
    return get('/service/api/v1/tauri/exception/report', params: data);
  }

// ====================================
// 📂 webrtc 相关 API
// ====================================

  /// webrtc 获取 远程 answer
  Future webRtcHandshake(String url, String webrtcUrl, String sdp,
      {type = 'play'}) async {
    Dio dio = Dio();
    // 拼接url
    url = type == 'publish' ? '$url/rtc/v1/publish/' : '$url/rtc/v1/play/';

    Map data = {
      'api': url,
      'streamurl': webrtcUrl,
      'sdp': sdp,
      'tid': "2b45a06"
    };

    try {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Connection'] = 'close';
      dio.options.responseType = ResponseType.plain;

      Response response =
          await dio.post(url, data: utf8.encode(json.encode(data)));

      if (response.statusCode == 200) {
        Map<String, dynamic> o = json.decode(response.data);
        if (!o.containsKey('code') || !o.containsKey('sdp') || o['code'] != 0) {
          if (o['code'] == 400) {
            // ToastUtils.showToast("错误 当前已有人在推流");
          }
          return Future.error(response.data);
        }
        return Future.value(RTCSessionDescription(o['sdp'], 'answer'));
      } else {
        // ToastUtils.showToast("直播服务认证失败", type: 'error');
        return Future.error('请求推流服务器信令验证失败 status: ${response.statusCode}');
      }
    } catch (err) {
      // ToastUtils.showToast("直播服务认证失败$err", type: 'error');
      print('获取 webrtc sdp 报错$err');
      throw Error();
    }
  }
}
