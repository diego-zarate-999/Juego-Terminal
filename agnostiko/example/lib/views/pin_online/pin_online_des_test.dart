import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../test_pin/test_pin_input.dart';
import '../../config/app_keys.dart';
import '../../dialogs/selection_dialog.dart';
import '../../models/pin_test_args.dart';
import '../../utils/emv.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/log_test.dart';
import '../../utils/pin_test.dart';
import '../test_logger/test_logger.dart';

class PinOnlineDESTestView extends StatefulWidget {
  static String route = "/pinOnline/des/test";

  @override
  _PinOnlineDESTestViewState createState() => _PinOnlineDESTestViewState();
}

class _PinOnlineDESTestViewState extends State<PinOnlineDESTestView> {
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
              _runSet(PinOnlineTest.des.loadKeysSet);
              break;
            case 2:
              _runPinTest(
                AppKeys.des.pinTR31Fixed,
                AppKeys.des.pinTR31FixedClearData,
              );
              break;
            case 3:
              _runPinTest(
                AppKeys.des.pinTR31DUKPT,
                AppKeys.des.pinTR31DUKPTClearData,
              );
              break;
            case 4:
              _runSet(PinOnlineTest.des.deleteKeysSet);
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
          title: const Text("PIN Online DES"),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).loadKeyTest),
                onTap: () => _runSet(PinOnlineTest.des.loadKeysSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).fixedKeyTest),
                onTap: () => _runPinTest(
                  AppKeys.des.pinTR31Fixed,
                  AppKeys.des.pinTR31FixedClearData,
                ),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).dukptKeyTest),
                onTap: () => _runPinTest(
                  AppKeys.des.pinTR31DUKPT,
                  AppKeys.des.pinTR31DUKPTClearData,
                ),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).deleteKeyTest),
                onTap: () => _runSet(PinOnlineTest.des.deleteKeysSet),
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

  Future<void> _runPinTest(SymmetricKey key, Uint8List keyClearData) async {
    await emvPreTransaction(isTestPINMode: true);

    if (!mounted) return;
    final CardType? cardType = await showSelectionDialog<CardType>(
      context,
      {"IC": CardType.IC, "RF": CardType.RF},
    );
    if (cardType == null) return;

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      TestPinInputView.route,
      arguments: PinTestArgs(
        cardType: cardType,
        key: key,
        keyClearData: keyClearData,
      ),
    );
  }
}
