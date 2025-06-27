import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:dart_des/dart_des.dart';
import 'package:pointycastle/export.dart';

// Máscara para variante de PIN
final _pekMask = BigInt.parse("FF00000000000000FF", radix: 16);
// Máscara para variante de datos
final _dekMask = BigInt.parse("FF00000000000000FF0000", radix: 16);
// Máscara para variante de MAC
//final _macMask = BigInt.parse("FF00000000000000FF00", radix: 16);

final _keyMask = BigInt.parse("C0C0C0C000000000C0C0C0C000000000", radix: 16);
final _reg8Mask = BigInt.parse("FFFFFFFFFFE00000", radix: 16);
final _reg3Mask = BigInt.parse("1FFFFF", radix: 16);
final _ls16Mask = BigInt.parse("FFFFFFFFFFFFFFFF", radix: 16);
final _ms16Mask = BigInt.parse("FFFFFFFFFFFFFFFF0000000000000000", radix: 16);

/// Permite calcular la llave de sesión para encriptar datos bajo DUKPT
///
/// Se requiere el valor de la [ipek] (Initial PIN Encryption Key) y el [ksn]
/// actual para obtener el valor correcto
Uint8List dukptDeriveDataKey(Uint8List ipek, Uint8List ksn) {
  BigInt derived = _deriveKey(ipek.toBigInt(), ksn.toBigInt()) ^ _dekMask;

  final derivedBytes = derived.toHexBytes();
  final left = derivedBytes.sublist(0, 8);
  final right = derivedBytes.sublist(8, 16);

  final des = DES3(
    key: derivedBytes,
    mode: DESMode.CBC,
    paddingType: DESPaddingType.None,
  );
  final leftEncrypted = Uint8List.fromList(des.encrypt(left));
  final rightEncrypted = Uint8List.fromList(des.encrypt(right));

  return Uint8List.fromList(leftEncrypted + rightEncrypted);
}

/// Permite calcular la llave de sesión que encripta un PIN block bajo DUKPT
///
/// Se requiere el valor de la [ipek] (Initial PIN Encryption Key) y el [ksn]
/// actual para obtener el valor correcto
Uint8List dukptDerivePinKey(Uint8List ipek, Uint8List ksn) {
  BigInt result = _deriveKey(ipek.toBigInt(), ksn.toBigInt()) ^ _pekMask;
  return result.toHexBytes();
}

// Dejo la implementación para MAC como referencia futura por si llega a ser
// necesaria pero no tengo como probarla así que queda comentada
//Uint8List dukptDeriveMacKey(Uint8List ipek, Uint8List ksn) {
//  BigInt result = _deriveKey(ipek.toBigInt(), ksn.toBigInt()) ^ _macMask;
//  return result.toHexBytes();
//}

BigInt _deriveKey(BigInt ipek, BigInt ksn) {
  var ksnReg = ksn & _reg8Mask;
  var curKey = ipek;
  for (var shiftReg = 0x100000; shiftReg > 0; shiftReg >>= 1) {
    if ((BigInt.from(shiftReg) & ksn & _reg3Mask) > BigInt.zero) {
      curKey = _generateKey(curKey, ksnReg |= BigInt.from(shiftReg));
    }
  }
  return curKey;
}

BigInt _generateKey(BigInt key, BigInt ksn) {
  return _encryptRegister(key ^ _keyMask, ksn) << 64 |
      _encryptRegister(key, ksn);
}

BigInt _encryptRegister(BigInt key, BigInt reg) {
  return (key & _ls16Mask) ^
      _desEncrypt(
        (key & _ms16Mask) >> 64,
        key & _ls16Mask ^ reg,
      );
}

BigInt _desEncrypt(BigInt key, BigInt msg) {
  // importante paddear estas conversiones de BigInt a Uint8List con el tamaño
  // correcto de bloque
  final keyBytes = key.toHexBytes().padBlockLeft(8, 0x00);
  final msgBytes = msg.toHexBytes().padBlockRight(8, 0x00);
  DES des = DES(
    key: keyBytes,
    mode: DESMode.CBC,
    iv: DES.IV_ZEROS,
    paddingType: DESPaddingType.None,
  );
  final resultBytes = Uint8List.fromList(des.encrypt(msgBytes));
  return resultBytes.toBigInt();
}

Uint8List aesECBEncrypt(Uint8List key, Uint8List data, bool encrypt) {
  final ecb = ECBBlockCipher(AESEngine())
    ..init(encrypt, DESedeParameters(key));
  
  final cipherText = Uint8List(data.length);
  var offset = 0;

  while (offset < data.length) {
    offset += ecb.processBlock(data, offset, cipherText, offset);
  }
  assert(offset == data.length);

  return cipherText;
}

Uint8List aesCBCEncrypt(Uint8List key,Uint8List iv , Uint8List data) {
  assert([128, 192, 256].contains(key.length * 8));
  assert (128 == iv.length * 8);
  assert(128 == data.length * 8);

  final cbc = CBCBlockCipher(AESEngine())
    ..init(true, ParametersWithIV(KeyParameter(key), iv)); // true=encrypt

  //Encriptando la data bloque a bloque
  final cipherText = Uint8List(data.length);

  var offset = 0;
  while (offset < data.length) {
    offset += cbc.processBlock(data, offset, cipherText, offset);
  }
  assert(offset == data.length);

  return cbc.process(data);
}

Uint8List aesCBCDecrypt(Uint8List key,Uint8List iv , Uint8List data) {
  assert([128, 192, 256].contains(key.length * 8));
  assert (128 == iv.length * 8);
  assert(128 == data.length * 8);

  final cbc = CBCBlockCipher(AESEngine())
    ..init(false, ParametersWithIV(KeyParameter(key), iv)); // false=decrypt
  //Desencriptando la data bloque a bloque
  final plainText = Uint8List(data.length);

  var offset = 0;
  while (offset < data.length) {
    offset += cbc.processBlock(data, offset, plainText, offset);
  }
  assert(offset == data.length);

  return plainText;
}