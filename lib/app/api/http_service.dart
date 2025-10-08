import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../controller/user_controller.dart';

/// HTTP 请求服务类，基于 Dio 封装，提供统一的网络请求功能
class HttpService extends GetxService {
  late final dio.Dio _dio;

  /// 初始化 Dio 配置和拦截器
  @override
  void onInit() {
    super.onInit();
    _initDio();
    _setupInterceptors();
  }

  /// 配置 Dio 实例，包括基础 URL 和超时设置
  void _initDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: AppConfig.apiServer,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));

    // 仅在调试模式下启用忽略 SSL 证书验证（用于抓包调试）
    if (AppConfig.debug) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  /// 设置 Dio 拦截器，统一处理请求头、响应日志和错误处理
  void _setupInterceptors() {
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证 Token（如果存在）
        final token = UserController.to.token.value;
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // 设置默认 Content-Type
        options.headers['Content-Type'] = 'application/json';
        Get.log('📡 请求: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Get.log(
            '✅ 响应成功: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (dio.DioException e, handler) {
        Get.log('❌ 请求错误: ${e.message} [${e.requestOptions.uri}]');
        _handleDioError(e);
        return handler.next(e);
      },
    ));
  }

  /// 发送 GET 请求
  ///
  /// [path] 请求路径
  /// [params] 查询参数（可选）
  /// 返回: 解析后的 JSON 数据（Map<String, dynamic>）或 null（失败时）
  Future<Map<String, dynamic>?> get(String path,
      {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return _processResponse(response);
    } on dio.DioException catch (e) {
      Get.log('❌ GET 请求失败: $path - ${e.message}');
      _handleDioError(e);
      return null;
    } catch (e) {
      Get.log('❌ GET 请求异常: $path - $e');
      return null;
    }
  }

  /// 发送 POST 请求
  ///
  /// [path] 请求路径
  /// [data] 请求体数据（可选）
  /// 返回: 解析后的 JSON 数据（Map<String, dynamic>）或 null（失败时）
  Future<Map<String, dynamic>?> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _processResponse(response);
    } on dio.DioException catch (e) {
      Get.log('❌ POST 请求失败: $path - ${e.message}');
      _handleDioError(e);
      return null;
    } catch (e) {
      Get.log('❌ POST 请求异常: $path - $e');
      return null;
    }
  }

  /// 处理 HTTP 响应数据
  ///
  /// [response] Dio 响应对象
  /// 返回: 解析后的 Map 数据；失败时抛出 DioException
  static Map<String, dynamic>? _processResponse(dio.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      return data is String ? jsonDecode(data) : data as Map<String, dynamic>?;
    }
    // 非成功状态码，抛出异常以触发拦截器错误处理
    throw dio.DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: dio.DioExceptionType.badResponse,
    );
  }

  /// 处理 Dio 异常，提供分类日志输出
  ///
  /// [error] DioException 对象
  void _handleDioError(dio.DioException error) {
    final message = switch (error.type) {
      dio.DioExceptionType.connectionTimeout => '⏳ 连接超时',
      dio.DioExceptionType.sendTimeout => '🚀 发送数据超时',
      dio.DioExceptionType.receiveTimeout => '⚠️ 接收数据超时',
      dio.DioExceptionType.badResponse =>
        '❌ 服务器错误: ${error.response?.statusCode}',
      dio.DioExceptionType.cancel => '❎ 请求被取消',
      dio.DioExceptionType.unknown => '🤷 未知网络错误: ${error.message}',
      _ => '🛑 其他错误: ${error.message}',
    };
    Get.log(message);
  }
}
