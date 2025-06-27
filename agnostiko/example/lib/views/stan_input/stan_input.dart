import 'package:flutter/material.dart';

import '../../dialogs/cancel_transaction_dialog.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../dialogs/info_dialog.dart';
import '../../models/transaction_args.dart';
import '../../utils/comm.dart';
import '../../pharos/pharos.dart';
import '../../widgets/on_screen_keypad.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

class StanInputView extends StatefulWidget {
  static String route = "/stanInput";

  @override
  _StanInputViewState createState() => _StanInputViewState();
}

class _StanInputViewState extends State<StanInputView> {
  final _stanController = TextEditingController();

  final _maxLen = 6;

  String? _stanError;

  TransactionArgs? transactionArgs;

  @override
  Widget build(BuildContext context) {
    transactionArgs =
        ModalRoute.of(context)?.settings.arguments as TransactionArgs;

    return WillPopScope(
      onWillPop: cancelTransactionDialogFn(context),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: rawKeypadHandler(
          context,
          onDigit: _addDigit,
          onEnter: _acceptStan,
          onBackspace: _removeDigit,
          onEscape: cancelTransactionDialogFn(context),
        ),
        child: Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text("STAN"),
          ),
          body: Column(children: [
            Expanded(child: Container()),
            Padding(
              child: TextField(
                autofocus: true,
                controller: _stanController,
                decoration: InputDecoration(
                  //labelText: getLocalizations(context).cardNumber,
                  errorText: _stanError,
                ),
                maxLength: _maxLen,
                readOnly: true,
                style: TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            if (transactionArgs?.showNumericKeyboard == true)
              OnScreenKeypad(
                onAccept: _acceptStan,
                onDigitTap: _addDigit,
                onBackspaceTap: _removeDigit,
                onClearTap: _clearDigits,
              )
            else
              Expanded(child: Container())
          ]),
        ),
      ),
    );
  }

  void _addDigit(int digit) {
    if (_stanController.text.length < _maxLen) {
      _stanController.text += digit.toString();
    }
  }

  void _removeDigit() {
    final stan = _stanController.text;
    _stanController.text =
        stan.length > 0 ? stan.substring(0, stan.length - 1) : "";
  }

  void _clearDigits() {
    _stanController.text = "";
  }

  Future<void> _acceptStan() async {
    if (_validate()) {
      final pharosVoidMsg = await pharosGenerateVoidMsg(_stanController.text);
      print("$pharosVoidMsg");
      String? responseCode;
      try {
        showCircularProgressDialog(
          context,
          getLocalizations(context).pleaseWait,
        );
        final response = await processVoidPharos(pharosVoidMsg);
        responseCode = response.resultCode;
      } catch (e) {
        print("Error: $e");
      }

      Navigator.pop(context);

      String infoDialogText;
      if (responseCode == "00") {
        infoDialogText = getLocalizations(context).voidAccepted;
      } else {
        infoDialogText = getLocalizations(context).voidRejected;
      }
      showInfoDialog(context, "$infoDialogText", onClose: () {
        Navigator.popUntil(context, (route) => route.isFirst == true);
      });
    }
  }

  bool _validate() {
    final stan = _stanController.text;
    bool isValid = stan != "";

    setState(() {
      _stanError = isValid ? null : getLocalizations(context).invalidValue;
    });

    return isValid;
  }
}
