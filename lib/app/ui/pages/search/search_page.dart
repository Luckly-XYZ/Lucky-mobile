import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_sizes.dart';
import '../../../controller/search_controller.dart';

class SearchPage extends GetView<SearchsController> {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchTextController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFCCCCCC),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: searchTextController,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: '搜索聊天记录',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    isDense: true,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF999999),
                      size: 18,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 32,
                    ),
                  ),
                  style: const TextStyle(fontSize: kSize16),
                  onSubmitted: controller.performSearch,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('取消'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => controller.isSearching.value
                ? const Center(child: CircularProgressIndicator())
                : controller.searchResults.isEmpty
                    ? _buildSearchHistory(searchTextController)
                    : _buildSearchResults()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => const Divider(
        height: 0.5,
        thickness: 0.5,
        color: Color(0xFFCCCCCC),
      ),
      itemBuilder: (context, index) {
        final result = controller.searchResults[index];
        return SizedBox(
          height: 48,
          child: Row(
            children: [
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  result.avatar,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${result.messageCount}条相关聊天记录',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchHistory(TextEditingController searchTextController) {
    return Obx(() => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.searchHistory.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '搜索历史',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: controller.clearSearchHistory,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.searchHistory.map((keyword) {
                  return InkWell(
                    onTap: () {
                      searchTextController.text = keyword;
                      controller.performSearch(keyword);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        keyword,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ));
  }
}
