import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../config/app_config.dart';
import '../../../routes/app_routes.dart';

/// 网页浏览页面，支持加载外部 URL 并提供交互功能
/// 特性：
/// - 通过 `Get.arguments` 或 `Get.parameters` 接收 URL（如 `Get.toNamed(Routes.WEB_VIEW, arguments: {"url": "https://flutter.dev"})`）。
/// - 显示网页标题、加载进度条和错误页面。
/// - 支持返回、刷新和外部协议（如 tel://、mailto://）。
/// - 提供 JavaScript 通道，允许网页与 Flutter 交互。
class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  // 常量定义
  static var _defaultUrl = AppConfig.defaultUrl; // 默认 URL
  static const _progressHeight = 3.0; // 进度条高度
  static const _errorTextStyle =
      TextStyle(fontSize: 16, color: Colors.grey); // 错误提示样式
  static const _appBarTitleStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500); // 标题样式
  static const _iconSize = 24.0; // 图标尺寸

  late final WebViewController _controller; // WebView 控制器
  String _title = '加载中...'; // 网页标题
  double _progress = 0.0; // 加载进度
  bool _hasError = false; // 是否发生加载错误

  @override
  void initState() {
    super.initState();
    // 初始化 WebView 控制器
    _initWebViewController();
  }

  /// 初始化 WebView 控制器
  void _initWebViewController() {
    // 获取 URL，优先从 arguments 获取
    final url =
        (Get.arguments is Map ? Get.arguments['url'] as String? : null) ??
            Get.parameters['url'] ??
            _defaultUrl;

    // 验证 URL 合法性
    if (!GetUtils.isURL(url)) {
      setState(() => _hasError = true);
      Get.log('❌ 无效 URL: $url');
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _progress = 0.0),
          onProgress: (progress) => setState(() => _progress = progress / 100),
          onPageFinished: (url) {
            setState(() => _progress = 1.0);
            _updateTitle(url);
          },
          onWebResourceError: (error) {
            setState(() => _hasError = true);
            Get.log('❌ 网页加载失败: ${error.description}');
          },
          onNavigationRequest: _handleNavigationRequest,
        ),
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (message) {
          Get.snackbar('网页消息', message.message);
          Get.log('📩 JavaScript 消息: ${message.message}');
        },
      )
      ..loadRequest(Uri.parse(url));
  }

  /// 更新网页标题
  Future<void> _updateTitle(String url) async {
    try {
      final titleResult =
          await _controller.runJavaScriptReturningResult('document.title');
      final title = titleResult.toString().replaceAll('"', '').trim();
      if (title.isNotEmpty && mounted) {
        setState(() => _title = title);
      }
    } catch (e) {
      Get.log('❌ 获取网页标题失败: $e');
    }
  }

  /// 处理网页导航请求
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
    Get.snackbar('提示', '无法处理 URL: ${request.url}');
    Get.log('⚠️ 无法处理的 URL: ${request.url}');
    return NavigationDecision.prevent;
  }

  /// 处理返回逻辑
  Future<void> _handleBack() async {
    if (_hasError) {
      Get.back();
      return;
    }
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  /// 刷新网页
  void _reload() {
    setState(() {
      _hasError = false;
      _progress = 0.0;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            /// 错误页面
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('网页加载失败，请检查网络或 URL', style: _errorTextStyle),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('重新加载'),
                    ),
                  ],
                ),
              )

            /// WebView
            else
              WebViewWidget(controller: _controller),

            /// 加载进度条
            if (_progress < 1.0 && !_hasError)
              LinearProgressIndicator(
                  value: _progress, minHeight: _progressHeight),
          ],
        ),
      ),
    );
  }

  /// 构建 AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _title,
        style: _appBarTitleStyle,
        overflow: TextOverflow.ellipsis,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: _iconSize),
        onPressed: _handleBack,
      ),
      actions: [
        /// 刷新按钮
        IconButton(
          icon: const Icon(Icons.refresh, size: _iconSize),
          onPressed: _reload,
        ),
      ],
    );
  }
}
