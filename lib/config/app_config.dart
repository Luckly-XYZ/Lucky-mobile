class AppConfig {
  static const String baseUrl = '192.168.31.166';

  // API 相关配置192.168.8.43
  static const String baseApi = '/api';
  static const String apiServer = 'http://$baseUrl:9191';
  static const String wsServer = 'ws://$baseUrl:9191/im';
  static const String meetWsServer = 'ws://$baseUrl:9191/meet';
  static const String webRtcServer = 'webRTC://$baseUrl/live/';
  static const String srsServer = 'http://$baseUrl:1980';

  // 应用信息
  static const String appName = 'IM';
  static const String appVersion = '1.0.0';
  static const String appDescription = '即时通讯';
  static const String appIcon = 'assets/logo.png';
  static const String appCopyright = '© 2023 im. All rights reserved.';
  static const String deviceType = 'mobile'; // 修改为移动端
  static const String protocolType = 'proto';
  static const String defaultUrl = 'https://www.bing.com'; // 默认url

  // 存储相关
  static const String storeName = 'im_store';
  static const String databaseName = 'im_db.db';
  static const String databaseIndexName = 'im_index.db';

  // 其他配置
  static const int listRefreshTime = 10000; // 列表刷新时间（毫秒）
  static const String audioPath = 'assets/audio/'; // 音频文件路径

  // 表情文件路径
  static const String emojiPath = 'assets/data/emoji_pack.json';
  static const String pickerPath = 'picker';

  static bool debug = true; // 表情包文件路径

// 数据库路径
// static String getDatabasePath() {
//   // TODO: 根据平台返回适当的数据库路径
//   return 'databases/$databaseName';
// }

// // 获取完整的 WebSocket URL
// static String getWebSocketUrl() {
//   return wsServer;
// }

// // 获取完整的 API URL
// static String getApiUrl(String path) {
//   return '$apiServer$baseApi$path';
// }

// // 获取音频文件完整路径
// static String getAudioPath(String fileName) {
//   return '$audioPath$fileName';
// }
}
