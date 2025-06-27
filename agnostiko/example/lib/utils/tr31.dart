import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';

import 'package:agnostiko/agnostiko.dart';
import 'package:pointycastle/export.dart';

class TR31 {
  TR31._();

  static final TR31 algorithm = TR31._();

  /// Encodea una llave inicial para AES DUKPT en versión D de TR31
  ///
  /// Se debe incluir el [initialKeyID] para colocarlo en su respectivo bloque
  /// opcional.
  String encodeAESDUKPT(
    Uint8List kbpk,
    Uint8List initialKey,
    Uint8List initialKeyID,
  ) {
    if (initialKeyID.length != 8) {
      throw StateError("initialKeyID must be 8 bytes long");
    }

    final initialKeyIDStr = initialKeyID.toHexStr().toUpperCase();
    final header = const AsciiCodec()
        .encode("D0144B1AX00N0200IK14${initialKeyIDStr}PB0C00000000");

    return _encodeAESDUKPT(kbpk, initialKey, initialKeyID, header);
  }

  /// Encodea llave inicial AES DUKPT en TR31 versión D modificado para Newland
  ///
  /// Se debe incluir el [ksn] para colocarlo en el bloque del initial key ID.
  /// Por alguna razón, así es como funciona en Newland de momento.
  String encodeAESDUKPTNewland(
    Uint8List kbpk,
    Uint8List initialKey,
    Uint8List ksn,
  ) {
    if (ksn.length != 12) {
      throw StateError("ksn must be 12 bytes long");
    }

    final ksnStr = ksn.toHexStr().toUpperCase();
    final header =
        const AsciiCodec().encode("D0144B1AX00N0200IK1C${ksnStr}PB04");

    return _encodeAESDUKPT(kbpk, initialKey, ksn, header);
  }

  String _encodeAESDUKPT(
    Uint8List kbpk,
    Uint8List initialKey,
    Uint8List initialKeyID,
    Uint8List header,
  ) {
    final kbek = _deriveAESKBEK(kbpk);
    final kbak = _deriveAESKBAK(kbpk);

    final keyLen = initialKey.length; // sin ofuscamiento de longitud
    const aesBlockSize = 16; // Tamaño de bloque AES

    final blocksToFill = ((2 + keyLen) % aesBlockSize);
    final payloadLen = blocksToFill * aesBlockSize;

    final keyLenBytes = (initialKey.length * 8)
        .toRadixString(16)
        .padLeft(4, '0')
        .toHexBytes(); // la longitud que se coloca acá es en bits

    final paddingLen = payloadLen - keyLenBytes.length - initialKey.length;
    final random = Random.secure();
    final padding = Uint8List.fromList(
      List<int>.generate(paddingLen, (i) {
        return random.nextInt(128);
      }),
    );

    final payload = Uint8List.fromList(keyLenBytes + initialKey + padding);
    final decodedKeyBlock = Uint8List.fromList(header + payload);

    const authenticatorLen = 16; // siempre 16 para formato D
    final authenticator = Uint8List(authenticatorLen);
    final cmac = CMac(AESEngine(), authenticatorLen * 8)
      ..init(KeyParameter(kbak));
    cmac.update(decodedKeyBlock, 0, decodedKeyBlock.length);
    cmac.doFinal(authenticator, 0);

    final aes = CBCBlockCipher(AESEngine())
      ..init(
        true,
        ParametersWithIV(
          KeyParameter(kbek),
          authenticator,
        ),
      ); // true=encrypt
    final encryptedPayload = Uint8List(payload.length);
    int offset = 0;
    while (offset < payload.length) {
      offset += aes.processBlock(payload, offset, encryptedPayload, offset);
    }

    final headerAscii = const AsciiCodec().decode(header);
    return headerAscii +
        encryptedPayload.toHexStr().toUpperCase() +
        authenticator.toHexStr().toUpperCase();
  }

  Uint8List _deriveAESKBEK(Uint8List kbpk) {
    // derivation data
    final counter = "01".toHexBytes();
    final keyUsage = "0000".toHexBytes(); // Derivation Key Usage Encryption CBC
    final separator = "00".toHexBytes();
    final algorithm = "0002".toHexBytes();
    final keyLen = (kbpk.length * 8)
        .toRadixString(16)
        .padLeft(4, '0')
        .toHexBytes(); // longitud en bits
    final kbxk =
        Uint8List.fromList(counter + keyUsage + separator + algorithm + keyLen);

    final cmac = CMac(AESEngine(), 128)..init(KeyParameter(kbpk));

    final kbek = cmac.process(kbxk);
    return kbek;
  }

  Uint8List _deriveAESKBAK(Uint8List kbpk) {
    // derivation data
    final counter = "01".toHexBytes();
    final keyUsage = "0001".toHexBytes(); // Derivation Key Usage MAC
    final separator = "00".toHexBytes();
    final algorithm = "0002".toHexBytes();
    final keyLen = (kbpk.length * 8)
        .toRadixString(16)
        .padLeft(4, '0')
        .toHexBytes(); // longitud en bits
    final kbxk =
        Uint8List.fromList(counter + keyUsage + separator + algorithm + keyLen);

    final cmac = CMac(AESEngine(), 128)..init(KeyParameter(kbpk));

    final kbak = cmac.process(kbxk);
    return kbak;
  }
}
