import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_sizes.dart';
import '../../../controller/user_controller.dart';
import '../../../routes/app_routes.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  void _loginOut() {
    Get.find<UserController>().logout();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            GetX<UserController>(
              builder: (controller) {
                final userInfo = controller.userInfo;
                String username = userInfo['name'] ?? '未登录';
                String signature = userInfo['selfSignature'] ?? '这个人很神秘...';
                String avatarUrl = userInfo['avatar'] ?? '';
                // 修复类型转换问题，确保 gender 是字符串类型
                String gender = userInfo['gender']?.toString() ?? '';

                Icon? genderIcon;
                if (gender == '1') {
                  genderIcon =
                      const Icon(Icons.male, color: Colors.blue, size: 18);
                } else if (gender == '0') {
                  genderIcon =
                      const Icon(Icons.female, color: Colors.pink, size: 18);
                }

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
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
                              : const Icon(Icons.person,
                                  size: 45, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(username,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 5),
                                if (genderIcon != null) genderIcon,
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(signature,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code, size: kSize22),
                        onPressed: () {
                          Get.toNamed("${Routes.HOME}${Routes.MY_QR_CODE}");
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner,
                        color: Colors.black87),
                    title: const Text('扫一扫'),
                    onTap: () {
                      Get.toNamed("${Routes.HOME}${Routes.SCAN}");
                    },
                  ),
                  //const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black87),
                    title: const Text('设置'),
                    onTap: () {
                      // TODO: 实现设置页面导航
                      //Get.toNamed(Routes.SETTINGS);
                    },
                  ),
                  //const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading:
                        const Icon(Icons.exit_to_app, color: Colors.black87),
                    title: const Text('退出登录'),
                    onTap: () {
                      _loginOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}