import 'package:fast_rsa/fast_rsa.dart';

/// RSA 加密工具类
///
/// - 支持 **公钥加密**、**私钥解密**
/// - 支持 **签名**、**验证**
/// - 支持 **生成 RSA 密钥对**
class RSAService {
  /// **RSA 加密**
  ///
  /// - 使用公钥对数据进行加密
  /// - [plainText] 需要加密的明文
  /// - [publicKey] 公钥
  /// - 返回 Base64 编码的密文
  static Future<String> encrypt(String plainText, String publicKey) async {
    try {
      String formattedKey = formatPublicKey(publicKey);
      return await RSA.encryptPKCS1v15(plainText, formattedKey);
    } catch (e) {
      print("🔴 RSA 加密失败: $e");
      return "";
    }
  }

  /// **RSA 解密**
  ///
  /// - 使用私钥对密文进行解密
  /// - [cipherText] 需要解密的密文（Base64 编码）
  /// - [privateKey] 私钥
  /// - 返回解密后的明文
  static Future<String> decrypt(String cipherText, String privateKey) async {
    try {
      return await RSA.decryptPKCS1v15(cipherText, privateKey);
    } catch (e) {
      print("🔴 RSA 解密失败: $e");
      return "";
    }
  }

  /// **RSA 签名**
  ///
  /// - 使用私钥对数据进行签名
  /// - [plainText] 需要签名的明文
  /// - [privateKey] 私钥
  /// - 返回 Base64 编码的签名字符串
  static Future<String> sign(String plainText, String privateKey) async {
    try {
      return await RSA.signPKCS1v15(plainText, Hash.SHA256, privateKey);
    } catch (e) {
      print("🔴 RSA 签名失败: $e");
      return "";
    }
  }

  /// **RSA 验证签名**
  ///
  /// - 使用公钥验证签名是否正确
  /// - [plainText] 原始数据
  /// - [signature] 需要验证的签名（Base64 编码）
  /// - [publicKey] 公钥
  /// - 返回 `true` 表示验证通过，`false` 表示签名不匹配
  static Future<bool> verify(
      String plainText, String signature, String publicKey) async {
    try {
      return await RSA.verifyPKCS1v15(
          signature, plainText, Hash.SHA256, publicKey);
    } catch (e) {
      print("🔴 RSA 验证失败: $e");
      return false;
    }
  }

  /// **生成 RSA 密钥对**
  ///
  /// - [keySize] 指定密钥大小（推荐 2048 或 4096）
  /// - 返回 `Map<String, String>`，包含 `privateKey` 和 `publicKey`
  static Future<Map<String, String>?> generateKeyPair(
      {int keySize = 2048}) async {
    try {
      final keyPair = await RSA.generate(keySize);
      return {
        "privateKey": keyPair.privateKey,
        "publicKey": keyPair.publicKey,
      };
    } catch (e) {
      print("🔴 RSA 密钥对生成失败: $e");
      return null;
    }
  }

  /// 格式化
  static String formatPublicKey(String key) {
    return "-----BEGIN PUBLIC KEY-----\n$key\n-----END PUBLIC KEY-----";
  }
}
