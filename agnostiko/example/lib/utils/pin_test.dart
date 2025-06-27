import 'dart:convert';
import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:agnostiko_example/utils/rsa.dart';
import 'package:agnostiko_example/utils/tr31.dart';

import '../config/app_keys.dart';

import 'log_test.dart';

class PinOnlineTest {
  static final des = _DES();
  static final aes = _AES();
  static final banorte = _Banorte();
}

class _DES {
  final loadKeysSet = [
    LogTest("Load Fixed Key", _loadTR31DESFixedKey),
    LogTest("Load DUKPT Key", _loadTR31DESDUKPTKey),
  ];
  final deleteKeysSet = [
    LogTest("Delete Fixed Key", _deleteTR31DESFixedKey),
    LogTest("Delete DUKPT Key", _deleteTR31DESDUKPTKey),
  ];
}

Future<LogTestResult> _loadTR31DESFixedKey() async {
  await cryptoTR31LoadKey(AppKeys.des.pinTR31Fixed, AppKeys.des.tr31KEK);
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinTR31Fixed);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _loadTR31DESDUKPTKey() async {
  await cryptoTR31LoadKey(AppKeys.des.pinTR31DUKPT, AppKeys.des.tr31KEK);
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinTR31DUKPT);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _deleteTR31DESFixedKey() async {
  await cryptoPINDeleteKey(AppKeys.des.pinTR31Fixed);
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinTR31Fixed);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _deleteTR31DESDUKPTKey() async {
  await cryptoPINDeleteKey(AppKeys.des.pinTR31DUKPT);
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinTR31DUKPT);
  return LogTestResult(!keyExists);
}

class _AES {
  final loadKeysSet = [
    LogTest("Load Fixed Key", _loadTR31AESFixedKey),
    LogTest("Load DUKPT Key", _loadTR31AESDUKPTKey),
  ];
  final deleteKeysSet = [
    LogTest("Delete Fixed Key", _deleteTR31AESFixedKey),
    LogTest("Delete DUKPT Key", _deleteTR31AESDUKPTKey),
  ];
}

Future<LogTestResult> _loadTR31AESFixedKey() async {
  await cryptoTR31LoadKey(AppKeys.aes.pinTR31Fixed, AppKeys.aes.tr31KEK128);
  final keyExists = await cryptoPINCheckKey(AppKeys.aes.pinTR31Fixed);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _loadTR31AESDUKPTKey() async {
  await cryptoTR31LoadKey(AppKeys.aes.pinTR31DUKPT, AppKeys.aes.tr31KEK128);
  final keyExists = await cryptoPINCheckKey(AppKeys.aes.pinTR31DUKPT);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _deleteTR31AESFixedKey() async {
  await cryptoPINDeleteKey(AppKeys.aes.pinTR31Fixed);
  final keyExists = await cryptoPINCheckKey(AppKeys.aes.pinTR31Fixed);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _deleteTR31AESDUKPTKey() async {
  await cryptoPINDeleteKey(AppKeys.aes.pinTR31DUKPT);
  final keyExists = await cryptoPINCheckKey(AppKeys.aes.pinTR31DUKPT);
  return LogTestResult(!keyExists);
}

/// Flujo para Banorte usando PinOnline
/// 
/// Con llave de pin TR31
class _Banorte {
  final loadKeysSet = [
    LogTest("Load RSA Key", _generatePINAsymKey),
  ];
  final deleteKeysSet = [
    LogTest("Delete RSA Key", _deletePINAsymKey),
  ];
}
Future<LogTestResult> _generatePINAsymKey() async {
  final Uint8List initialKey = generateRandomDESKey(16);
  final result = await tr31Encoder(initialKey);

  await cryptoTR31LoadKey(result, AppKeys.aes.pinTR31RSA);
  final keyExists = await cryptoPINCheckKey(AppKeys.aes.llavePinOnlineBanorte);
  
  BanorteKeys.instance.setInitialKey(initialKey);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _deletePINAsymKey() async {
  await cryptoPINDeleteKey(AppKeys.aes.llavePinOnlineBanorte);
  final keyExists = await cryptoPINCheckKey(AppKeys.aes.llavePinOnlineBanorte);
  return LogTestResult(!keyExists);
}
Future<SymmetricKey> tr31Encoder(Uint8List initialKey) async {
  final kbpk = await generateKeyWithAsymKey(AppKeys.rsa.distributionKey, AppKeys.aes.pinTR31RSA);
  String path = 'assets/ca/banorteTest.pem';
  String name = 'banorteTest.pem';
  final decryptedData = await rsaDecryptResult(kbpk, path, name);

  final encoder = TR31.algorithm;
  final result = encoder.encodeAESDUKPTNewland(decryptedData.toHexBytes(), initialKey, AppKeys.aes.ksn);

  final rsaSymTR31 = DUKPTKey(
    type: KeyType.AES,
    index: 22,
    data: const AsciiCodec().encode(result),
    ksn: "FFFF77901696738000000001".toHexBytes()
  );
  
  return rsaSymTR31;
}