import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

import './i18n/app_trans.dart';
import './routes/app_pages.dart';
import 'app/bindings/app_bindings.dart';
import 'app/database/app_database.dart';
import 'config/app_config.dart';
import 'theme/app_theme_data.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  await initApp();
  runApp(const MyApp());
}

Future<void> initApp() async {
  if (AppConfig.debug) {
    HttpOverrides.global = GlobalHttpOverrides();
  }

  WidgetsFlutterBinding.ensureInitialized();

  // 初始化GetStorage
  await GetStorage.init();

  // 自定义日志
  Get.config(
    enableLog: true, // 开启日志
    logWriterCallback: customLogWriter,
  );

  // 注册数据库
  final database =
      await $FloorAppDatabase.databaseBuilder(AppConfig.databaseName).build();
  getIt.registerSingleton<AppDatabase>(database);

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  //WidgetsFlutterBinding.ensureInitialized();
}

/// tips : 所有类启动 都需要 注意 优先级，否则可能初始化失败找不到类
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 标题
      title: 'Lucky App',
      // 初始化绑定
      initialBinding: AppAllBinding(),
      // 初始路由
      initialRoute: AppPages.initial,
      // 路由
      getPages: AppPages.rootRoutes,
      // 路由
      unknownRoute: AppPages.unknownRoute,
      // 国际化配置
      translations: AppTranslations(),
      // 默认语言
      locale: const Locale('zh', 'CN'),
      // 备用语言
      fallbackLocale: const Locale('en', 'US'),

      // 添加本地化代理
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 添加支持的语言
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],

      // 主题
      theme: AppThemeData.lightTheme,
      darkTheme: AppThemeData.darkTheme,
      themeMode: ThemeMode.system,

      // 去除debug 标志
      debugShowCheckedModeBanner: false,
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print('Background running: $task');
    return Future.value(true);
  });
}

/// 自定义日志格式，包含时间戳、类名、行号
void customLogWriter(String text, {bool isError = false}) {
  final now = DateTime.now();
  final formattedTime =
      "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}";

  final frame = StackTrace.current.toString().split("\n")[2]; // 获取调用日志的代码位置
  final fileInfo =
      RegExp(r'\((.*?):(\d+):(\d+)\)').firstMatch(frame); // 提取文件名、行号
  final file = fileInfo?.group(1) ?? "Unknown";
  final line = fileInfo?.group(2) ?? "0";

  final logText = "${isError ? '❌' : '✅'} [$formattedTime] ($file:$line) $text";
  debugPrint(logText);
}

class GlobalHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
