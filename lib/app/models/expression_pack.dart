// ignore: unused_import
import 'dart:convert';

/// 表情类型枚举
enum ExpressionType { emoji, image }

/// 扩展方法：将字符串转换为 ExpressionType 枚举
ExpressionType expressionTypeFromString(String type) {
  switch (type) {
    case 'emoji':
      return ExpressionType.emoji;
    case 'image':
      return ExpressionType.image;
    default:
      throw ArgumentError('Invalid expression type: $type');
  }
}

/// 表情包类
class ExpressionPack {
  final String packName; // 表情包名称
  final List<Expression> expressions; // 表情列表
  final ExpressionType type; // 使用枚举代替字符串
  ExpressionPack({
    required this.packName,
    required this.expressions,
    required this.type,
  });

  /// JSON 转 Dart 对象
  factory ExpressionPack.fromJson(Map<String, dynamic> json) {
    return ExpressionPack(
      packName: json['packName'] ?? '',
      expressions: (json['expressions'] as List<dynamic>)
          .map((e) => Expression.fromJson(e))
          .toList(),
      type: expressionTypeFromString(json['type'] ?? 'emoji'),
    );
  }

  /// Dart 对象转 JSON
  Map<String, dynamic> toJson() {
    return {
      'packName': packName,
      'expressions': expressions.map((e) => e.toJson()).toList(),
    };
  }
}

/// 单个表情类
class Expression {
  final String id; // 表情ID
  final String name; // 表情名称

  final String? unicode; // 表情Unicode码
  String? imageURL; // 表情图片URL
  final String? description; // 表情描述
  final String? category; // 表情分类
  final List<String>? tags; // 表情标签
  final Map<String, dynamic>? extra; // 表情扩展信息

  Expression({
    required this.id,
    required this.name,
    this.unicode,
    this.imageURL,
    this.description,
    this.category,
    this.tags,
    this.extra,
  });

  /// JSON 转 Dart 对象
  factory Expression.fromJson(Map<String, dynamic> json) {
    return Expression(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      // type: expressionTypeFromString(json['type'] ?? 'emoji'),
      unicode: json['unicode'],
      imageURL: json['imageURL'],
      description: json['description'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      extra: json['extra'] != null
          ? Map<String, dynamic>.from(json['extra'])
          : null,
    );
  }

  /// Dart 对象转 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'type': type.name, // 枚举转换为字符串
      'unicode': unicode,
      'imageURL': imageURL,
      'description': description,
      'category': category,
      'tags': tags,
      'extra': extra,
    };
  }
}

// void main() {
//   String jsonString = '''
//   {
//     "packName": "常用表情包",
//     "expressions": [
//       {
//         "id": "001",
//         "name": "微笑",
//         "type": "emoji",
//         "unicode": "😊",
//         "description": "表示友好和高兴的表情",
//         "category": "情感",
//         "tags": ["开心", "友好"],
//         "extra": {
//           "useCase": "适合用于聊天中表示开心"
//         }
//       },
//       {
//         "id": "003",
//         "name": "愤怒",
//         "type": "image",
//         "imageURL": "https://example.com/images/angry.png",
//         "description": "表示愤怒的表情",
//         "category": "情感",
//         "tags": ["愤怒", "生气"],
//         "extra": {
//           "useCase": "适合表示不满或生气的情绪"
//         }
//       }
//     ]
//   }
//   ''';

//   // JSON 转 Dart 对象
//   Map<String, dynamic> jsonData = jsonDecode(jsonString);
//   ExpressionPack pack = ExpressionPack.fromJson(jsonData);

//   print("Pack Name: ${pack.packName}");
//   print("First Expression Name: ${pack.expressions.first.name}");
//   print("First Expression Type: ${pack.expressions.first.type}");

//   // Dart 对象转 JSON
//   String encodedJson = jsonEncode(pack.toJson());
//   print("Encoded JSON: $encodedJson");
// }
