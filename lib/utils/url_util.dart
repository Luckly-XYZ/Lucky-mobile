class UrlUtil {
  static final RegExp _urlRegExp = RegExp(
    r'^(http|https):\/\/([\w-]+\.)+[\w-]+(\/[\w-./?%&=]*)?$',
    caseSensitive: false,
  );

  /// 验证URL是否有效
  ///
  /// [url] 要验证的URL字符串
  /// 返回 true 表示是有效的URL，false 表示无效
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      // 首先使用正则表达式进行基本验证
      if (!_urlRegExp.hasMatch(url)) {
        return false;
      }

      // 然后使用Uri解析进行更严格的验证
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
