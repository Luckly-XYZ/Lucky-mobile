import 'package:floor/floor.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> decode(String databaseValue) {
    return databaseValue.isNotEmpty ? databaseValue.split('|') : [];
  }

  @override
  String encode(List<String> value) {
    return value.join('|');
  }
}

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}
