import 'package:flutter/material.dart';

import '../../utils/crypto_test.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/log_test.dart';
import '../test_logger/test_logger.dart';

class CryptographyDESTestView extends StatefulWidget {
  static String route = "/cryptography/des/test";

  @override
  _CryptographyDESTestViewState createState() =>
      _CryptographyDESTestViewState();
}

class _CryptographyDESTestViewState extends State<CryptographyDESTestView> {
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
              _runSet(loadKeysTestSet);
              break;
            case 2:
              _runSet(encryptionTestSet);
              break;
            case 3:
              _runSet(decryptionTestSet);
              break;
            case 4:
              _runSet(deleteKeysTestSet);
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
                title: Text(getLocalizations(context).loadKeyTest),
                onTap: () => _runSet(loadKeysTestSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).dataEncryptionTest),
                onTap: () => _runSet(encryptionTestSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).dataDecryptionTest),
                onTap: () => _runSet(decryptionTestSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).deleteKeyTest),
                onTap: () => _runSet(deleteKeysTestSet),
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
