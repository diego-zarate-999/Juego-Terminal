import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agnostiko/agnostiko.dart';

import '../../models/transaction_args.dart';
import '../../config/app_keys.dart';
import '../../utils/emv.dart';
import '../../utils/locale.dart';

class PinInputView extends StatefulWidget {
  static String route = "/pinInput";

  @override
  _PinInputViewState createState() => _PinInputViewState();
}

class _PinInputViewState extends State<PinInputView> {
  final _pinTextController = TextEditingController();

  String? _pinError;

  TransactionArgs? transactionArgs;
  int? remainingPinTries;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emvEventLoop());
  }

  @override
  void dispose() {
    transactionArgs = null;
    remainingPinTries = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (transactionArgs == null) {
      transactionArgs =
          ModalRoute.of(context)?.settings.arguments as TransactionArgs;

      remainingPinTries = transactionArgs?.remainingPinTries;
    }

    String appBarText;
    if (transactionArgs?.emvTransactionType == EmvTransactionType.Refund) {
      appBarText = getLocalizations(context).refund;
    } else {
      appBarText = getLocalizations(context).sale;
    }

    return PopScope(
      canPop: Platform.isLinux ? false : true,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(appBarText),
        ),
        body: Column(children: [
          TextField(
            autofocus: true,
            controller: _pinTextController,
            decoration: InputDecoration(
              labelText: "PIN ($remainingPinTries)",
              errorText: _pinError,
            ),
            obscureText: true,
            readOnly: true,
            style: TextStyle(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          Expanded(child: Container()),
        ]),
      ),
    );
  }

  void _emvEventLoop() async {
    final emvStream = transactionArgs?.emvStream;
    if (emvStream == null) return;

    try {
      await for (IEmvEvent event in emvStream) {
        if (!mounted) return; // si la pantalla no está activa cancelamos

        if (event is EmvPinRequestedEvent) {
          await _onPinRequested(event);
        }
      }
    } catch (e) {
      print("EMV Error: $e");
    }
  }

  Future<void> _onPinRequested(EmvPinRequestedEvent event) async {
    // cuando cambie el valor de intentos de PIN restantes...
    if (this.remainingPinTries != event.remainingTries) {
      setState(() {
        this.remainingPinTries = event.remainingTries;
      });
      _pinError = getLocalizations(context).wrongPIN;
    }

    final entryParameters = PinEntryParameters(
      timeout: 60,
      pinRSAData: event.pinRSAData,
      allowedLength: [0, 4, 8, 23, 13, 6],
    );

    final Stream<IPinEvent> pinEntryStream;
    if (event.isOnline) {
      String clearPAN;
      PinOnlineParameters onlineParameters;
      if (transactionArgs?.testPinMode == true) {
        clearPAN = "4761731000000043";
      } else {
        clearPAN = await emvGetClearPAN();
      }

      if (transactionArgs?.isDUKPTPin == true) {
        onlineParameters = PinOnlineParameters(
          AppKeys.des.pinDUKPT,
          pan: clearPAN,
        );
      } else {
        onlineParameters = PinOnlineParameters(
          AppKeys.des.pinFixed,
          pan: clearPAN,
        );
      }
      pinEntryStream = startOnlinePinEntry(entryParameters, onlineParameters);
    } else {
      pinEntryStream = startOfflinePinEntry(entryParameters);
    }
    MPOSController.instance.showMessage("PIN:");
    try {
      await for (final event in pinEntryStream) {
        if (!mounted) return;

        if (event is PinFinishedEvent) {
          if (transactionArgs?.testPinMode == true) {
            transactionArgs?.actualPinBlock = event.pinBlock;
            if (transactionArgs?.isDUKPTPin == true) {
              int counter = transactionArgs?.dukptInputCounter ?? 0;
              transactionArgs?.dukptInputCounter = counter + 1;
              transactionArgs?.actualKsn = event.ksn;
            }
            return emvCompletePin(event.pinBlock);
          } else {
            return emvCompletePin(event.pinResultSw);
          }
        } else if (event is PinCancelledEvent) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(getLocalizations(context).pinCancelled),
          ));
        } else if (event is PinTimeoutEvent) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(getLocalizations(context).pinTimeout),
          ));
        } else if (event is PinInputChangedEvent) {
          String bullets = "";
          for (int i = 0; i < event.inputLength; i++) {
            bullets += "*";
          }
          this._pinTextController.text = bullets;
          MPOSController.instance.showMessage("PIN:\n$bullets");
        } else {}
      }
    } catch (e) {
      print("PIN Error: $e");
      return emvCompletePin(null);
    }
    // si llegamos aquí, hubo cancelación o timeout
    await cancelPinEntry();
    await closeCardReader();
    await cancelEmvTransaction();
    print("****************PIN ENTRY CLOSED*****************");
  }
}
