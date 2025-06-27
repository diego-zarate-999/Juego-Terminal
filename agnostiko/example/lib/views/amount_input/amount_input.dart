import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/app_config.dart';
import '../../dialogs/cancel_transaction_dialog.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../models/transaction_args.dart';
import '../../views/card_input/card_input.dart';
import '../../views/pan_input/pan_input.dart';
import '../../widgets/on_screen_keypad.dart';
import '../../utils/emv.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

class AmountInputView extends StatefulWidget {
  static String route = "/amountInput";

  @override
  _AmountInputViewState createState() => _AmountInputViewState();
}

class _AmountInputViewState extends State<AmountInputView> {
  final _amountController = TextEditingController();

  String? _amountError;

  // Este valor almacena los centavos como números enteros
  // Se debe dividir entre 100 para obtener su valor decimal real en dólares
  int _amountInCents = 0;

  TransactionArgs? transactionArgs;

  @override
  void initState() {
    super.initState();
    fixKeyboard();
  }

  void fixKeyboard() async {
    // El Newland P300 necesita este truco de mostrar y ocultar el teclado en
    // pantalla rápidamente para que pueda tomar los eventos del teclado físico
    if (await getModel() == "P300") {
      await SystemChannels.textInput.invokeMethod("TextInput.show");
      await SystemChannels.textInput.invokeMethod("TextInput.hide");
    }
  }

  @override
  Widget build(BuildContext context) {
    transactionArgs =
        ModalRoute.of(context)?.settings.arguments as TransactionArgs;

    _updateAmountText();

    String appBarText;
    if (transactionArgs?.emvTransactionType == EmvTransactionType.Refund) {
      appBarText = getLocalizations(context).refund;
    } else {
      appBarText = getLocalizations(context).sale;
    }

    return WillPopScope(
      onWillPop: cancelTransactionDialogFn(context),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: rawKeypadHandler(
          context,
          onDigit: _addDigit,
          onEnter: _acceptAmount,
          onBackspace: _removeDigit,
          onEscape: cancelTransactionDialogFn(context),
        ),
        child: Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text(appBarText),
          ),
          body: Column(mainAxisSize: MainAxisSize.max, children: [
            Expanded(child: Container()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                autofocus: true,
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: getLocalizations(context).amount,
                  errorText: _amountError,
                ),
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40),
              ),
            ),
            if (transactionArgs?.showNumericKeyboard == true)
              OnScreenKeypad(
                onAccept: _acceptAmount,
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

  void _updateAmountText() {
    final currencyFormat = AppConfig.getCurrencyFormat(context);
    _amountController.text = currencyFormat.format(_amountInCents / 100);
  }

  void _addDigit(int value) {
    if (_amountInCents.toString().length >= 6) return;

    _amountInCents = int.parse(_amountInCents.toString() + value.toString());
    _updateAmountText();
  }

  void _removeDigit() {
    int digitsCount = _amountInCents.toString().length;

    _amountInCents = digitsCount > 1
        ? int.parse(_amountInCents.toString().substring(0, digitsCount - 1))
        : 0;

    _updateAmountText();
  }

  void _clearDigits() {
    _amountInCents = 0;
    _updateAmountText();
  }

  void _acceptAmount() async {
    if (_validate()) {
      transactionArgs?.amountInCents = _amountInCents;

      if (transactionArgs?.entryMode == EntryMode.Manual) {
        Navigator.pushReplacementNamed(context, PanInputView.route,
            arguments: transactionArgs);
      } else {
        final hasCardReader =
            transactionArgs?.platformInfo.hasCardReader ?? false;
        final hasEmvModule =
            transactionArgs?.platformInfo.hasEmvModule ?? false;

        final deviceType = await getDeviceType();
        if (hasCardReader) {
          if (hasEmvModule &&
              (deviceType == DeviceType.POS ||
                  deviceType == DeviceType.PINPAD)) {
            // mostramos un popup mientras se realiza la carga de parámetros EMV
            showCircularProgressDialog(
              context,
              getLocalizations(context).pleaseWait,
            );
            if (deviceType != DeviceType.PINPAD) {
              await emvPreTransaction();
            }
            Navigator.pop(context); // y cerramos el popup antes de seguir
          }

          Navigator.pushReplacementNamed(context, CardInputView.route,
              arguments: transactionArgs);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              getLocalizations(context).deviceWithoutCardReader,
            ),
          ));
          Navigator.popUntil(context, (route) => route.isFirst == true);
        }
      }
    }
  }

  bool _validate() {
    bool isValid = _amountInCents > 0 && _amountInCents <= 999999;

    setState(() {
      _amountError = isValid ? null : getLocalizations(context).invalidValue;
    });

    return isValid;
  }
}
