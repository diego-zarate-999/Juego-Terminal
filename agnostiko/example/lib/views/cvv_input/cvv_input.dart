import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../pharos/pharos.dart';
import '../../utils/comm.dart';
import '../../dialogs/cancel_transaction_dialog.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../dialogs/info_dialog.dart';
import '../../models/transaction_args.dart';
import '../../widgets/on_screen_keypad.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

class CvvInputView extends StatefulWidget {
  static String route = "/cvvInput";

  @override
  _CvvInputViewState createState() => _CvvInputViewState();
}

class _CvvInputViewState extends State<CvvInputView> {
  final _cvvController = TextEditingController();
  final _maxLen = 3;

  String? _cvvError;

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
            onEnter: _acceptCvv,
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
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: "CVV2",
                  errorText: _cvvError,
                ),
                maxLength: _maxLen,
                obscureText: true,
                readOnly: true,
                style: TextStyle(fontSize: 40),
                textAlign: TextAlign.center,
              ),
              if (transactionArgs?.showNumericKeyboard == true)
                OnScreenKeypad(
                  onAccept: _acceptCvv,
                  onDigitTap: _addDigit,
                  onBackspaceTap: _removeDigit,
                  onClearTap: _clearDigits,
                )
              else
                Expanded(child: Container())
            ]),
          )),
    );
  }

  void _addDigit(int digit) {
    if (_cvvController.text.length < _maxLen) {
      _cvvController.text += digit.toString();
    }
  }

  void _removeDigit() {
    int len = _cvvController.text.length;
    String expDate = _cvvController.text;
    if (len > 0) _cvvController.text = expDate.substring(0, len - 1);
  }

  void _clearDigits() {
    _cvvController.text = "";
  }

  void _acceptCvv() {
    if (_validate()) {
      transactionArgs?.cvv = _cvvController.text;
      _doSale();
    }
  }

  bool _validate() {
    bool isValid = _cvvController.text.length == _maxLen;

    setState(() {
      _cvvError = isValid ? null : getLocalizations(context).invalidValue;
    });

    return isValid;
  }

  void _doSale() async {
    final transactionArgs = this.transactionArgs;
    if (transactionArgs == null) return;

    if (transactionArgs.entryMode == EntryMode.Manual &&
        transactionArgs.pan != null) {
      transactionArgs.clearTrack2 =
          "${transactionArgs.pan}D${transactionArgs.expDate ?? "0000"}";
    }

    showCircularProgressDialog(context, getLocalizations(context).processing);

    try {
      final pharosMsg = await pharosGenerateSaleMsg(transactionArgs);

      print("PHAROS MSG: ${jsonEncode(pharosMsg)}");
      final response = await processSalePharos(pharosMsg);
      String responseCode = response.resultCode;

      Navigator.pop(context);
      showInfoDialog(context, "Result: $responseCode", onClose: () {
        Navigator.popUntil(context, (route) => route.isFirst == true);
      });
    } on SocketException catch (e) {
      _showError(e, getLocalizations(context).commError);
    } catch (e) {
      _showError(e, "${getLocalizations(context).internalError}\n$e");
    }
  }

  void _showError(dynamic e, String message) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
    print("Error: $e");
    Navigator.popUntil(context, (route) => route.isFirst == true);
  }
}
