// lib/pages/login_authorization_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_sizes.dart';
import '../../../controller/home_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../routes/app_routes.dart';

class AuthorizationPage extends StatelessWidget {
  final String code;

  const AuthorizationPage({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('登录授权'),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GetBuilder<UserController>(builder: (userController) {
          final userInfo = userController.userInfo;
          String avatarUrl = userInfo['avatar'] ?? '';

          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: kSize35,
                      height: kSize35,
                      color: Colors.grey[300],
                      child: avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              size: kSize35,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: kSize32),
                Text(
                  '授权确认',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: kSize16),
                Text(
                  '是否确认授权登录该设备？',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: kSize40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSize32,
                          vertical: kSize12,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: kSize16,
                        ),
                      ),
                    ),
                    const SizedBox(width: kSize20),
                    ElevatedButton(
                      onPressed: () async {
                        bool res =
                            await Get.find<UserController>().scanQrCode(code);

                        if (res) {
                          Get.offAllNamed(Routes.HOME);
                          Get.find<HomeController>().changeTabIndex(0);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSize32,
                          vertical: kSize12,
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '确认登录',
                        style: TextStyle(
                          fontSize: kSize16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }));
  }
}
