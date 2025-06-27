import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:dart_des/dart_des.dart';

import '../config/app_keys.dart';
import '../utils/aes_dukpt.dart';
import '../utils/dukpt.dart';
import '../utils/rsa.dart';

import 'log_test.dart';

final loadKeysTestSet = [
  LogTest("Load Fixed Data Key", _loadSymmetricDataKey),
  LogTest("Load DUKPT Data Key", _loadDUKPTDataKey),
  LogTest("Load Fixed PIN Key", _loadSymmetricPinKey),
  LogTest("Load DUKPT PIN Key", _loadDUKPTPinKey),
];
final encryptionTestSet = [
  LogTest("Fixed ECB Encryption", _fixedECBEncryption),
  LogTest("Fixed CBC Encryption", _fixedCBCEncryption),
  LogTest("DUKPT ECB Encryption", _dukptECBEncryption),
  LogTest("DUKPT CBC Encryption", _dukptCBCEncryption),
];
final decryptionTestSet = [
  LogTest("Fixed ECB Decryption", _fixedECBDecryption),
  LogTest("Fixed CBC Decryption", _fixedCBCDecryption),
  LogTest("DUKPT ECB Decryption", _dukptECBDecryption),
  LogTest("DUKPT CBC Decryption", _dukptCBCDecryption),
];
final deleteKeysTestSet = [
  LogTest("Delete Fixed Data Key", _deleteSymmetricDataKey),
  LogTest("Delete DUKPT Data Key", _deleteDUKPTDataKey),
  LogTest("Delete Fixed PIN Key", _deleteSymmetricPinKey),
  LogTest("Delete DUKPT PIN Key", _deleteDUKPTPinKey),
];
final loadAESKeysTestSet = [
  LogTest("Load AES Data Key", _loadAESDataKey),
  LogTest("Load AES DUKPT Key", _loadAESDUKPTDataKey),
];
final encryptionAESTestSet = [
  LogTest("Fixed AES Encryption", _fixedAESEncryption),
  LogTest("DUKPT AES Encryption", _dukptAESEncryption),
];
final decryptionAESTestSet = [
  LogTest("Fixed AES Decryption", _fixedAESDecryption),
  LogTest("DUKPT AES Decryption", _dukptAESDecryption),
];
final deleteAESKeysTestSet = [
  LogTest("Delete AES Data Key", _deleteAESDataKey),
  LogTest("Delete AES DUKPT Key", _deleteAESDUKPTDataKey),
];
final loadRSAKeyWithAsymKeySet = [
  LogTest("Load RSA Key With AsymKey", _generateKeyWithAsymKey)
];

Future<LogTestResult> _loadSymmetricDataKey() async {
  await cryptoDataLoadKey(
    AppKeys.des.testDataFixed,
    kek: AppKeys.des.kek,
    algorithmParameters: AppKeys.des.testDataFixedParams,
  );
  final keyExists = await cryptoDataCheckKey(AppKeys.des.testDataFixed);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _loadSymmetricPinKey() async {
  await cryptoPINLoadKey(
    AppKeys.des.pinFixed,
    kek: AppKeys.des.kek,
    algorithmParameters: AppKeys.des.pinFixedParams,
  );
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinFixed);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _loadDUKPTDataKey() async {
  await cryptoDataLoadKey(AppKeys.des.testDataDUKPT, kek: AppKeys.des.kek);
  final keyExists = await cryptoDataCheckKey(AppKeys.des.testDataDUKPT);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _loadDUKPTPinKey() async {
  await cryptoPINLoadKey(AppKeys.des.pinDUKPT, kek: AppKeys.des.kek);
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinDUKPT);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _loadAESDataKey() async {
  await cryptoDataLoadKey(AppKeys.aes.testDataFixed,
      kek: AppKeys.aes.kek128,
      algorithmParameters: AppKeys.aes.testDataFixedParams);
  final keyExists = await cryptoDataCheckKey(AppKeys.aes.testDataFixed);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _loadAESDUKPTDataKey() async {
  await cryptoDataLoadKey(AppKeys.aes.testDataDUKPT,
      // se está utilizando en claro por PAX
      //kek: AppKeys.aes.kek128,
      algorithmParameters: AppKeys.aes.testDataDUKPTParams);
  final keyExists = await cryptoDataCheckKey(AppKeys.aes.testDataDUKPT);
  return LogTestResult(keyExists);
}

Future<LogTestResult> _fixedECBEncryption() async {
  final clearData = "EC09B15E494945CB".toHexBytes();
  const expectedResult = "109FADB0C01EC98C";
  final params = AlgorithmParameters(cipherMode: CipherMode.ECB);

  final cryptoResult = await cryptoDataEncrypt(
    AppKeys.des.testDataFixed,
    clearData,
    params,
  );
  final comparationResult =
      cryptoResult.data.toHexStr().toUpperCase() == expectedResult;
  return LogTestResult(comparationResult);
}

Future<LogTestResult> _fixedCBCEncryption() async {
  final clearData =
      "9E76ABA443E67C64FB5BBA432C4F7F45D5644A913D6452763DD5B926ECB9E602"
          .toHexBytes();
  const expectedResult =
      "2E21AB09412714CACE6341331AFB4BB9A4F6E3943D8BEB36FF4AAF441037545D";
  final params = AlgorithmParameters(
    cipherMode: CipherMode.CBC,
    iv: "64FEAA7C5DF63C75".toHexBytes(),
  );

  final cryptoResult = await cryptoDataEncrypt(
    AppKeys.des.testDataFixed,
    clearData,
    params,
  );
  final comparationResult =
      cryptoResult.data.toHexStr().toUpperCase() == expectedResult;
  return LogTestResult(comparationResult);
}

Future<LogTestResult> _dukptECBEncryption() async {
  final params = AlgorithmParameters(cipherMode: CipherMode.ECB);
  final result = await _dukptEncrypt("EC09B15E494945CB".toHexBytes(), params);
  return LogTestResult(result);
}

Future<LogTestResult> _dukptCBCEncryption() async {
  final data =
      "9E76ABA443E67C64FB5BBA432C4F7F45D5644A913D6452763DD5B926ECB9E602"
          .toHexBytes();
  final params = AlgorithmParameters(
    cipherMode: CipherMode.CBC,
    iv: "64FEAA7C5DF63C75".toHexBytes(),
  );
  final result = await _dukptEncrypt(data, params);
  return LogTestResult(result);
}

Future<LogTestResult> _fixedAESEncryption() async {
  final clearData =
      "9DADE0679E1631AD85BCDC29580D081A1968CD3D0DF7D0D62FC25BF8BF5202370EE5541A9815EA79A13107A180926BD3"
          .toHexBytes();
  const expectedResult =
      "A5CE364E5533A08DD75ABD1E230AAD14F4B3917435611075E461E772ED9AC88DED6F213599950F4D90292F3A13FFF2FD";
  final params = AlgorithmParameters(
    cipherMode: CipherMode.CBC,
    iv: "A7D6855B436197B5D09D2CCE7583A1BF".toHexBytes(),
  );

  final cryptoResult = await cryptoDataEncrypt(
    AppKeys.aes.testDataFixed,
    clearData,
    params,
  );
  final comparationResult =
      cryptoResult.data.toHexStr().toUpperCase() == expectedResult;
  return LogTestResult(comparationResult);
}

Future<LogTestResult> _dukptAESEncryption() async {
  final data =
      "9DADE0679E1631AD85BCDC29580D081A1968CD3D0DF7D0D62FC25BF8BF5202370EE5541A9815EA79A13107A180926BD3"
          .toHexBytes();
  final params = AlgorithmParameters(
    cipherMode: CipherMode.ECB,
  );
  final result = await _dukptEncryptAES(
    AppKeys.aes.testDataDUKPTClear,
    params,
    data,
  );
  return LogTestResult(result);
}

/// Este método lo utilizamos para ECB y CBC por igual ya que solo varían la
/// data y los parámetros
Future<bool> _dukptEncrypt(Uint8List data, AlgorithmParameters params) async {
  final key = AppKeys.des.testDataDUKPTClear;

  // arrancamos con el KSN actual y su resultado calculado dinámicamente
  final ksn01Result = await _getCurrentKSNResult(true, key, params, data);
  var cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01Result) return false;

  // El KSN no debería haber aumentado y debería dar el mismo resultado otra vez
  cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01Result) return false;

  // Aumento de KSN
  await cryptoIncrementKSN(key);
  final ksn02Result = await _getCurrentKSNResult(true, key, params, data);
  cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn02Result) return false;

  // Incrementamos el KSN 5 veces
  for (int i = 0; i < 5; i++) {
    await cryptoIncrementKSN(key);
  }

  // Y verificamos un último resultado
  final ksnEndResult = await _getCurrentKSNResult(true, key, params, data);
  cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksnEndResult) return false;

  return true;
}

/// Implementando método para encriptar con DUKPT
///
/// Se necesita [clearKey] como la definición de la llave con el valor en claro
/// los parámetros para algoritmos de encripción, [params] debe decir si es ECB o CBC(con IV),
/// y por último la [data] para encriptar/desencriptar.

Future<bool> _dukptEncryptAES(
  DUKPTKey key,
  AlgorithmParameters params,
  Uint8List data,
) async {
  final ksn01 = await _getCurrentKSNResultAES(true, key, params, data);
  var cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01) return false;

  // El KSN no debería haber aumentado y debería dar el mismo resultado otra vez
  cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01) return false;

  // Aumento de KSN
  await cryptoIncrementKSN(key);
  final ksn02 = await _getCurrentKSNResultAES(true, key, params, data);
  cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn02) return false;

  // Incrementamos el KSN 5 veces
  for (int i = 0; i < 5; i++) {
    await cryptoIncrementKSN(key);
  }
  // Y verificamos un último resultado
  final ksnEnd = await _getCurrentKSNResultAES(true, key, params, data);
  cryptoResult = await cryptoDataEncrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksnEnd) return false;

  return true;
}

/// Permite precalcular el resultado para el KSN actual de la llave para poder
/// así comparar contra el resultado del módulo seguro
///
/// Si [encrypt] es [true], se encripta y si es [false] se desencripta la data.
///
/// Se necesita [clearKey] como la definición de la llave con el valor en claro
/// la versión en claro de la IPEK, [params] debe decir si es ECB o CBC(con IV),
/// y por último la [data] para encriptar/desencriptar y sacar el resultado.
Future<String> _getCurrentKSNResult(
  bool encrypt,
  DUKPTKey clearKey,
  AlgorithmParameters params,
  Uint8List data,
) async {
  final currentKSN = await cryptoGetKSN(clearKey);
  final keyData = clearKey.data;
  if (keyData == null) {
    throw StateError("missing clear key data");
  }

  // obtenemos la llave derivada para el KSN actual
  final derivKey = dukptDeriveDataKey(keyData, currentKSN);

  // parametrizamos y encriptamos con 3DES
  DESMode desMode;
  List<int> iv = DES.IV_ZEROS;
  DESPaddingType padding = DESPaddingType.None;
  switch (params.cipherMode) {
    case CipherMode.ECB:
      desMode = DESMode.ECB;
      break;
    case CipherMode.CBC:
      desMode = DESMode.CBC;
      iv = params.iv ?? DES.IV_ZEROS;
      break;
  }
  final des = DES3(key: derivKey, mode: desMode, iv: iv, paddingType: padding);

  // encriptamos o desencriptamos según el flag
  final result = encrypt ? des.encrypt(data) : des.decrypt(data);

  // el resultado final es el hex del resultado criptográfico para el KSN actual
  return Uint8List.fromList(result).toHexStr().toUpperCase();
}

Future<String> _getCurrentKSNResultAES(
  bool encrypt,
  DUKPTKey clearKey,
  AlgorithmParameters params,
  Uint8List data,
) async {
  final currentKSN = await cryptoGetKSN(clearKey);

  final DerivationKeyUsage derivationKeyUsage = encrypt
      ? DerivationKeyUsage.DataEncryptionEncrypt
      : DerivationKeyUsage.DataEncryptionDecrypt;

  final keyData = clearKey.data;
  if (keyData == null) {
    throw StateError("missing clear key data");
  }

  // derivamos la llave de trabajo para el KSN actual
  final currentWorkingKey = AESDUKPT.algorithm.deriveWorkingKey(
    keyData,
    currentKSN,
    DerivationKeyType.AES128,
    derivationKeyUsage,
    DerivationKeyType.AES128,
  );

  // el resultado final es el hex del resultado criptográfico para el KSN actual
  final result = aesECBEncrypt(currentWorkingKey, data, encrypt);
  return result.toHexStr().toUpperCase();
}

Future<LogTestResult> _fixedECBDecryption() async {
  const expectedResult = "340131E2FDAC4339";
  final encryptedData = "9E76ABA443E67C64".toHexBytes();
  final key = AppKeys.des.testDataFixed;
  final params = AlgorithmParameters(cipherMode: CipherMode.ECB);

  final cryptoResult = await cryptoDataDecrypt(key, encryptedData, params);
  final result = cryptoResult.data.toHexStr().toUpperCase() == expectedResult;
  return LogTestResult(result);
}

Future<LogTestResult> _fixedCBCDecryption() async {
  const expectedResult =
      "50FF9B9EA05A7F4CBC9ED3D78B6A08FB103695E1557DBF7EE58A559990443774";
  final encryptedData =
      "9E76ABA443E67C64FB5BBA432C4F7F45D5644A913D6452763DD5B926ECB9E602"
          .toHexBytes();
  final key = AppKeys.des.testDataFixed;
  final params = AlgorithmParameters(
    cipherMode: CipherMode.CBC,
    iv: "64FEAA7C5DF63C75".toHexBytes(),
  );

  final cryptoResult = await cryptoDataDecrypt(key, encryptedData, params);
  final result = cryptoResult.data.toHexStr().toUpperCase() == expectedResult;
  return LogTestResult(result);
}

Future<LogTestResult> _dukptECBDecryption() async {
  final params = AlgorithmParameters(cipherMode: CipherMode.ECB);
  final result = await _dukptDecrypt("64FEAA7C5DF63C75".toHexBytes(), params);
  return LogTestResult(result);
}

Future<LogTestResult> _dukptCBCDecryption() async {
  final data =
      "9E76ABA443E67C64FB5BBA432C4F7F45D5644A913D6452763DD5B926ECB9E602"
          .toHexBytes();
  final params = AlgorithmParameters(
    cipherMode: CipherMode.CBC,
    iv: "64FEAA7C5DF63C75".toHexBytes(),
  );
  final result = await _dukptDecrypt(data, params);
  return LogTestResult(result);
}

Future<LogTestResult> _fixedAESDecryption() async {
  const expectedResult =
      "9DADE0679E1631AD85BCDC29580D081A1968CD3D0DF7D0D62FC25BF8BF5202370EE5541A9815EA79A13107A180926BD3";
  final encryptedData =
      "A5CE364E5533A08DD75ABD1E230AAD14F4B3917435611075E461E772ED9AC88DED6F213599950F4D90292F3A13FFF2FD"
          .toHexBytes();
  final key = AppKeys.aes.testDataFixed;
  final params = AlgorithmParameters(
    cipherMode: CipherMode.CBC,
    iv: "A7D6855B436197B5D09D2CCE7583A1BF".toHexBytes(),
  );

  final cryptoResult = await cryptoDataDecrypt(key, encryptedData, params);
  final result = cryptoResult.data.toHexStr().toUpperCase() == expectedResult;
  return LogTestResult(result);
}

Future<LogTestResult> _dukptAESDecryption() async {
  final data =
      "9DADE0679E1631AD85BCDC29580D081A1968CD3D0DF7D0D62FC25BF8BF5202370EE5541A9815EA79A13107A180926BD3"
          .toHexBytes();
  final params = AlgorithmParameters(
    cipherMode: CipherMode.ECB,
  );
  final result = await _dukptDecryptAES(
    AppKeys.aes.testDataDUKPTClear,
    params,
    data,
  );
  return LogTestResult(result);
}

/// Este método lo utilizamos para ECB y CBC por igual ya que solo varían la
/// data y los parámetros
Future<bool> _dukptDecrypt(Uint8List data, AlgorithmParameters params) async {
  final key = AppKeys.des.testDataDUKPTClear;

  // arrancamos con el KSN actual y su resultado calculado dinámicamente
  final ksn01Result = await _getCurrentKSNResult(false, key, params, data);
  var cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01Result) return false;

  // El KSN no debería haber aumentado y debería dar el mismo resultado otra vez
  cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01Result) return false;

  // Aumento de KSN
  await cryptoIncrementKSN(key);
  final ksn02Result = await _getCurrentKSNResult(false, key, params, data);
  cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn02Result) return false;

  // Incrementamos el KSN 5 veces
  for (int i = 0; i < 5; i++) {
    await cryptoIncrementKSN(key);
  }

  // Y verificamos un último resultado
  final ksnEndResult = await _getCurrentKSNResult(false, key, params, data);
  cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksnEndResult) return false;

  return true;
}

Future<bool> _dukptDecryptAES(
  DUKPTKey key,
  AlgorithmParameters params,
  Uint8List data,
) async {
  final ksn01Result = await _getCurrentKSNResultAES(false, key, params, data);
  var cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01Result) return false;

  // El KSN no debería haber aumentado y debería dar el mismo resultado otra vez
  cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn01Result) return false;

  // Aumento de KSN
  await cryptoIncrementKSN(key);
  final ksn02Result = await _getCurrentKSNResultAES(false, key, params, data);
  cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksn02Result) return false;
  // Incrementamos el KSN 5 veces
  for (int i = 0; i < 5; i++) {
    await cryptoIncrementKSN(key);
  }
  final ksnEndResult = await _getCurrentKSNResultAES(false, key, params, data);
  cryptoResult = await cryptoDataDecrypt(key, data, params);
  if (cryptoResult.data.toHexStr().toUpperCase() != ksnEndResult) return false;

  return true;
}

Future<LogTestResult> _deleteSymmetricDataKey() async {
  await cryptoDataDeleteKey(AppKeys.des.testDataFixed);
  final keyExists = await cryptoDataCheckKey(AppKeys.des.testDataFixed);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _deleteSymmetricPinKey() async {
  await cryptoPINDeleteKey(AppKeys.des.pinFixed);
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinFixed);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _deleteDUKPTDataKey() async {
  await cryptoDataDeleteKey(AppKeys.des.testDataDUKPT);
  final keyExists = await cryptoDataCheckKey(AppKeys.des.testDataDUKPT);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _deleteDUKPTPinKey() async {
  await cryptoPINDeleteKey(AppKeys.des.pinDUKPT);
  final keyExists = await cryptoPINCheckKey(AppKeys.des.pinDUKPT);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _deleteAESDataKey() async {
  await cryptoDataDeleteKey(AppKeys.aes.testDataFixed);
  final keyExists = await cryptoDataCheckKey(AppKeys.aes.testDataFixed);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _deleteAESDUKPTDataKey() async {
  await cryptoDataDeleteKey(AppKeys.aes.testDataDUKPT);
  final keyExists = await cryptoDataCheckKey(AppKeys.aes.testDataDUKPT);
  return LogTestResult(!keyExists);
}

Future<LogTestResult> _generateKeyWithAsymKey() async {
  var result = await generateKeyWithAsymKey(AppKeys.rsa.distributionKey, AppKeys.aes.pinTR31RSA);
  String path = 'assets/ca/banorteTest.pem';
  String name = 'banorteTest.pem';
  final decryptedData = await rsaDecryptResult(result, path, name);
  return LogTestResult(result.toHexStr() == decryptedData);
}
