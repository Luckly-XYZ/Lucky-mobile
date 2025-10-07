import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../config/app_config.dart';
import '../../../controller/user_controller.dart';
import '../../../models/User.dart';
import '../../widgets/crop/crop_image.dart';

/// 用户资料页面
///
/// 展示并编辑用户的详细信息，包括圆角矩形头像、用户名、性别、生日、地区和个性签名。
/// 支持查看大图、更换头像和编辑模式切换（右上角编辑按钮）。
/// 使用 GetX 响应式状态管理，编辑模式下转为可编辑表单，保存后更新控制器。
class UserProfilePage extends GetView<UserController> {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化编辑控制器（一次性创建，避免重复）
    final usernameController = TextEditingController();
    final birthdayController = TextEditingController();
    final locationController = TextEditingController();
    final signatureController = TextEditingController();
    // 定义性别变量，避免直接修改 userInfo
    final gender = RxInt(-1); // -1 表示未设置，0 表示女，1 表示男
    final avatarUrl = RxString("");

    return WillPopScope(onWillPop: () async {
      if (controller.isEditing.value) {
        controller.isEditing.value = false; // 退出页面时强制结束编辑模式
        return false; // 拦截返回，防止直接退出
      }
      return true; // 正常退出
    }, child: Obx(() {
      final isEditing = controller.isEditing.value;

      final userInfo = new Map.from(controller.userInfo);

      // 同步数据到控制器（仅在非编辑模式或数据变更时）
      if (!isEditing) {
        usernameController.text = userInfo['name'] as String? ?? '未设置';
        birthdayController.text = userInfo['birthday'] as String? ?? '未设置';
        locationController.text = userInfo['location'] as String? ?? '未设置';
        signatureController.text =
            userInfo['selfSignature'] as String? ?? '未设置签名';
        // 同步性别数据
        gender.value = userInfo['gender'] as int? ?? -1;
        avatarUrl.value = userInfo['avatar'] as String? ?? '';
      }

      return Scaffold(
        appBar: _buildAppBar(isEditing),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // 头像区域（圆角矩形，支持点击查看大图）
              _buildAvatarSection(
                  userInfo['avatar'] as String? ?? '', context, isEditing),

              // 用户基本信息（编辑模式下转为 TextField）
              _buildUserInfoItem('用户名', usernameController, isEditing),

              // 性别（暂不支持编辑，使用下拉选择或类似，可扩展）
              _buildUserInfoItem(
                  '性别',
                  TextEditingController(
                      text: _getGenderText(userInfo['gender'] as int?)),
                  isEditing,
                  gender: gender),

              // 生日
              _buildUserInfoItem('生日', birthdayController, isEditing),

              // 地区
              _buildUserInfoItem('地区', locationController, isEditing),

              // 个性签名
              _buildSignatureSection(signatureController, isEditing),

              // 保存按钮（仅编辑模式显示）
              if (isEditing)
                _buildSaveButton(usernameController, birthdayController,
                    locationController, signatureController, gender, avatarUrl),
            ],
          ),
        ),
      );
    }));
  }

  /// 构建 AppBar，支持编辑/保存切换
  AppBar _buildAppBar(bool isEditing) {
    return AppBar(
      title: const Text('个人资料'),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {
            controller.isEditing.toggle();
            if (!controller.isEditing.value) {
              // 退出编辑模式时，可添加取消逻辑（如重载数据）
              //controller.loadUserInfo(); // 假设有刷新方法
            }
          },
          child: Text(isEditing ? '取消' : '编辑',
              style: const TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  /// 构建头像区域：圆角矩形，支持查看大图和更换头像
  Widget _buildAvatarSection(
      String avatarUrl, BuildContext context, bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: GestureDetector(
        onTap: () => _viewFullImage(context, avatarUrl), // 点击查看大图
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // 圆角矩形
                child: avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 80),
                      )
                    : const Icon(Icons.person, size: 80),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: isEditing ? () => _changeAvatar() : null, // 编辑模式下更换头像
                child: Text(
                  isEditing ? '更换头像' : '',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户信息项：支持编辑模式下转为 TextField
  Widget _buildUserInfoItem(
    String label,
    TextEditingController controller,
    bool isEditing, {
    bool readOnly = false,
    RxInt? gender, // 性别值，用于性别选择器
  }) {
    // 特殊处理性别选择（仅此处修改为 Radio 选择器，UI/样式保持原有 ListTile 布局）
    if (label == '性别' && isEditing) {
      final currentGender = gender; // 使用传递进来的性别值

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          trailing: Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 男
                  GestureDetector(
                    onTap: () {
                      // 更新性别变量而不直接修改 userInfo
                      currentGender?.value = 1;
                    },
                    child: Row(
                      children: [
                        Radio<int>(
                          value: 1,
                          groupValue: currentGender?.value,
                          onChanged: (value) {
                            if (value != null) {
                              // 更新性别变量而不直接修改 userInfo
                              currentGender?.value = value;
                            }
                          },
                        ),
                        const Text('男'),
                      ],
                    ),
                  ),
                  // 女
                  GestureDetector(
                    onTap: () {
                      // 更新性别变量而不直接修改 userInfo
                      currentGender?.value = 0;
                    },
                    child: Row(
                      children: [
                        Radio<int>(
                          value: 0,
                          groupValue: currentGender?.value,
                          onChanged: (value) {
                            if (value != null) {
                              // 更新性别变量而不直接修改 userInfo
                              currentGender?.value = value;
                            }
                          },
                        ),
                        const Text('女'),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      );
    }

    // 特殊处理生日选择（使用日期选择器）
    if (label == '生日' && isEditing) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: TextField(
              controller: controller,
              readOnly: true,
              // 设为只读，通过点击弹出日期选择器
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.right,
              onTap: () => _selectBirthDate(controller), // 点击弹出日期选择器
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(label,
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
        trailing: isEditing
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.text,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
      ),
    );
  }

  /// 构建个性签名区域：支持多行编辑
  Widget _buildSignatureSection(
      TextEditingController controller, bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('个性签名',
                style: TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 8),
            isEditing
                ? TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  )
                : Text(controller.text,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton(
      TextEditingController usernameController,
      TextEditingController birthdayController,
      TextEditingController locationController,
      TextEditingController signatureController,
      RxInt gender,
      RxString avatarUrl) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {

          if (avatarUrl.isNotEmpty &&
              controller.userInfo['avatar'] != avatarUrl.value) {
            avatarUrl.value = controller.userInfo['avatar'];
          }

          // 收集数据更新 userInfo
          final user = new User(
              userId: controller.userId.value,
              name: usernameController.text,
              avatar: avatarUrl.value,
              birthday: birthdayController.text,
              location: locationController.text,
              gender: gender.value == -1 ? 1 : gender.value,
              selfSignature: signatureController.text);
          if (user.name.isEmpty) {
            // Get.sh  showToast('请填写用户名');
            return;
          }
          await controller.updateUserInfo(user);
          controller.isEditing.value = false; // 退出编辑模式
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('保存'),
      ),
    );
  }

  /// 查看全屏大图
  void _viewFullImage(BuildContext context, String avatarUrl) {
    if (avatarUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: PhotoView(
              imageProvider: NetworkImage(avatarUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.0,
            ),
          ),
        ),
      ),
    );
  }

  /// 更换头像
  Future<void> _changeAvatar() async {
    showModalBottomSheet(
      context: Get.context!,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍摄照片'),
                onTap: () {
                  Navigator.pop(context);
                  getImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选取'),
                onTap: () {
                  Navigator.pop(context);
                  chooseImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ///拍摄照片
  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      cropImage(File(image.path));
    }
  }

  ///从相册选取
  Future chooseImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      cropImage(File(image.path));
    }
  }

  void cropImage(File originalImage) async {
    try {
      print('Selected image path: ${originalImage.path}');

      // 创建一个 CropImage 实例 设置超时时间
      final File? cropped =
          await CropperImage.crop(originalImage, AppConfig.cropImageTimeout);

      if (cropped != null) {
        // 上传图片并获取返回的图片 URL
        final String? imageUrl = await controller.uploadImage(cropped);
        if (imageUrl != null) {
          // 更新 UI 中的头像
          controller.userInfo['avatar'] = imageUrl;
          controller.userInfo.refresh(); // 触发 Obx 更新
        }
      }
    } catch (e) {
      print('Error creating CropperImage: $e');
    }
  }

  /// 选择生日日期
  Future<void> _selectBirthDate(TextEditingController controller) async {
    DateTime? initialDate;

    // 尝试解析当前文本中的日期
    if (controller.text != '未设置') {
      try {
        List<String> parts = controller.text.split('-');
        if (parts.length == 3) {
          initialDate = DateTime(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      } catch (e) {
        // 解析失败则使用当前日期
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    // 确保日期不会是未来的日期
    initialDate =
        initialDate!.isAfter(DateTime.now()) ? DateTime.now() : initialDate;

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
              primary: Color(0xFF409EFF), // 使用用户的主题色
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /// 获取性别文本描述
  String _getGenderText(int? gender) {
    switch (gender) {
      case 0:
        return '女';
      case 1:
        return '男';
      default:
        return '未设置';
    }
  }
}
