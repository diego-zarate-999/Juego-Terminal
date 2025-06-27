import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:pointycastle/export.dart';

/// Identifica si una derivación AES DUKPT es para crear una llave inicial o
/// algún otro tipo de llave de trabajo soportado
enum DerivationPurpose {
  InitialKey,
  DerivationOrWorkingKey,
}

/// Define los posibles uso de llaves AES DUKPT que se pueden derivar
enum DerivationKeyUsage {
  KeyEncryptionKey,
  PINEncryption,
  MessageAuthenticationGeneration,
  MessageAuthenticationVerification,
  MessageAuthenticationBothWays,
  DataEncryptionEncrypt,
  DataEncryptionDecrypt,
  DataEncryptionBothWays,
  KeyDerivation,
  KeyDerivationInitialKey,
}

/// Para AES DUKPT, define el tipo de llave criptográfica a derivar
enum DerivationKeyType {
  _2TDEA,
  _3TDEA,
  AES128,
  AES192,
  AES256,
}

/// Implementación de AES DUKPT basada en el estándar ANSI X9.24-3-2017
class AESDUKPT {
  const AESDUKPT._();

  static const AESDUKPT algorithm = AESDUKPT._();

  /// Deriva una llave de trabajo AES DUKPT con la [initialKey] y el [ksn]
  ///
  /// Implementación basada en el estándar AES X9.24-3-2017
  Uint8List deriveWorkingKey(
    Uint8List initialKey,
    Uint8List ksn,
    DerivationKeyType deriveKeyType,
    DerivationKeyUsage workingKeyUsage,
    DerivationKeyType workingKeyType,
  ) {
    Uint8List initialKeyID = ksn.sublist(0, 8);
    Uint8List transactionCounterBytes = ksn.sublist(8, 12);
    int transactionCounter = transactionCounterBytes.toBigInt().toInt();

    // set the most significant bit to one and all other bits to zero
    int mask = 0x80000000;
    int workingCounter = 0;
    Uint8List derivationKey = initialKey;

    // calculate current derivation key from initial key
    while (mask > 0) {
      if ((mask & transactionCounter) != 0) {
        workingCounter = workingCounter | mask;
        final derivationData = _createDerivationData(
          DerivationPurpose.DerivationOrWorkingKey,
          DerivationKeyUsage.KeyDerivation,
          deriveKeyType,
          initialKeyID,
          workingCounter,
        );
        derivationKey = _deriveKey(
          derivationKey,
          deriveKeyType,
          derivationData,
        );
      }
      mask = mask >> 1;
    }

    // derive working key from current derivation key
    final derivationData = _createDerivationData(
      DerivationPurpose.DerivationOrWorkingKey,
      workingKeyUsage,
      workingKeyType,
      initialKeyID,
      transactionCounter,
    );
    final workingKey = _deriveKey(
      derivationKey,
      workingKeyType,
      derivationData,
    );
    return workingKey;
  }

  Uint8List _createDerivationData(
    DerivationPurpose derivationPurpose,
    DerivationKeyUsage keyUsage,
    DerivationKeyType keyType,
    Uint8List initialKeyID,
    int counter,
  ) {
    Uint8List derivationData = Uint8List(8);

    // Set Version ID of the table structure.
    derivationData[0] = 0x01; // version 1

    // set Key Block Counter
    derivationData[1] = 0x01; // 1 for first block, 2 for second, etc.

    // set Key Usage Indicator
    switch (keyUsage) {
      case DerivationKeyUsage.KeyEncryptionKey:
        derivationData[2] = 0x00;
        derivationData[3] = 0x02;
        break;
      case DerivationKeyUsage.PINEncryption:
        derivationData[2] = 0x10;
        derivationData[3] = 0x00;
        break;
      case DerivationKeyUsage.MessageAuthenticationGeneration:
        derivationData[2] = 0x20;
        derivationData[3] = 0x00;
        break;
      case DerivationKeyUsage.MessageAuthenticationVerification:
        derivationData[2] = 0x20;
        derivationData[3] = 0x01;
        break;
      case DerivationKeyUsage.MessageAuthenticationBothWays:
        derivationData[2] = 0x20;
        derivationData[3] = 0x02;
        break;
      case DerivationKeyUsage.DataEncryptionEncrypt:
        derivationData[2] = 0x30;
        derivationData[3] = 0x00;
        break;
      case DerivationKeyUsage.DataEncryptionDecrypt:
        derivationData[2] = 0x30;
        derivationData[3] = 0x01;
        break;
      case DerivationKeyUsage.DataEncryptionBothWays:
        derivationData[2] = 0x30;
        derivationData[3] = 0x02;
        break;
      case DerivationKeyUsage.KeyDerivation:
        derivationData[2] = 0x80;
        derivationData[3] = 0x00;
        break;
      case DerivationKeyUsage.KeyDerivationInitialKey:
        derivationData[2] = 0x80;
        derivationData[3] = 0x01;
        break;
    }

    // set Algorithm Indicator and key size
    switch (keyType) {
      case DerivationKeyType._2TDEA:
        derivationData[4] = 0x00;
        derivationData[5] = 0x00;
        break;
      case DerivationKeyType._3TDEA:
        derivationData[4] = 0x00;
        derivationData[5] = 0x01;
        break;
      case DerivationKeyType.AES128:
        derivationData[4] = 0x00;
        derivationData[5] = 0x02;
        break;
      case DerivationKeyType.AES192:
        derivationData[4] = 0x00;
        derivationData[5] = 0x03;
        break;
      case DerivationKeyType.AES256:
        derivationData[4] = 0x00;
        derivationData[5] = 0x04;
        break;
    }

    // set length of key material being generated
    switch (keyType) {
      case DerivationKeyType._2TDEA:
        derivationData[6] = 0x00;
        derivationData[7] = 0x80;
        break;
      case DerivationKeyType._3TDEA:
        derivationData[6] = 0x00;
        derivationData[7] = 0xC0;
        break;
      case DerivationKeyType.AES128:
        derivationData[6] = 0x00;
        derivationData[7] = 0x80;
        break;
      case DerivationKeyType.AES192:
        derivationData[6] = 0x00;
        derivationData[7] = 0xC0;
        break;
      case DerivationKeyType.AES256:
        derivationData[6] = 0x01;
        derivationData[7] = 0x00;
        break;
    }

    //  next 8 bytes depend on the derivation purpose
    if (derivationPurpose == DerivationPurpose.InitialKey) {
      derivationData = Uint8List.fromList(derivationData + initialKeyID);
    } else if (derivationPurpose == DerivationPurpose.DerivationOrWorkingKey) {
      derivationData =
          Uint8List.fromList(derivationData + initialKeyID.sublist(4));
      Uint8List counterBytes =
          counter.toRadixString(16).padLeft(8, '0').toHexBytes();
      derivationData = Uint8List.fromList(derivationData + counterBytes);
    }

    return derivationData;
  }

  Uint8List _deriveKey(
    Uint8List derivationKey,
    DerivationKeyType keyType,
    Uint8List derivationData,
  ) {
    int L = getKeyTypeLength(keyType);
    int n = (L / 128)
        .ceil(); // number of blocks required to construct the derived key
    Uint8List result = Uint8List(0);
    for (int i = 1; i <= n; i++) {
      // Set the value of the derivation data key block counter field equal to
      // the block count being derived.
      // First block is 0x01, second block is 0x02.
      derivationData[1] = i;
      result = Uint8List.fromList(
        result + _encryptECB(derivationKey, derivationData),
      );
    }
    final derivedKey = result.sublist(0, L ~/ 8);
    return derivedKey;
  }

  int getKeyTypeLength(DerivationKeyType keyType) {
    switch (keyType) {
      case DerivationKeyType._2TDEA:
        return 128;
      case DerivationKeyType._3TDEA:
        return 192;
      case DerivationKeyType.AES128:
        return 128;
      case DerivationKeyType.AES192:
        return 192;
      case DerivationKeyType.AES256:
        return 256;
    }
  }

  Uint8List _encryptECB(Uint8List derivationKey, Uint8List derivationData) {
    assert([128, 192, 256].contains(derivationKey.length * 8));
    assert(128 == derivationData.length * 8);

    final ecb = ECBBlockCipher(AESEngine())
      ..init(true, DESedeParameters(derivationKey));
    return ecb.process(derivationData);
  }
}
