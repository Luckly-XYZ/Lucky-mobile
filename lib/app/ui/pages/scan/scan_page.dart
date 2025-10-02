import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于震动反馈
import 'package:flutter_im/app/routes/app_routes.dart';
import 'package:flutter_im/constants/app_constant.dart';
import 'package:flutter_im/utils/audio.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'login_authorization_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool isTorchOn = false; // 闪光灯状态
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // 设置强制竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // 添加应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    // 启动相机
    controller.start();

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    // 移除应用生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    // 停止相机并释放资源
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 监听应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // 应用从后台恢复时，启动相机
        if (!controller.isStarting) {
          controller.start();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // 应用进入后台或暂停时，停止相机
        if (controller.isStarting) {
          controller.stop();
        }
        break;
      default:
        break;
    }
  }

  /// **条码检测回调**
  ///
  /// - 通过 `BarcodeCapture` 获取检测到的所有二维码
  /// - 提取二维码的内容（`rawValue`）
  /// - 获取二维码的类型、格式等信息
  /// - 触发震动反馈 & 播放扫码提示音
  /// - 解析二维码内容，执行相应的跳转逻辑
  void onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    // **确保至少检测到一个二维码**
    if (barcodes.isNotEmpty) {
      final Barcode firstBarcode = barcodes.first;

      // **获取二维码的内容（数据）**
      final String? code = firstBarcode.rawValue;

      // **获取二维码的类型（格式）**
      final BarcodeFormat format =
          firstBarcode.format; // e.g., QR_CODE, CODE_128, EAN_13
      final String formatString = format.name; // 转换成字符串
      debugPrint('📌 扫码格式: $formatString');

      // **获取二维码的元信息（可能为空）**
      final BarcodeType type = firstBarcode.type; // 例如：URL、文本、WiFi、联系人等
      debugPrint('📌 二维码类型: ${type.name}');

      // **检查是否成功解析二维码内容**
      if (code != null) {
        debugPrint('✅ 扫码结果: $code');

        // **触发中等强度的震动反馈**
        HapticFeedback.mediumImpact();

        // **播放扫码音效**
        AudioPlayerUtil().play('audio/beep.mp3', useMediaVolume: false);

        // **如果是URL，则跳转到 WebView**
        if (GetUtils.isURL(code)) {
          debugPrint('🌐 解析为 URL，跳转到 WebView: $code');

          // 停止扫码
          controller.stop();

          // **跳转 WebView 并传递 URL 参数**
          Get.toNamed(Routes.WEB_VIEW, arguments: {"url": code})?.then((_) {
            // **WebView 返回时，重新启动扫码**
            if (mounted) {
              controller.start();
            }
          }).catchError((err) {
            debugPrint('❌ WebView 页面跳转失败: $err');
            Get.back();
          });

          return;
        }

        // **如果二维码内容以特定前缀开头，则跳转到授权页面**
        if (code.startsWith(AppConstants.LOGIN_QRCODE_PREFIX)) {
          debugPrint('🔐 解析为登录二维码，跳转到授权页面');

          // **防止重复跳转**
          if (ModalRoute.of(context)?.settings.name != '/authorization') {
            String trimmedCode =
                code.substring(AppConstants.LOGIN_QRCODE_PREFIX.length);
            if (trimmedCode.isNotEmpty) {
              // **停止扫码**
              controller.stop();

              // **跳转授权页面并传递数据**
              Get.to(() => AuthorizationPage(code: trimmedCode))?.then((_) {
                // **授权页面返回时，重新启动扫码**
                if (mounted) {
                  controller.start();
                }
              }).catchError((err) {
                debugPrint('❌ 授权页面跳转失败: $err');
                Get.back();
              });
            }
          }
        }

        // **如果二维码内容以特定前缀开头，则跳转到好友资料页面**
        if (code.startsWith(AppConstants.FRIEND_PROFILE_PREFIX)) {
          debugPrint('👤 解析为好友资料二维码，跳转到好友资料页面');

          String trimmedCode =
              code.substring(AppConstants.FRIEND_PROFILE_PREFIX.length);

          if (trimmedCode.isNotEmpty) {
            // **停止扫码**
            controller.stop();

            // **跳转好友资料页面并传递数据**
            Get.toNamed("${Routes.HOME}${Routes.FRIEND_PROFILE}",
                arguments: {'userId': trimmedCode})?.then((_) {
              // **好友资料页面返回时，重新启动扫码**
              if (mounted) {
                controller.start();
              }
            }).catchError((err) {
              debugPrint('❌ 好友资料页面跳转失败: $err');
              Get.back();
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // 显示扫描界面
          MobileScanner(
            controller: controller,
            onDetect: onBarcodeDetected,
          ),
          // 左上角的返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          // 居中绘制扫描区域的边框
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 移除原来的Container，改用SizedBox来控制大小
                const SizedBox(
                  width: 250,
                  height: 250,
                ),
                // 添加扫描线动画
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: _animationController.value * 250,
                      child: Container(
                        width: 230,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.green.withOpacity(0),
                              Colors.green.withOpacity(0.5),
                              Colors.green,
                              Colors.green.withOpacity(0.5),
                              Colors.green.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // 左上角
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.green, width: 4),
                        top: BorderSide(color: Colors.green, width: 4),
                      ),
                    ),
                  ),
                ),
                // 右上角
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.green, width: 4),
                        top: BorderSide(color: Colors.green, width: 4),
                      ),
                    ),
                  ),
                ),
                // 左下角
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.green, width: 4),
                        bottom: BorderSide(color: Colors.green, width: 4),
                      ),
                    ),
                  ),
                ),
                // 右下角
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.green, width: 4),
                        bottom: BorderSide(color: Colors.green, width: 4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 闪光灯图标位于扫描区域下方
          Positioned(
            top: screenHeight / 2 + 140,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                iconSize: 40,
                icon: Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color:
                      isTorchOn ? Colors.amber[400] : Colors.white, // 打开时显示金黄色
                ),
                onPressed: () {
                  setState(() {
                    isTorchOn = !isTorchOn;
                    controller.toggleTorch();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
