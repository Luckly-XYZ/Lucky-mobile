/// 常见正则表达式工具类
class RegexUtils {
  static final Map<String, String> cityMap = Map();

  /// Return whether input matches regex of simple mobile.
  /// 判断输入字符串是否符合手机号
  static bool isMobileSimple(String input) {
    return matches(RegexConstants.REGEX_MOBILE_SIMPLE, input);
  }

  /// Return whether input matches regex of exact mobile.
  /// 精确验证是否是手机号
  static bool isMobileExact(String input) {
    return matches(RegexConstants.REGEX_MOBILE_EXACT, input);
  }

  /// Return whether input matches regex of telephone number.
  /// 判断返回输入是否匹配电话号码的正则表达式
  static bool isTel(String input) {
    return matches(RegexConstants.REGEX_TEL, input);
  }

  /// Return whether input matches regex of id card number.
  /// 返回输入是否匹配身份证号码的正则表达式。
  static bool isIDCard(String input) {
    if (input.length == 15) {
      return isIDCard15(input);
    }
    if (input.length == 18) {
      return isIDCard18Exact(input);
    }
    return false;
  }

  /// Return whether input matches regex of id card number which length is 15.
  /// 返回输入是否匹配长度为15的身份证号码的正则表达式。
  static bool isIDCard15(String input) {
    return matches(RegexConstants.REGEX_ID_CARD15, input);
  }

  /// Return whether input matches regex of id card number which length is 18.
  /// 返回输入是否匹配长度为18的身份证号码的正则表达式。
  static bool isIDCard18(String input) {
    return matches(RegexConstants.REGEX_ID_CARD18, input);
  }

  /// Return whether input matches regex of exact id card number which length is 18.
  /// 返回输入是否匹配长度为18的id卡号的正则表达式。
  static bool isIDCard18Exact(String input) {
    if (isIDCard18(input)) {
      List<int> factor = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
      List<String> suffix = [
        '1',
        '0',
        'X',
        '9',
        '8',
        '7',
        '6',
        '5',
        '4',
        '3',
        '2'
      ];
      if (cityMap.isEmpty) {
        List<String> list = ID_CARD_PROVINCE_DICT;
        List<MapEntry<String, String>> mapEntryList = [];
        for (int i = 0, length = list.length; i < length; i++) {
          List<String> tokens = list[i].trim().split('=');
          MapEntry<String, String> mapEntry = MapEntry(tokens[0], tokens[1]);
          mapEntryList.add(mapEntry);
        }
        cityMap.addEntries(mapEntryList);
      }
      if (cityMap[input.substring(0, 2)] != null) {
        int weightSum = 0;
        for (int i = 0; i < 17; ++i) {
          weightSum += (input.codeUnitAt(i) - '0'.codeUnitAt(0)) * factor[i];
        }
        int idCardMod = weightSum % 11;
        String idCardLast = String.fromCharCode(input.codeUnitAt(17));
        return idCardLast == suffix[idCardMod];
      }
    }
    return false;
  }

  /// Return whether input matches regex of email.
  /// 返回输入是否匹配电子邮件的正则表达式。
  static bool isEmail(String input) {
    return matches(RegexConstants.REGEX_EMAIL, input);
  }

  /// Return whether input matches regex of url.
  /// 返回输入是否匹配url的正则表达式。
  static bool isURL(String input) {
    return matches(RegexConstants.REGEX_URL, input);
  }

  /// Return whether input matches regex of Chinese character.
  /// 返回输入是否匹配汉字的正则表达式。
  static bool isZh(String input) {
    return '〇' == input || matches(RegexConstants.REGEX_ZH, input);
  }

  /// Return whether input matches regex of date which pattern is 'yyyy-MM-dd'.
  /// 返回输入是否匹配样式为'yyyy-MM-dd'的日期的正则表达式。
  static bool isDate(String input) {
    return matches(RegexConstants.REGEX_DATE, input);
  }

  /// Return whether input matches regex of ip address.
  /// 返回输入是否匹配ip地址的正则表达式。
  static bool isIP(String input) {
    return matches(RegexConstants.REGEX_IP, input);
  }

  /// Return whether input matches regex of username.
  /// 返回输入是否匹配用户名的正则表达式。
  static bool isUserName(String input,
      {String regex = RegexConstants.REGEX_USERNAME}) {
    return matches(regex, input);
  }

  /// Return whether input matches regex of QQ.
  /// 返回是否匹配QQ的正则表达式。
  static bool isQQ(String input) {
    return matches(RegexConstants.REGEX_QQ_NUM, input);
  }

  /// Return whether input matches the regex.
  /// 返回输入是否匹配正则表达式。
  static bool matches(String regex, String input) {
    if (input.isEmpty) {
      return false;
    }
    return RegExp(regex).hasMatch(input);
  }

  /// 判断内容是否符合正则
// static bool hasMatch(String s, Pattern p){
//   return (s == null) ? false : RegExp(p).hasMatch(s);
// }
}

/// id card province dict.
List<String> ID_CARD_PROVINCE_DICT = [
  '11=北京',
  '12=天津',
  '13=河北',
  '14=山西',
  '15=内蒙古',
  '21=辽宁',
  '22=吉林',
  '23=黑龙江',
  '31=上海',
  '32=江苏',
  '33=浙江',
  '34=安徽',
  '35=福建',
  '36=江西',
  '37=山东',
  '41=河南',
  '42=湖北',
  '43=湖南',
  '44=广东',
  '45=广西',
  '46=海南',
  '50=重庆',
  '51=四川',
  '52=贵州',
  '53=云南',
  '54=西藏',
  '61=陕西',
  '62=甘肃',
  '63=青海',
  '64=宁夏',
  '65=新疆',
  '71=台湾老',
  '81=香港',
  '82=澳门',
  '83=台湾新',
  '91=国外',
];

/// 正则表达式的常量，参考AndroidUtils：https://github.com/Blankj/AndroidUtilCode
class RegexConstants {
  ///Regex of simple mobile.
  ///简单移动电话的正则表达式
  static const String REGEX_MOBILE_SIMPLE = "^[1]\\d{10}\$";

  /// Regex of exact mobile.
  ///  <p>china mobile: 134(0-8), 135, 136, 137, 138, 139, 147, 150, 151, 152, 157, 158, 159, 165, 172, 178, 182, 183, 184, 187, 188, 195, 197, 198</p>
  ///  <p>china unicom: 130, 131, 132, 145, 155, 156, 166, 167, 175, 176, 185, 186, 196</p>
  ///  <p>china telecom: 133, 149, 153, 162, 173, 177, 180, 181, 189, 190, 191, 199</p>
  ///  <p>china broadcasting: 192</p>
  ///  <p>global star: 1349</p>
  ///  <p>virtual operator: 170, 171</p>
  static const String REGEX_MOBILE_EXACT =
      "^((13[0-9])|(14[579])|(15[0-35-9])|(16[2567])|(17[0-35-8])|(18[0-9])|(19[0-35-9]))\\d{8}\$";

  /// Regex of telephone number.
  static const String REGEX_TEL = "^0\\d{2,3}[- ]?\\d{7,8}\$";

  /// Regex of id card number which length is 15.
  static const String regexIdCard15 =
      '^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}\$';

  /// Regex of id card number which length is 15.
  static const String REGEX_ID_CARD15 =
      "^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}\$";

  /// Regex of id card number which length is 18.
  static const String REGEX_ID_CARD18 =
      "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9Xx])\$";

  ///Regex of email.
  static const String REGEX_EMAIL =
      "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";

  ///Regex of url.
  static const String REGEX_URL = "[a-zA-z]+://[^\\s]*";

  ///Regex of Chinese character.
  static const String REGEX_ZH = "^[\\u4e00-\\u9fa5]+\$";

  /// Regex of username.
  /// <p>scope for "a-z", "A-Z", "0-9", "_", "Chinese character"</p>
  /// <p>can't end with "_"</p>
  /// <p>length is between 6 to 20</p>
  static const String REGEX_USERNAME = "^[\\w\\u4e00-\\u9fa5]{6,20}(?<!_)\$";

  /// must contain letters and numbers, 6 ~ 18.
  /// 必须包含字母和数字, 6~18.
  static const String REGEX_USERNAME1 =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z]{6,18}\$';

  /// must contain letters and numbers, can contain special characters 6 ~ 18.
  /// 必须包含字母和数字,可包含特殊字符 6~18.
  static const String REGEX_USERNAME2 =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z\\W]{6,18}\$';

  /// must contain letters and numbers and special characters, 6 ~ 18.
  /// 必须包含字母和数字和殊字符, 6~18.
  static const String REGEX_USERNAME3 =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)(?![0-9a-zA-Z]+\$)(?![0-9\\W]+\$)(?![a-zA-Z\\W]+\$)[0-9A-Za-z\\W]{6,18}\$';

  /// Regex of date which pattern is "yyyy-MM-dd".
  static const String REGEX_DATE =
      "^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)\$";

  /// Regex of ip address.
  static const String REGEX_IP =
      "((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)";

  ///////////////////////////////////////////////////////////////////////////
  // The following come from http://tool.oschina.net/regex
  ///////////////////////////////////////////////////////////////////////////

  /// Regex of double-byte characters.
  static const String REGEX_DOUBLE_BYTE_CHAR = "[^\\x00-\\xff]";

  /// Regex of blank line.
  static const String REGEX_BLANK_LINE = "\\n\\s*\\r";

  /// Regex of QQ number.
  static const String REGEX_QQ_NUM = "[1-9][0-9]{4,}";

  /// Regex of postal code in China.
  static const String REGEX_CHINA_POSTAL_CODE = "[1-9]\\d{5}(?!\\d)";

  /// Regex of integer.
  static const String REGEX_INTEGER = "^(-?[1-9]\\d*)|0\$";

  /// Regex of positive integer.
  static const String REGEX_POSITIVE_INTEGER = "^[1-9]\\d*\$";

  /// Regex of negative integer.
  static const String REGEX_NEGATIVE_INTEGER = "^-[1-9]\\d*\$";

  /// Regex of non-negative integer.
  static const String REGEX_NOT_NEGATIVE_INTEGER = "^[1-9]\\d*|0\$";

  /// Regex of non-positive integer.
  static const String REGEX_NOT_POSITIVE_INTEGER = "^-[1-9]\\d*|0\$";

  /// Regex of positive float.
  static const String REGEX_FLOAT =
      "^-?([1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*|0?\\.0+|0)\$";

  /// Regex of positive float.
  static const String REGEX_POSITIVE_FLOAT =
      "^[1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*\$";

  /// Regex of negative float.
  static const String REGEX_NEGATIVE_FLOAT =
      "^-[1-9]\\d*\\.\\d*|-0\\.\\d*[1-9]\\d*\$";

  /// Regex of positive float.
  static const String REGEX_NOT_NEGATIVE_FLOAT =
      "^[1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*|0?\\.0+|0\$";

  ///Regex of negative float.
  ///
  static const String REGEX_NOT_POSITIVE_FLOAT =
      "^(-([1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*))|0?\\.0+|0\$";

  /// Email regex
  /// email正则表达式
  static Pattern email =
      r'^[a-z0-9]+([-+._][a-z0-9]+){0,2}@.*?(\.(a(?:[cdefgilmnoqrstuwxz]|ero|(?:rp|si)a)|b(?:[abdefghijmnorstvwyz]iz)|c(?:[acdfghiklmnoruvxyz]|at|o(?:m|op))|d[ejkmoz]|e(?:[ceghrstu]|du)|f[ijkmor]|g(?:[abdefghilmnpqrstuwy]|ov)|h[kmnrtu]|i(?:[delmnoqrst]|n(?:fo|t))|j(?:[emop]|obs)|k[eghimnprwyz]|l[abcikrstuvy]|m(?:[acdeghklmnopqrstuvwxyz]|il|obi|useum)|n(?:[acefgilopruz]|ame|et)|o(?:m|rg)|p(?:[aefghklmnrstwy]|ro)|qa|r[eosuw]|s[abcdeghijklmnortuvyz]|t(?:[cdfghjklmnoprtvwz]|(?:rav)?el)|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw])\b){1,2}$';

  /// URL regex
  /// Eg:
  /// - https://medium.com/@diegoveloper/flutter-widget-size-and-position-b0a9ffed9407
  /// - https://www.youtube.com/watch?v=COYFmbVEH0k
  /// - https://stackoverflow.com/questions/53913192/flutter-change-the-width-of-an-alertdialog/57688555
  static Pattern url =
      r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-@]+))*$";

  /// Hexadecimal regex
  static Pattern hexadecimal = r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$';

  /// Image vector regex
  /// 图像向量正则表达式
  static Pattern vector = r'.(svg)$';

  /// Image regex
  /// 图像正则表达式
  static Pattern image = r'.(jpeg|jpg|gif|png|bmp)$';

  /// Audio regex
  /// 音频正则表达式
  static Pattern audio = r'.(mp3|wav|wma|amr|ogg)$';

  /// Video regex
  /// 视频正则表达式
  static Pattern video = r'.(mp4|avi|wmv|rmvb|mpg|mpeg|3gp)$';

  /// Txt regex
  /// 文本正则表达式
  static Pattern txt = r'.txt$';

  /// Document regex
  /// word正则表达式
  static Pattern doc = r'.(doc|docx)$';

  /// Excel regex
  /// Excel正则表达式
  static Pattern excel = r'.(xls|xlsx)$';

  /// PPT regex
  /// ppt正则表达式
  static Pattern ppt = r'.(ppt|pptx)$';

  /// Document regex
  /// apk正则表达式
  static Pattern apk = r'.apk$';

  /// PDF regex
  /// pdf正则表达式
  static Pattern pdf = r'.pdf$';

  /// HTML regex
  /// html正则表达式
  static Pattern html = r'.html$';

  /// DateTime regex (UTC)
  /// 时间正则表达式
  /// Unformatted date time (UTC and Iso8601)
  /// Example: 2020-04-27 08:14:39.977, 2020-04-27T08:14:39.977, 2020-04-27 01:14:39.977Z
  static Pattern basicDateTime =
      r'^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}.\d{3}Z?$';

  /// MD5 regex
  /// md5正则表达式
  static Pattern md5 = r'^[a-f0-9]{32}$';

  /// SHA1 regex
  /// sha1正则表达式
  static Pattern sha1 =
      r'(([A-Fa-f0-9]{2}\:){19}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{40})';

  /// SHA256 regex
  /// sha256正则表达式
  static Pattern sha256 =
      r'([A-Fa-f0-9]{2}\:){31}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{64}';

  /// IPv4 regex
  /// IPv4正则表达式
  static Pattern ipv4 = r'^(?:(?:^|\.)(?:2(?:5[0-5]|[0-4]\d)|1?\d?\d)){4}$';

  /// IPv6 regex
  /// IPv6正则表达式
  static Pattern ipv6 =
      r'^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(([0-9A-Fa-f]{1,4}:){0,5}:((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(::([0-9A-Fa-f]{1,4}:){0,5}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$';

  /// Numeric Only regex (No Whitespace & Symbols)
  /// 只有数字的正则表达式(没有空格和符号)
  static Pattern numericOnly = r'^\d+$';

  /// Alphabet Only regex (No Whitespace & Symbols)
  /// 仅限字母正则表达式(无空格和符号)
  static Pattern alphabetOnly = r'^[a-zA-Z]+$';

  /// Password (Easy) Regex
  /// Allowing all character except 'whitespace'
  /// Minimum character: 8
  static Pattern passwordEasy = r'^\S{8,}$';

  /// Password (Easy) Regex
  /// Allowing all character
  /// Minimum character: 8
  static Pattern passwordEasyAllowedWhitespace = r'^[\S ]{8,}$';

  /// Password (Normal) Regex
  /// Allowing all character except 'whitespace'
  /// Must contains at least: 1 letter & 1 number
  /// Minimum character: 8
  static Pattern passwordNormal1 = r'^(?=.*[A-Za-z])(?=.*\d)\S{8,}$';

  /// Password (Normal) Regex
  /// Allowing all character
  /// Must contains at least: 1 letter & 1 number
  /// Minimum character: 8
  static Pattern passwordNormal1AllowedWhitespace =
      r'^(?=.*[A-Za-z])(?=.*\d)[\S ]{8,}$';

  /// Password (Normal) Regex
  /// Allowing LETTER and NUMBER only
  /// Must contains at least: 1 letter & 1 number
  /// Minimum character: 8
  static Pattern passwordNormal2 = r'^(?=.*[A-Za-z])(?=.*\d)[a-zA-Z0-9]{8,}$';

  /// Password (Normal) Regex
  /// Allowing LETTER and NUMBER only
  /// Must contains: 1 letter & 1 number
  /// Minimum character: 8
  static Pattern passwordNormal2AllowedWhitespace =
      r'^(?=.*[A-Za-z])(?=.*\d)[a-zA-Z0-9 ]{8,}$';

  /// Password (Normal) Regex
  /// Allowing all character except 'whitespace'
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter & 1 number
  /// Minimum character: 8
  static Pattern passwordNormal3 = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)\S{8,}$';

  /// Password (Normal) Regex
  /// Allowing all character
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter & 1 number
  /// Minimum character: 8
  static Pattern passwordNormal3AllowedWhitespace =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[\S ]{8,}$';

  /// Password (Hard) Regex
  /// Allowing all character except 'whitespace'
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, & 1 special character (symbol)
  /// Minimum character: 8
  static Pattern passwordHard =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])\S{8,}$';

  /// Password (Hard) Regex
  /// Allowing all character
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, & 1 special character (symbol)
  /// Minimum character: 8
  static Pattern passwordHardAllowedWhitespace =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[\S ]{8,}$';
}
