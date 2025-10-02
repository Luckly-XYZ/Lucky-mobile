import 'package:get/get.dart';

class ApiService extends GetxService {
  Future<ApiService> init() async {
    // 初始化 API 服务
    return this;
  }

  Future<dynamic> get(String path) async {
    // 实现 GET 请求
  }

  Future<dynamic> post(String path, dynamic data) async {
    // 实现 POST 请求
  }
}
