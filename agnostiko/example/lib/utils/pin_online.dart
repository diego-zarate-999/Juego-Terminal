import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:dart_des/dart_des.dart';
import 'package:pointycastle/export.dart';

class Iso9564 {
  static const format0 = _Format0();
  static const format4 = _Format4();
}

class _Format0 {
  const _Format0();

  // Extrae el valor de PIN de un bloque ISO9564 Formato 0 encriptado con TDES
  String extractPIN(Uint8List pinKey, Uint8List encryptedPinBlock, String pan) {
    if (encryptedPinBlock.length != 8) {
      throw StateError("pin block length must be 8 bytes");
    }

    DES3 pinDes = DES3(key: pinKey, mode: DESMode.ECB);
    final clearPinBlock = Uint8List.fromList(pinDes.decrypt(encryptedPinBlock));
    if (clearPinBlock.length != 8) {
      throw StateError("clear pin block length must be 8 bytes");
    }

    final panField = _generatePANField(pan);
    final pinField = Uint8List(8);
    for (var i = 0; i < 8; i++) {
      pinField[i] = clearPinBlock[i] ^ panField[i];
    }
    return _extractPINFromPINField(pinField);
  }

  Uint8List _generatePANField(String pan) {
    if (pan.length < 13 || pan.length > 19) {
      throw StateError("invalid PAN length");
    }
    final panDigits = pan.substring(pan.length - 13, pan.length - 1);
    final panFieldStr = "0000$panDigits";
    return panFieldStr.toHexBytes();
  }

  String _extractPINFromPINField(Uint8List pinField) {
    final fieldStr = pinField.toHexStr();
    final pinLen = int.parse(fieldStr[1], radix: 16);
    return fieldStr.substring(2, 2 + pinLen);
  }
}

class _Format4 {
  const _Format4();

  // Extrae el valor de PIN de un bloque ISO9564 Formato 4 encriptado con AES
  String extractPIN(
    Uint8List pinKey,
    Uint8List encipheredPinBlock,
    String pan,
  ) {
    if (encipheredPinBlock.length != 16) {
      throw StateError("pin block length must be 8 bytes");
    }
    final intermediateBlockB = _aesECBDecrypt(pinKey, encipheredPinBlock);

    final panField = _generatePANField(pan);

    final intermediateBlockA = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      intermediateBlockA[i] = intermediateBlockB[i] ^ panField[i];
    }

    final pinField = _aesECBDecrypt(pinKey, intermediateBlockA);
    return _extractPINFromPINField(pinField);
  }

  String _extractPINFromPINField(Uint8List pinField) {
    final fieldStr = pinField.toHexStr();
    final pinLen = int.parse(fieldStr[1], radix: 16);
    return fieldStr.substring(2, 2 + pinLen);
  }

  Uint8List _aesECBDecrypt(Uint8List key, Uint8List data) {
    assert([128, 192, 256].contains(key.length * 8));
    assert(128 == data.length * 8);

    final ecb = ECBBlockCipher(AESEngine())
      ..init(false, DESedeParameters(key)); // false=decrypt
    return ecb.process(data);
  }

  Uint8List _generatePANField(String pan) {
    if (pan.length < 13 || pan.length > 19) {
      throw StateError("invalid PAN length");
    }
    // según el estándar, el primer digito de este campo indica una longitud de
    // PAN de 12 + el valor de este digito
    final firstDigit = pan.length - 12;
    final panFieldStr = "$firstDigit$pan".padRight(32, "0");
    return panFieldStr.toHexBytes();
  }
}
