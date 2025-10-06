// database.dart

// required package imports
import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../database/dao/friend_dao.dart';
import '../models/chats.dart';
import '../models/friend.dart';
import '../models/group_message.dart';
import '../models/single_message.dart';
import './dao/chats_dao.dart';
import './dao/group_message_dao.dart';
import './dao/single_message_dao.dart';

//import 'converter/converter.dart';

part 'app_database.g.dart'; // the generated code will be there

//@TypeConverters([StringListConverter, DateTimeConverter])
@Database(version: 1, entities: [
  Chats,
  Friend,
  GroupMessage,
  SingleMessage,
])
abstract class AppDatabase extends FloorDatabase {
  ChatsDao get chatsDao;

  FriendDao get friendDao;

  SingleMessageDao get singleMessageDao;

  GroupMessageDao get groupMessageDao;
}

//在使用 Flutter 的 Floor ORM 框架时，如果无法引用 $FloorAppDatabase，可能是由于以下原因：
//未生成数据库代码：Floor 通过代码生成器创建数据库相关代码，包括 $FloorAppDatabase。如果未运行代码生成命令，可能导致无法引用该类。
//解决方案：在项目根目录的终端运行以下命令：
//flutter packages pub run build_runner build
//此命令将生成必要的数据库代码。如果希望在代码更改时自动生成代码，可以使用：
//flutter packages pub run build_runner watch
//这将监听文件变化并自动生成代码。
//
//文件命名不一致：确保数据库定义文件的文件名与 part 指令中的文件名一致。例如，如果数据库定义在 app_database.dart 中，文件顶部应包含：

//part 'app_database.g.dart';
//不一致的命名可能导致代码生成失败。
//
//缺少必要的依赖：确保在 pubspec.yaml 中添加了 Floor 和 build_runner 依赖：
//
//yaml
//复制
//编辑
//dependencies:
//floor: ^1.0.0
//
//dev_dependencies:
//build_runner: ^2.0.0
//然后运行 flutter pub get 获取依赖。
//
//代码生成冲突：如果之前生成的代码存在冲突，可能导致生成失败。
//
//解决方案：先清理生成的代码，然后重新生成：

//flutter packages pub run build_runner clean
//flutter packages pub run build_runner build --delete-conflicting-outputs
//这将删除冲突的输出并重新生成代码。
//
//通过以上步骤，您应该能够解决无法引用 $FloorAppDatabase 的问题。如果问题仍然存在，建议检查项目配置和代码，以确保所有设置正确。
