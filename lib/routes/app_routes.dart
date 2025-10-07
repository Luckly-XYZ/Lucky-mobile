/// 应用路由常量定义类
abstract class Routes {
  /// 未知路由
  static const UNKNOWN = '/unknown';

  /// 首页
  static const HOME = '/home';

  /// 登录
  static const LOGIN = '/login';

  /// 会话
  static const CHAT = '/chat';

  /// 通讯录
  static const CONTACTS = '/contacts';

  /// 添加好友
  static const ADD_FRIEND = '/add_friend';

  /// 好友请求
  static const FRIEND_REQUESTS = '/friend_requests';

  /// 消息
  static const MESSAGE = '/message';

  /// 聊天信息
  static const CHAT_INFO = '/chat_info';

  /// 通讯录
  static const CONTACT = '/contact';

  /// 搜索
  static const SEARCH = '/SEARCH';

  /// 设置
  static const SETTING = '/setting';

  /// webview
  static const WEB_VIEW = '/web_view';

  /// 我的二维码
  static const MY_QR_CODE = '/my_qr_code';

  /// 扫一扫
  static const SCAN = '/scan';

  /// 登录授权 只在扫一扫中使用
  static const LOGIN_AUTHORIZATION = '/login_authorization';

  /// 好友信息
  static var FRIEND_PROFILE = '/friend_profile';

  /// 用户资料
  static var USER_PROFILE = '/user_profile';

  /// 视频通话
  static var VIDEO_CALL = '/video_call';
}
