import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 应用日志工具类
class AppLogger extends GetxService {
  static const String _defaultTag = "AppLogger";

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      stackTraceBeginIndex: 0,
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// 是否启用日志（默认 debug 模式启用，release 关闭）
  static bool enable = kDebugMode;

  /// 打印 `verbose` 级别日志
  static void verbose(Object? msg, {String tag = _defaultTag}) {
    if (enable) _logger.v("[$tag] $msg");
  }

  /// 打印 `debug` 级别日志
  static void debug(Object? msg, {String tag = _defaultTag}) {
    if (enable) _logger.d("[$tag] $msg");
  }

  /// 打印 `info` 级别日志
  static void info(Object? msg, {String tag = _defaultTag}) {
    if (enable) _logger.i("[$tag] $msg");
  }

  /// 打印 `warning` 级别日志
  static void warning(Object? msg, {String tag = _defaultTag}) {
    if (enable) _logger.w("[$tag] $msg");
  }

  /// 打印 `error` 级别日志
  static void error(Object? msg, {String tag = _defaultTag}) {
    if (enable) _logger.e("[$tag] $msg");
  }

  /// 打印 `WTF` 级别日志
  static void wtf(Object? msg, {String tag = _defaultTag}) {
    if (enable) _logger.wtf("[$tag] $msg");
  }
}
