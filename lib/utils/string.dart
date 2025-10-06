/// 字符串工具类
class StringUtil {
  /// 解析网络地址，提取URL的各个组成部分
  ///
  /// [url] 要解析的URL字符串
  /// 返回包含URL各部分信息的Map，如果URL无效则返回null
  static Map<String, dynamic>? parseUrl(String url) {
    if (url.isEmpty) return null;

    try {
      final uri = Uri.parse(url);

      // 检查是否是有效的网络协议
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return null;
      }

      return {
        'scheme': uri.scheme, // 协议 (http/https)
        'host': uri.host, // 主机名
        'port': uri.port, // 端口
        'path': uri.path, // 路径
        'query': uri.query, // 查询参数字符串
        'queryParameters': uri.queryParameters, // 查询参数Map
        'fragment': uri.fragment, // 锚点/片段标识符
        'userInfo': uri.userInfo, // 用户信息
        'authority': uri.authority, // 权限部分（主机+端口）
      };
    } catch (e) {
      // URL解析失败
      return null;
    }
  }

  /// 从URL中提取域名
  ///
  /// [url] 要提取域名的URL
  /// 返回域名部分，如果URL无效则返回null
  static String? extractDomain(String url) {
    final parsedUrl = parseUrl(url);
    return parsedUrl?['host'];
  }

  /// 检查URL是否有效
  ///
  /// [url] 要验证的URL字符串
  /// 返回 true 表示是有效的URL，false 表示无效
  static bool isValidUrl(String url) {
    return parseUrl(url) != null;
  }

  /// 构建带查询参数的URL
  ///
  /// [baseUrl] 基础URL
  /// [queryParams] 查询参数
  /// 返回构建好的完整URL
  static String buildUrl(String baseUrl, Map<String, dynamic> queryParams) {
    final uri = Uri.parse(baseUrl);
    final newUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
    return newUri.toString();
  }

  // 扩展方法示例（添加到 RegexUtils 类中）
  static bool containsURL(String input) {
    if (input.isEmpty) return false;

    final urlRegex = RegExp(
      r'https?:\/\/(a-z\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    return urlRegex.hasMatch(input);
  }

// 或者提取所有URL
  static List<String> extractURLs(String input) {
    if (input.isEmpty) return [];

    final urlRegex = RegExp(
      r'https?:\/\/(a-z\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(input);
    return matches.map((match) => match.group(0)!).toList();
  }
}
