import 'package:flutter/material.dart';
import 'package:flutter_im/config/app_config.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../routes/app_routes.dart';

/// 网页页面  Get.toNamed(Routes.WEB_VIEW, arguments: {"url": "https://flutter.dev"});  // 传递参数
class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller; // webview控制器

  String _title = "加载中..."; // 网页标题

  late String _url; // 跳转地址

  @override
  void initState() {
    super.initState();
    // 从参数获取url
    _url =
        Get.parameters["url"] ?? Get.arguments?["url"] ?? AppConfig.defaultUrl;

    // 初始化webview
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: _updateTitle, // 页面加载完成更新title
          onNavigationRequest: _handleNavigationRequest, // 网页跳转前置处理
        ),
      )
      ..loadRequest(Uri.parse(_url)); // 加载网页
  }

  /// 更新网页标题
  Future<void> _updateTitle(String url) async {
    try {
      final titleResult =
          await _controller.runJavaScriptReturningResult("document.title");
      String title = titleResult.toString().replaceAll('"', '').trim();
      if (title.isNotEmpty && mounted) {
        setState(() => _title = title);
      }
    } catch (e) {
      Get.log("❌ 获取网页标题失败: $e");
    }
  }

  /// 网页跳转前置处理
  Future<NavigationDecision> _handleNavigationRequest(
      NavigationRequest request) async {
    final uri = Uri.parse(request.url);
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return NavigationDecision.navigate;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return NavigationDecision.prevent;
    }
    Get.log("⚠️ 无法处理的 URL: ${request.url}");
    return NavigationDecision.prevent;
  }

  /// 处理返回逻辑
  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      // 跳转回初始页面
      if (Get.previousRoute.isNotEmpty) {
        Get.back(); // 先返回一级
        if (Get.previousRoute.isNotEmpty) {
          Get.back(); // 再返回一级
        }
      } else {
        Get.offAllNamed(Routes.HOME); // 直接回到首页
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title, overflow: TextOverflow.ellipsis),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _handleBack,
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
