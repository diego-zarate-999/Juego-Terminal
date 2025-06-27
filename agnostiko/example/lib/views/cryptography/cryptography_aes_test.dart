import 'package:flutter/material.dart';

import '../../utils/crypto_test.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/log_test.dart';
import '../test_logger/test_logger.dart';

class CryptographyAESTestView extends StatefulWidget {
  static String route = "/cryptography/aes/test";

  @override
  _CryptographyAESTestViewState createState() =>
      _CryptographyAESTestViewState();
}

class _CryptographyAESTestViewState extends State<CryptographyAESTestView> {
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
              _runSet(loadAESKeysTestSet);
              break;
            case 2:
              _runSet(encryptionAESTestSet);
              break;
            case 3:
              _runSet(decryptionAESTestSet);
              break;
            case 4:
              _runSet(deleteAESKeysTestSet);
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
          title: Text(getLocalizations(context).cryptography),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).loadAESKeyTest),
                onTap: () => _runSet(loadAESKeysTestSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).aesDataEncryptionTest),
                onTap: () => _runSet(encryptionAESTestSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).aesDataDecryptionTest),
                onTap: () => _runSet(decryptionAESTestSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).deleteAESKeyTest),
                onTap: () => _runSet(deleteAESKeysTestSet),
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }

  void _runSet(List<LogTest> testSet) {
    Navigator.pushNamed(
      context,
      TestLoggerView.route,
      arguments: testSet,
    );
  }
}
