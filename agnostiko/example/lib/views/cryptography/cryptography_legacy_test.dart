import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../config/app_keys.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

class CryptographyLegacyTestView extends StatefulWidget {
  static String route = "/cryptography/legacy/test";

  @override
  _CryptographyLegacyTestViewState createState() =>
      _CryptographyLegacyTestViewState();
}

class _CryptographyLegacyTestViewState
    extends State<CryptographyLegacyTestView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) {
          switch (digit) {
            case 1:
              _testDUKPTEncryption(true);
              break;
            case 2:
              _testDUKPTEncryption(false);
              break;
          }
        },
        onEscape: () {
          Navigator.pop(context, true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).cryptographyLegacy),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).encryptionCipherOption),
                onTap: () async {
                  _testDUKPTEncryption(true);
                },
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).encryptionClearOption),
                onTap: () async {
                  _testDUKPTEncryption(false);
                },
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }

  Future<void> _testDUKPTEncryption(bool withKEK) async {
    try {
      await _doTestDUKPT(withKEK);
    } catch (e, stacktrace) {
      print("Encryption error: $e");
      print("Stacktrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).encryptionError),
      ));
    }
    Navigator.pop(context); // cerramos el dialog de progreso
  }

  //TODO Borrar llaves al final de la prueba para evitar conflictos con transacciones
  Future<void> _doTestDUKPT(bool withKEK) async {
    DUKPTResult encrypted;
    showCircularProgressDialog(context, getLocalizations(context).processing);

    final kekIndex = AppKeys.des.kek.index;
    final keyIndex = withKEK
        ? AppKeys.des.testLegacyEncrypted.index
        : AppKeys.des.testLegacyClear.index;
    final kcv = withKEK
        ? AppKeys.des.testLegacyEncrypted.kcv
        : AppKeys.des.testLegacyClear.kcv;
    final ipekClear = AppKeys.des.testLegacyClear.data;
    final ipekCipher = AppKeys.des.testLegacyEncrypted.data;
    final ksn = AppKeys.des.testLegacyEncrypted.ksn;
    if (ipekClear == null || ipekCipher == null || ksn == null) {
      throw StateError("missing ipek data");
    }

    // ECB
    final dataECB = "5413330002001171".toHexBytes();
    if (withKEK) {
      await cryptoLoadIPEK(keyIndex, ksn, ipekCipher,
          kekIndex: kekIndex, kcv: kcv);
    } else {
      await cryptoLoadIPEK(keyIndex, ksn, ipekClear);
    }
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataECB, CipherMode.ECB);
    _throwIfWrongEncryption(encrypted, 1, "52c11e4e843f4d45".toHexBytes());
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataECB, CipherMode.ECB);
    _throwIfWrongEncryption(encrypted, 1, "52c11e4e843f4d45".toHexBytes());

    await cryptoDUKPTIncrementKSN(keyIndex);
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataECB, CipherMode.ECB);
    _throwIfWrongEncryption(encrypted, 2, "29038990ea43e82b".toHexBytes());
    for (int i = 0; i < 3; i++) {
      await cryptoDUKPTIncrementKSN(keyIndex);
    }
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataECB, CipherMode.ECB);
    _throwIfWrongEncryption(encrypted, 5, "653f770d15f6a55c".toHexBytes());
    for (int i = 0; i < 5; i++) {
      await cryptoDUKPTIncrementKSN(keyIndex);
    }
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataECB, CipherMode.ECB);
    _throwIfWrongEncryption(encrypted, 10, "50160b1776c61297".toHexBytes());
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataECB, CipherMode.ECB);
    _throwIfWrongEncryption(encrypted, 10, "50160b1776c61297".toHexBytes());

    print("ECB OK!");

    // CBC
    final iv = "FFFFFFFFFFFFFFFD".toHexBytes();
    final dataCBC =
        "d1390cd6b0191009ef37214e244bf88dad21a2fd1ef7a977b6ef9b674cd32ddb"
            .toHexBytes();

    if (withKEK) {
      await cryptoLoadIPEK(keyIndex, ksn, ipekCipher,
          kekIndex: kekIndex, kcv: kcv);
    } else {
      await cryptoLoadIPEK(keyIndex, ksn, ipekClear);
    }
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataCBC, CipherMode.CBC, iv);
    _throwIfWrongEncryption(
      encrypted,
      1,
      '95d318265c2724be811861669af71625efcd10826caa0cfed7e35e67e675fd3d'
          .toHexBytes(),
    );
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataCBC, CipherMode.CBC, iv);
    _throwIfWrongEncryption(
      encrypted,
      1,
      '95d318265c2724be811861669af71625efcd10826caa0cfed7e35e67e675fd3d'
          .toHexBytes(),
    );
    await cryptoDUKPTIncrementKSN(keyIndex);
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataCBC, CipherMode.CBC, iv);
    _throwIfWrongEncryption(
      encrypted,
      2,
      '936ec275bb1d0d27f16272e0a3a75dc7727f9e6eaae1375a4d5045636688f932'
          .toHexBytes(),
    );
    for (int i = 0; i < 3; i++) {
      await cryptoDUKPTIncrementKSN(keyIndex);
    }
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataCBC, CipherMode.CBC, iv);
    _throwIfWrongEncryption(
      encrypted,
      5,
      '2533612a80bcb0df0f525bf77a04d439d0e0790dd3f26725504bb989142f75e2'
          .toHexBytes(),
    );
    for (int i = 0; i < 5; i++) {
      await cryptoDUKPTIncrementKSN(keyIndex);
    }
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataCBC, CipherMode.CBC, iv);
    _throwIfWrongEncryption(
      encrypted,
      10,
      'eb014cbe5ba91c4276f1b090c5af98d96e927a356a665708fbf07ddd27fca2a8'
          .toHexBytes(),
    );
    encrypted = await cryptoDUKPTEncrypt(keyIndex, dataCBC, CipherMode.CBC, iv);
    _throwIfWrongEncryption(
      encrypted,
      10,
      'eb014cbe5ba91c4276f1b090c5af98d96e927a356a665708fbf07ddd27fca2a8'
          .toHexBytes(),
    );

    print("CBC OK!");

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(getLocalizations(context).encryptionModuleOk),
    ));
  }

  void _throwIfWrongEncryption(
      DUKPTResult result, int validKSNCounter, Uint8List validData) {
    if (result.ksn[9] != validKSNCounter ||
        result.data.toHexStr() != validData.toHexStr()) {
      Navigator.pop(context); // cerramos el dialog de progreso
      throw StateError("Wrong encryption result");
    }
  }
}
