// file: lib/objects.dart

typedef JsonLike = Map<String, dynamic>;

class Objects {

  Objects._();

  /// 通用判空：支持 String / Iterable / Map / null / num / bool / 自定义对象 (尝试 toJson/toMap)
  /// [deep] = true 时会递归检查 Map/Iterable 内部元素是否都为空（常用于判断“所有字段都为空”的场景）
  static bool isEmpty(Object? value, {bool deep = false}) {
    // null 一律为空
    if (value == null) return true;

    // String：trim 后空字符串视为空
    if (value is String) return value.trim().isEmpty;

    // Iterable (List, Set, ...)
    if (value is Iterable) {
      if (!deep) return value.isEmpty;
      // deep: 若任一元素非空则整体非空
      for (final e in value) {
        if (!isEmpty(e, deep: true)) return false;
      }
      return true;
    }

    // Map
    if (value is Map) {
      if (!deep) return value.isEmpty;
      // deep: 若任一 key/value 非空则整体非空
      if (value.isEmpty) return true;
      for (final entry in value.entries) {
        if (!isEmpty(entry.value, deep: true)) return false;
      }
      return true;
    }

    // 基础类型：数字 / 布尔 不视为空
    if (value is num) return false;
    if (value is bool) return false;

    // 尝试调用 toJson 或 toMap（常见 pattern）
    try {
      final dynamic dyn = value;
      // prefer toJson if exists
      final dynamic json = dyn.toJson();
      // 如果 toJson 返回 Map/Iterable/string etc，则递归判断
      return isEmpty(json, deep: deep);
    } catch (_) {
      // ignore
    }

    try {
      final dynamic dyn = value;
      final dynamic map = dyn.toMap();
      return isEmpty(map, deep: deep);
    } catch (_) {
      // ignore
    }

    // fallback: 若对象的 toString() 明显为空或 'null'，视作空；否则认为非空
    final s = value.toString();
    if (s == null) return true;
    final trimmed = s.trim();
    if (trimmed.isEmpty) return true;
    // Some generated models print "Instance of 'X'" which is not empty
    // If you want to treat 'Instance of' as empty, uncomment next line:
    // if (trimmed.startsWith('Instance of')) return true;
    return false;
  }

  static bool isNotEmpty(Object? value, {bool deep = false}) => !isEmpty(value, deep: deep);

  /// 判断字符串是否为 null / 空 / 全空白
  static bool isBlank(String? s) => s == null || s.trim().isEmpty;
  static bool isNotBlank(String? s) => !isBlank(s);
}

/// 常用的扩展方法，方便写法：
///   myString.isNullOrEmpty  或  myList.isNullOrEmpty
extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}

extension NullableIterableExtensions<E> on Iterable<E>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension NullableMapExtensions<K, V> on Map<K, V>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
