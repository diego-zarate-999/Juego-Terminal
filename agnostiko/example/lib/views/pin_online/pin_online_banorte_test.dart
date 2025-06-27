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

class PinOnlineBanorteTest extends StatefulWidget {
  const PinOnlineBanorteTest({super.key});
  static String route = "/pinOnline/banorte/test";

  @override
  State<PinOnlineBanorteTest> createState() => _PinOnlineBanorteTestState();
}

class _PinOnlineBanorteTestState extends State<PinOnlineBanorteTest> {
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
              _runSet(PinOnlineTest.banorte.loadKeysSet);
              break;
            case 2:
              _runPinTest(
                AppKeys.aes.llavePinOnlineBanorte,
              );
              break;
            case 3:
              _runSet(PinOnlineTest.banorte.deleteKeysSet);
              break;
          }
        },
        onEscape: () {
          Navigator.pop(context, true);
        }
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text("PIN Online Banorte"),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).randomKeyWithRSASet),
                onTap: () => _runSet(PinOnlineTest.banorte.loadKeysSet),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).dukptKeyTest),
                onTap: () async => _runPinTest(AppKeys.aes.llavePinOnlineBanorte),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).deleteRandomKeyWithRSASet),
                onTap: () => _runSet(PinOnlineTest.banorte.deleteKeysSet),
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

  Future<void> _runPinTest(SymmetricKey key) async {
    Uint8List keyClearData = BanorteKeys.instance.initialKey;
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