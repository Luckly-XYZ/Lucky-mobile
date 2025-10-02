import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path; // 添加这行导入
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// 从 assets 目录加载 JSON 文件，并解析为 Map
  static Future<Map<String, dynamic>> loadJson(String path) async {
    try {
      String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print("Error loading JSON file: $e");
      return {};
    }
  }

  /// 获取应用的文档目录
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// 获取应用的文档目录
  static Future<String> getPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// 创建文件
  static Future<File> createFile(String filePath, String content) async {
    final file = File(filePath);
    return file.writeAsString(content);
  }

  /// 创建文件夹
  static Future<Directory> createDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      return await directory.create(recursive: true);
    }
    return directory;
  }

  /// 重命名文件
  static Future<File> renameFile(String oldPath, String newPath) async {
    final file = File(oldPath);
    if (await file.exists()) {
      return file.rename(newPath);
    }
    throw FileSystemException("File does not exist", oldPath);
  }

  /// 删除文件或文件夹
  static Future<void> deleteFileOrDirectory(String path) async {
    final entity = FileSystemEntity.typeSync(path);
    if (entity == FileSystemEntityType.directory) {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } else if (entity == FileSystemEntityType.file) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// 复制文件
  static Future<File> copyFile(
      String sourcePath, String destinationPath) async {
    final file = File(sourcePath);
    if (await file.exists()) {
      return file.copy(destinationPath);
    }
    throw FileSystemException("Source file does not exist", sourcePath);
  }

  /// 扫描指定目录下指定后缀的文件
  /// [subPath] 相对于应用文档目录的子路径
  /// [extensions] 要扫描的文件后缀列表，如 ['.txt', '.doc']
  /// 返回符合条件的文件信息列表
  static Future<List<FileInfo>> scanFilesWithExtension(
    String subPath,
    List<String> extensions,
  ) async {
    try {
      final basePath = await getDocumentsPath();
      final fullPath = Directory(path.join(basePath, subPath));

      if (!await fullPath.exists()) {
        throw FileSystemException("目录不存在", fullPath.path);
      }

      final List<FileInfo> files = [];
      await for (final entity
          in fullPath.list(recursive: true, followLinks: false)) {
        if (entity is File &&
            extensions.any((ext) =>
                entity.path.toLowerCase().endsWith(ext.toLowerCase()))) {
          final String filePath = entity.path;
          final String fileName = path.basename(filePath);
          final String relativePath = path.relative(filePath, from: basePath);
          final String dirPath = path.dirname(filePath);
          files.add(FileInfo(
            fileName: fileName,
            filePath: filePath,
            relativePath: relativePath,
            dirPath: dirPath,
          ));
        }
      }

      return files;
    } catch (e) {
      print("扫描文件出错: $e");
      return [];
    }
  }
}

/// 文件扫描结果模型
class FileInfo {
  final String fileName; // 文件名
  final String filePath; // 完整路径
  final String relativePath; // 相对路径
  final String dirPath; // 文件夹路径

  FileInfo(
      {required this.fileName,
      required this.filePath,
      required this.relativePath,
      required this.dirPath});
}
