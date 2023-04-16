import 'dart:developer';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataEncryption {
  DataEncryption._();
  static DataEncryption instance = DataEncryption._();

  final String _secureStorageKey = 'SecureKey';
  //final String _secureStoragePassword = 'JuMT,^7EMPh``^xbj{jS`m={<)Wy(t&3';
  final String _secureStoragePassword =
      '-W(/Fb"T/S,tRrA78*?{FR_9sBwk<9(M*YwV_sT,sK7bS~MRx*+~\*]&k3D-z4SGw~>`q8Ln_/^;KA*#>NQ_Lfz!uvWXFnFG@{qHy@qgk-y2]S:~u)T7.-cpet"@fd`/';

  //final String _secureStoragePassword = 'wUrAvFtduXgheNWZdUGuFU3USCF5aWABEYPjBhHcUBurhmzZHS6AvY4DD2FFprJs4EZFeurGmY4vGM5EDAfknMBWpwqQWK2aTkMjhNyprSJsjrhuLRPZvJYSKW2nmCRu';

  //Password Generated from "https://passwordsgenerator.net/"

  //:::::::::::::::: Write To Secure Storage ::::::::::::::::
  Future<void> writeValueToSecureStorage() async {
    // Create storage
    const storage = FlutterSecureStorage();
    // Write value
    await storage.write(key: _secureStorageKey, value: _secureStoragePassword);
  }

  //:::::::::::::::: Get Key From Secure Storage ::::::::::::::::
  Future<String> getPasswordSecureStorage() async {
    // Create storage
    const storage = FlutterSecureStorage();

    /// Read value
    String password = await storage.read(key: _secureStorageKey) ?? '';
    return password;
  }

  //:::::::::::::::::::: Create Encrypter :::::::::::::::::::
  Future<Encrypter> createEncrypter() async {
    String password = await getPasswordSecureStorage();
    log('key: $password');
    final key = Key.fromUtf8(password);
    final encrypter = Encrypter(Salsa20(key));
    //final encrypter = Encrypter(AES(key));
    return encrypter;
  }

  Future<Encrypter> createEncrypterAES() async {
    String password = await getPasswordSecureStorage();
    log('key: $password');
    final key = Key.fromUtf8(password);
    final encrypter = Encrypter(AES(key));
    return encrypter;
  }

  //::::::::::::::::: Data Encryption Method :::::::::::::::::
  Future<String> encryptData({required String textToEncrypt}) async {
    Encrypter encrypter = await createEncrypter();
    final iv = IV.fromLength(8);

    final encrypted = encrypter.encrypt(textToEncrypt, iv: iv);
    log('Bytes Encryption: ${encrypted.bytes}');
    log('Base16 Encryption: ${encrypted.base16}');
    log('Base64 Encryption: ${encrypted.base64}');
    log('HashCode Encryption: ${encrypted.hashCode}');
    log('RuntimeType Encryption: ${encrypted.runtimeType}');
    return encrypted.base64;
  }

  Future<String> encryptDataAES({required String textToEncrypt}) async {
    Encrypter encrypter = await createEncrypter();
    final iv = IV.fromLength(16);

    final encrypted = encrypter.encrypt(textToEncrypt, iv: iv);
    // log('Bytes Encryption: ${encrypted.bytes}');
    // log('Base16 Encryption: ${encrypted.base16}');
    log('Base64 Encryption: ${encrypted.base64}');
    //log('HashCode Encryption: ${encrypted.hashCode}');
    //log('RuntimeType Encryption: ${encrypted.runtimeType}');
    return encrypted.base64;
  }

  //::::::::::::::::: Data Decryption Method :::::::::::::::::
  Future<String> dencryptData({required String textToDencrypt}) async {
    Encrypter encrypter = await createEncrypter();
    final iv = IV.fromLength(8);

    final decryptedData =
        encrypter.decrypt(Encrypted.from64(textToDencrypt), iv: iv);
    log('Decryption: $decryptedData');
    return decryptedData;
  }

  Future<String> dencryptDataAES({required String textToDencrypt}) async {
    Encrypter encrypter = await createEncrypter();
    final iv = IV.fromLength(16);

    final decryptedData =
        encrypter.decrypt(Encrypted.from64(textToDencrypt), iv: iv);
    log('Decryption: $decryptedData');
    return decryptedData;
  }
}
