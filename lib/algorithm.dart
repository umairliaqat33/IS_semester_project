import 'dart:convert';
import 'dart:developer';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:is_semester_project/keys.dart';
import 'package:is_semester_project/utils.dart';

class Algorithm {
  Future<void> generateAndStoreKey() async {
    final key = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16);

    String encodedKey = base64.encode(key.bytes);
    String encodedIv = base64.encode(iv.bytes);
    Utils.saveStringToLocalStorage(
      key: Keys.key,
      value: encodedKey,
    );
    Utils.saveStringToLocalStorage(
      key: Keys.vectore,
      value: encodedIv,
    );
  }

  Future<String> encryptMessage(String message) async {
    final String? k = await Utils.getStringFromLocalStorage(key: Keys.key);
    final String? v = await Utils.getStringFromLocalStorage(key: Keys.vectore);
    encrypt.Key key = encrypt.Key.fromBase64(k!);
    encrypt.IV vector = encrypt.IV.fromBase64(v!);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(message, iv: vector);
    log('Encrypted: ${encrypted.base64}');
    return encrypted.base64;
  }

  Future<String> decryptMessage(String encryptedMessage) async {
    final String? k = await Utils.getStringFromLocalStorage(key: Keys.key);
    final String? v = await Utils.getStringFromLocalStorage(key: Keys.vectore);
    encrypt.Key key = encrypt.Key.fromBase64(k!);
    encrypt.IV vector = encrypt.IV.fromBase64(v!);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final decrypted = encrypter.decrypt64(encryptedMessage, iv: vector);
    log('Decrypted: $decrypted');
    return decrypted;
  }

  String attack(String enctyptedMessag) {
    String decrypted = '';
    try {
      final key = encrypt.Key.fromSecureRandom(32);
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      decrypted = encrypter.decrypt64(enctyptedMessag, iv: iv);
      log('Decrypted: $decrypted');
    } catch (e) {
      decrypted = e.toString();
      log(e.toString());
    }
    return decrypted;
  }
}
