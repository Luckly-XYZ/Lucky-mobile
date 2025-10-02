import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UnknownView extends GetView {
  const UnknownView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '抱歉，页面未找到',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
