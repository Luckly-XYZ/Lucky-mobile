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
  late ApiService _apiService;
  final storage = GetStorage();
  final searchResults = <SearchMessageResult>[].obs;
  final searchHistory = <String>[].obs;
  final isSearching = false.obs;
  static const String KEY_USER_ID = 'userId';

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
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

    await _storage.write(_searchHistoryKey, searchResults);
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
    searchResults.clear();

    final storedUserId = storage.read(KEY_USER_ID);

    try {
      // 搜索单聊消息
      final singleMessages =
          await db.singleMessageDao.searchMessages(keyword, storedUserId);

      // 搜索群聊消息
      final groupMessages =
          await db.groupMessageDao.searchMessages(keyword, storedUserId);

      // 整理搜索结果
      final Map<String, SearchMessageResult> resultMap = {};

      // 处理单聊消息
      for (final message in singleMessages) {
        final chatId =
            message.fromId == storedUserId ? message.toId : message.fromId;

        if (!resultMap.containsKey(chatId)) {
          final response = await _apiService
              .getFriendInfo({'fromId': storedUserId, 'toId': chatId});

          if (response != null && response['code'] == 200) {
            Friend friend = Friend.fromJson(response['data']);
            resultMap[chatId] = SearchMessageResult(
              id: chatId,
              name: friend.name ?? "",
              avatar: friend.avatar ?? "",
              messageCount: 0,
              messages: [],
            );
          }
        }

        if (resultMap.containsKey(chatId)) {
          resultMap[chatId]!.messages.add(message);
          resultMap[chatId]!.messageCount++;
        }
      }

      // 将Map转换为List并更新searchResults
      searchResults.value = resultMap.values.toList();

      await saveSearch(keyword);
    } catch (e) {
      Get.snackbar('搜索失败', '搜索过程中出现错误: $e');
    } finally {
      isSearching.value = false;
    }
  }
}
