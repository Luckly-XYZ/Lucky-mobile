import 'package:flutter_im/app/models/friend.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import '../api/api_service.dart';
import '../database/app_database.dart';
import '../models/search_message_result.dart';

class SearchsController extends GetxController {
  final _storage = GetStorage();
  static const String _searchHistoryKey = 'search_history';

  // 数据库实例
  final db = GetIt.instance<AppDatabase>();
  final ApiService _apiService = Get.find<ApiService>();
  final storage = GetStorage();
  final searchResults = <SearchMessageResult>[].obs;
  final searchHistory = <String>[].obs;
  final isSearching = false.obs;
  static const String KEY_USER_ID = 'userId';

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
  }

  // 加载搜索历史
  Future<void> loadSearchHistory() async {
    final List<dynamic>? history = _storage.read<List>(_searchHistoryKey);
    if (history != null) {
      searchHistory.value = history.map((e) => e.toString()).toList();
    }
  }

  // 保存搜索历史
  Future<void> saveSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    searchHistory.remove(keyword);
    searchHistory.insert(0, keyword);
    if (searchHistory.length > 10) {
      searchHistory.removeLast();
    }

    await _storage.write(_searchHistoryKey, searchHistory);
  }

  // 清除搜索历史
  void clearSearchHistory() {
    searchHistory.clear();
    _storage.remove(_searchHistoryKey);
  }

  // 执行搜索
  Future<void> performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    isSearching.value = true;

    final storedUserId = storage.read(KEY_USER_ID);

    try {
      // TODO: 实现真实的搜索逻辑
      // 1. 搜索单聊消息
      final singleMessages =
          await db.singleMessageDao.searchMessages(keyword, storedUserId);

      // 2. 搜索群聊消息
      final groupMessages =
          await db.groupMessageDao.searchMessages(keyword, storedUserId);

      Get.log("aaaa");

      // 3. 整理搜索结果
      final Map<String, SearchMessageResult> resultMap = {};

      // 处理单聊消息
      for (final message in singleMessages) {
        final chatId =
            message.fromId == storedUserId ? message.toId : message.fromId;

        if (!resultMap.containsKey(chatId)) {
          final response = await _apiService
              .getFriendInfo({'fromId': storedUserId, 'toId': chatId});

          if (response != null && response['status'] == 200) {
            Friend friend = Friend.fromJson(response['data']);
            resultMap[chatId] = SearchMessageResult(
              id: chatId,
              name: friend.name ?? "",
              // 假设消息中包含发送者名称
              avatar: friend.avatar ?? "",
              // 假设消息中包含头像
              messageCount: 0,
              messages: [],
            );
          }
        }

        resultMap[chatId]!.messages.add(message);
        resultMap[chatId]!.messageCount++;
      }

      // 将Map转换为List并更新searchResults
      searchResults.value = resultMap.values.toList();

      await saveSearch(keyword);

      // // 处理群聊消息
      // for (final message in groupMessages) {
      //   final groupId = message.groupId;

      //   if (!resultMap.containsKey(groupId)) {
      //     resultMap[groupId] = SearchMessageResult(
      //       id: groupId,
      //       name: message.groupName, // 假设消息中包含群组名称
      //       avatar: message.groupAvatar, // 假设消息中包含群组头像
      //       messageCount: 0,
      //       messages: [],
      //       isGroup: true,
      //     );
      //   }

      //   resultMap[groupId]!.messages.add(message);
      //   resultMap[groupId]!.messageCount++;
      // }

      // 3. 整理搜索结果
      // TODO: 根据消息分组整理结果
      // searchResults.value = [
      //   SearchMessageResult(
      //     id: "user1",
      //     name: "张三",
      //     avatar: "https://example.com/avatar1.jpg",
      //     messageCount: 3,
      //     messages: [],
      //   ),
      //   SearchMessageResult(
      //     id: "user2",
      //     name: "李四",
      //     avatar: "https://example.com/avatar2.jpg",
      //     messageCount: 5,
      //     messages: [],
      //   ),
      // ];

      await saveSearch(keyword);
    } catch (e) {
      // TODO: 错误处理
      print(e);
    } finally {
      isSearching.value = false;
    }
  }
}
