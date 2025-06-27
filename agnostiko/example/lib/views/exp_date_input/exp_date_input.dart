import 'package:flutter/material.dart';

import 'package:agnostiko_example/views/cvv_input/cvv_input.dart';

import '../../dialogs/cancel_transaction_dialog.dart';
import '../../models/transaction_args.dart';
import '../../widgets/on_screen_keypad.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

class ExpDateInputView extends StatefulWidget {
  static String route = "/expDateInput";

  @override
  _ExpDateInputViewState createState() => _ExpDateInputViewState();
}

class _ExpDateInputViewState extends State<ExpDateInputView> {
  final _expDateController = TextEditingController();
  final _maxLen = 4;

  String? _expDateError;

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
          onEnter: _acceptExpDate,
          onBackspace: _removeDigit,
          onEscape: cancelTransactionDialogFn(context),
        ),
        child: Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text(getLocalizations(context).sale),
          ),
          body: Column(children: [
            Expanded(child: Container()),
            TextField(
              autofocus: true,
              controller: _expDateController,
              decoration: InputDecoration(
                labelText: getLocalizations(context).expirationDate,
                hintText: getLocalizations(context).mmyy,
                errorText: _expDateError,
              ),
              maxLength: _maxLen,
              obscureText: true,
              readOnly: true,
              style: TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            ),
            if (transactionArgs?.showNumericKeyboard == true)
              OnScreenKeypad(
                onAccept: _acceptExpDate,
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
    if (_expDateController.text.length < _maxLen) {
      _expDateController.text += digit.toString();
    }
  }

  void _removeDigit() {
    int len = _expDateController.text.length;
    String expDate = _expDateController.text;
    if (len > 0) _expDateController.text = expDate.substring(0, len - 1);
  }

  void _clearDigits() {
    _expDateController.text = "";
  }

  void _acceptExpDate() {
    if (_validate()) {
      transactionArgs?.expDate = _expDateController.text;
      Navigator.pushReplacementNamed(context, CvvInputView.route,
          arguments: transactionArgs);
    }
  }

  bool _validate() {
    bool isValid = _expDateController.text.length == _maxLen;

    setState(() {
      _expDateError = isValid ? null : getLocalizations(context).invalidValue;
    });

    return isValid;
  }
}
