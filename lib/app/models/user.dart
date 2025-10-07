class User {
  // 用户id
  String userId;

  // 用户名
  String name;

  // 头像
  String avatar;

  // 性别
  int gender;

  // 生日
  String? birthday;

  // 地点
  String? location;

  // 个性签名
  String? selfSignature;

  User(
      {required this.userId,
      required this.name,
      required this.avatar,
      required this.gender,
      this.birthday,
      this.location,
      this.selfSignature});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['userId'],
        name: json['name'],
        avatar: json['avatar'],
        gender: json['gender'],
        birthday: json['birthday'],
        location: json['location'],
        selfSignature: json['selfSignature']);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'gender': gender,
      'birthday': birthday,
      'location': location,
      'selfSignature': selfSignature
    };
  }
}
