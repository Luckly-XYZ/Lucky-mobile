class SearchMessageResult {
  final String id; // 用户ID
  final String name; // 用户名
  final String avatar; // 头像URL
  int messageCount; // 相关消息数量
  final List<dynamic> messages; // 消息列表，可以是SingleMessage或GroupMessage

  SearchMessageResult({
    required this.id,
    required this.name,
    required this.avatar,
    required this.messageCount,
    required this.messages,
  });
}
