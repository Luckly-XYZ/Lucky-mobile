import 'package:get/get.dart';

import 'en_US.dart';
import 'zh_CN.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zhCN,
        'en_US': enUS,
      };
}
