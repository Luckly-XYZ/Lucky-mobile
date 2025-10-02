import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../controller/user_controller.dart';

/// HTTP 请求服务
class HttpService extends GetxService {
  late dio.Dio _dio;

  /// 初始化 Dio
  @override
  void onInit() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: AppConfig.apiServer, // API 地址
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));

    // 设置代理，用于抓包调试
    if (AppConfig.debug) {
      // 建议只在调试模式下
      // 忽略 SSL 证书验证
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // 设置拦截器
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        String token = UserController.to.token.value;
        if (token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        options.headers["Content-Type"] = "application/json";
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Get.log("✅ 响应成功: ${response.data}");
        return handler.next(response);
      },
      onError: (dio.DioException e, handler) {
        Get.log("❌ 请求错误: ${e.message}");
        return handler.next(e);
      },
    ));

    super.onInit();
  }

  /// 发送 `GET` 请求
  Future<Map<String, dynamic>?> get(String path,
      {Map<String, dynamic>? params}) async {
    try {
      dio.Response response = await _dio.get(path, queryParameters: params);
      return _handleResponse(response);
    } catch (e) {
      Get.log("❌ GET 请求失败: $e");
      return null;
    }
  }

  /// 发送 `POST` 请求
  Future<Map<String, dynamic>?> post(String path, {dynamic data}) async {
    try {
      dio.Response response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } catch (e) {
      Get.log("❌ POST 请求失败: $e");
      return null;
    }
  }

  /// 处理 HTTP 响应
  ///
  /// - [response] Dio 的 Response 对象
  /// - 返回解析后的 JSON 数据（Map<String, dynamic>）
  static Map<String, dynamic>? _handleResponse(dio.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data is String
          ? jsonDecode(response.data)
          : response.data;
    } else {
      throw dio.DioException(
          requestOptions: response.requestOptions, response: response);
    }
  }

  /// 处理 Dio 异常
  ///
  /// - [error] 可能的异常类型：
  ///   - DioException：网络请求错误
  ///   - 其他异常：未知错误
  // ignore: unused_element
  static void _handleError(dynamic error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
          Get.log("⏳ 连接超时");
          break;
        case dio.DioExceptionType.receiveTimeout:
          Get.log("⚠️  接收数据超时");
          break;
        case dio.DioExceptionType.sendTimeout:
          Get.log("🚀  发送数据超时");
          break;
        case dio.DioExceptionType.badResponse:
          Get.log("❌  服务器错误: ${error.response?.statusCode}");
          break;
        case dio.DioExceptionType.cancel:
          Get.log("❎  请求被取消");
          break;
        case dio.DioExceptionType.unknown:
          Get.log("🤷  未知错误: ${error.message}");
          break;
        default:
          Get.log("🛑  其他错误: ${error.message}");
      }
    } else {
      Get.log("❌  未知异常: $error");
    }
  }
}
