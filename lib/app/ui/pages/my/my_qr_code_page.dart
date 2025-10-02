import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../constants/app_constant.dart';
import '../../../controller/user_controller.dart';

class MyQRCodePage extends StatelessWidget {
  const MyQRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    const qrSize = 240.0;
    const containerPadding = 10.0;
    const containerWidth = qrSize + (containerPadding * 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的二维码'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetX<UserController>(
        builder: (controller) {
          final userInfo = controller.userInfo;
          String username = userInfo['name'] ?? '未登录';
          String avatarUrl = userInfo['avatar'] ?? '';
          String userId = userInfo['userId']?.toString() ?? '';

          // 构建简化的二维码数据
          String qrData = '${AppConstants.FRIEND_PROFILE_PREFIX}$userId';

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // 用户信息区域
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 矩形头像
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: avatarUrl.isNotEmpty
                            ? Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 用户名
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // 二维码
                Center(
                  child: Container(
                    width: containerWidth,
                    padding: const EdgeInsets.all(containerPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: QrImageView(
                      data: Uri.encodeComponent(qrData),
                      version: QrVersions.auto,
                      size: qrSize,
                      backgroundColor: Colors.white,
                      embeddedImage: NetworkImage(avatarUrl),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(36, 36),
                      ),
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 提示文字居中
                const Center(
                  child: Text(
                    '扫一扫上面的二维码，加我为好友',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
