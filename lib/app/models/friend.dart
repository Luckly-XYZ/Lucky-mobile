import 'package:floor/floor.dart';

@Entity(tableName: 'friend', indices: [
  Index(value: ['userId', 'friendId', 'name'])
])
class Friend {
  @primaryKey
  String? userId;
  String? friendId;
  String? name;
  String? alias; // 别名
  String? avatar;
  int? gender;
  String? location;
  int? black; // 是否拉黑 1正常 2拉黑
  int? flag;
  String? birthDay;
  String? selfSignature;
  int? sequence;

  Friend({
    this.userId,
    this.friendId,
    this.name,
    this.alias,
    this.avatar,
    this.gender,
    this.location,
    this.black,
    this.flag,
    this.birthDay,
    this.selfSignature,
    this.sequence,
  });

  Friend.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    friendId = json['friendId'];
    name = json['name'];
    alias = json['alias'];
    avatar = json['avatar'];
    gender = json['gender'];
    location = json['location'];
    black = json['black'];
    flag = json['flag'];
    birthDay = json['birthDay'];
    selfSignature = json['selfSignature'];
    sequence = json['sequence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['friendId'] = friendId;
    data['name'] = name;
    data['alias'] = alias;
    data['avatar'] = avatar;
    data['gender'] = gender;
    data['location'] = location;
    data['black'] = black;
    data['flag'] = flag;
    data['birthDay'] = birthDay;
    data['selfSignature'] = selfSignature;
    data['sequence'] = sequence;
    return data;
  }
}
