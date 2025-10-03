import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import '../api/api_service.dart';
import '../database/app_database.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';

class ContactController extends GetxController {
  final RxList<Friend> contactsList = <Friend>[].obs;
  final RxBool isLoading = false.obs;
  final storage = GetStorage();
  late ApiService _apiService;

  // 数据库实例
  final db = GetIt.instance<AppDatabase>();
  static const String KEY_USER_ID = 'userId';

  var userId = ''.obs;
  final newFriendRequestCount = 0.obs;
  final RxList<FriendRequest> friendRequests = <FriendRequest>[].obs;
  final RxBool isLoadingRequests = false.obs;

  final RxBool isSearching = false.obs;
  final RxList<Friend> searchResults = <Friend>[].obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();

    final storedUserId = storage.read(KEY_USER_ID);
    if (storedUserId != null) userId.value = storedUserId;
  }

  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getFriendList({
        'userId': userId.value,
        'sequence': '0'
      });

      if (response != null && response['code'] == 200) {
        final List friendList = response['data'] ?? [];

        contactsList.value =
            friendList.map((friend) => Friend.fromJson(friend)).toList();
      } else {
        throw Exception(response?['message'] ?? '获取好友列表失败');
      }
    } catch (e) {
      Get.snackbar('错误', '获取联系人列表失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateNewFriendRequestCount(int count) {
    newFriendRequestCount.value = count;
  }

  Future<void> fetchFriendRequests() async {
    if (userId.value.isEmpty) return;

    try {
      isLoadingRequests.value = true;
      final response =
          await _apiService.getRequestFriendList({'userId': userId.value});

      if (response != null && response['code'] == 200) {
        final List requests = response['data'] ?? [];
        friendRequests.value =
            requests.map((request) => FriendRequest.fromJson(request)).toList();

        // 更新未处理的好友请求数量
        final pendingRequests = friendRequests
            .where((request) => request.approveStatus == 0)
            .length;

        updateNewFriendRequestCount(pendingRequests);
      } else {
        throw Exception(response?['message'] ?? '获取好友请求列表失败');
      }
    } catch (e) {
      Get.snackbar('错误', '获取好友请求列表失败: $e', snackPosition: SnackPosition.TOP);
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> handleFriendRequest(String requestId) async {
    try {
      final response = await _apiService
          .requestContact({'fromId': userId.value, 'toId': requestId});

      if (response != null && response['code'] == 200) {
        Get.snackbar('成功', '已发送添加好友请求');
      } else {
        throw Exception(response?['message'] ?? '发送好友请求失败');
      }
    } catch (e) {
      Get.snackbar('错误', '处理好友请求失败: $e');
    }
  }

  Future<void> handleFriendApprove(String requestId, String toId) async {
    try {
      final response = await _apiService.approveContact({
        'id': requestId,
        'fromId': userId.value,
        'toId': toId,
        'approveStatus': '1',
      });
      if (response != null && response['code'] == 200) {
        Get.snackbar('成功', '已接受好友请求');
        // 重新获取好友列表
        await fetchContacts();
        // 重新获取好友请求
        await fetchFriendRequests();
      } else {
        throw Exception(response?['message'] ?? '处理好友请求失败');
      }
    } catch (e) {
      Get.snackbar('错误', '处理好友请求失败: $e');
    }
  }

  Future<void> searchUser(String keyword) async {
    try {
      isSearching.value = true;
      searchResults.clear();

      // 获取好友信息
      final response = await _apiService
          .getFriendInfo({'fromId': userId.value, 'toId': keyword});

      if (response != null && response['code'] == 200) {
        if (response['data'] != null) {
          searchResults.value.add(Friend.fromJson(response['data']));
        } else {
          Get.snackbar('错误', '搜索用户不存在');
        }
      } else {
        throw Exception(response?['message'] ?? '搜索用户失败');
      }
    } catch (e) {
      Get.snackbar('错误', '搜索用户失败: $e');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      final response = await _apiService.requestContact({
        'fromId': userId.value,
        'toId': targetUserId,
      });

      if (response != null && response['code'] == 200) {
        Get.snackbar('成功', '好友请求已发送');
      } else {
        throw Exception(response?['message'] ?? '发送好友请求失败');
      }
    } catch (e) {
      Get.snackbar('错误', '发送好友请求失败: $e');
    }
  }
  
  Future<void> deleteFriend(String friendId) async {
    try {
      final response = await _apiService.deleteContact({
        'fromId': userId.value,
        'toId': friendId,
      });

      if (response != null && response['code'] == 200) {
        Get.snackbar('成功', '已删除好友');
        // 重新获取好友列表
        await fetchContacts();
      } else {
        throw Exception(response?['message'] ?? '删除好友失败');
      }
    } catch (e) {
      Get.snackbar('错误', '删除好友失败: $e');
    }
  }
}