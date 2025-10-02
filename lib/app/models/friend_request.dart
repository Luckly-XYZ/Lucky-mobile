class FriendRequest {
  final String id;
  final String fromId;
  final String toId;
  final String name;
  final String avatar;
  final String message;
  final int approveStatus;

  FriendRequest({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.name,
    required this.avatar,
    required this.message,
    required this.approveStatus,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? '',
      fromId: json['fromId'] ?? '',
      toId: json['toId'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      message: json['message'] ?? '',
      approveStatus: json['approve_status'] ?? 0,
    );
  }
}
