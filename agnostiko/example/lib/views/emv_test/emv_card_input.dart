
import 'dart:io';

import 'package:agnostiko/agnostiko.dart';
import 'package:agnostiko_example/config/app_config.dart';
import 'package:agnostiko_example/config/app_keys.dart';
import 'package:agnostiko_example/dialogs/cancel_transaction_dialog.dart';
import 'package:agnostiko_example/dialogs/candidate_list_dialog.dart';
import 'package:agnostiko_example/dialogs/card_indicator_dialog.dart';
import 'package:agnostiko_example/dialogs/circular_progress_dialog.dart';
import 'package:agnostiko_example/dialogs/info_dialog.dart';
import 'package:agnostiko_example/models/transaction_args.dart';
import 'package:agnostiko_example/utils/counters.dart';
import 'package:agnostiko_example/utils/emv.dart';
import 'package:agnostiko_example/utils/issuer.dart';
import 'package:agnostiko_example/utils/keypad.dart';
import 'package:agnostiko_example/utils/locale.dart';
import 'package:agnostiko_example/views/card_input/card_input.dart';
import 'package:agnostiko_example/views/emv_test/emv_test.dart';
import 'package:agnostiko_example/views/emv_transaction_info/emv_transaction_info.dart';
import 'package:agnostiko_example/views/pin_input/pin_input.dart';
import 'package:flutter/material.dart';

class EMVTestCardInput extends StatefulWidget {
  const EMVTestCardInput({super.key});
  static String route = "/emvCardInput";

  @override
  State<EMVTestCardInput> createState() => _EMVTestCardInputState();
}

class _EMVTestCardInputState extends State<EMVTestCardInput> {
  TransactionArgs? transactionArgs;
  
  /// Flag para evitar el reingreso a la pantalla de PIN
  bool _pinProcessFlag = false;
  /// Flag para evitar doble proceso de detección
  bool _detectionStarted = false;

  List<CardType> _supportedCardTypes = [];
  List<CardType> _expectedCardTypes = [];

  bool debugMode = false;

  @override
  void dispose() {
    closeCardReader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    transactionArgs ??= ModalRoute.of(context)?.settings.arguments as TransactionArgs;

    if (_detectionStarted == false) {
      _detectionStarted = true;
      _supportedCardTypes = transactionArgs?.supportedCardTypes ?? [];
      _startCardDetection(_supportedCardTypes);
    }
    final amount = (transactionArgs?.amountInCents ?? 0) / 100;

    final currencyFormat = AppConfig.getCurrencyFormat(context);

    String appBarText;
    TextStyle style;
    if (transactionArgs?.emvTransactionType == EmvTransactionType.Refund) {
      appBarText = getLocalizations(context).refund;
      style = const TextStyle(color: Colors.red, fontSize: 32);
    } else {
      appBarText = getLocalizations(context).sale;
      style = const TextStyle(color: Colors.green, fontSize: 32);
    }

    return WillPopScope(
      onWillPop: cancelTransactionDialogFn(context),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: rawKeypadHandler(
          context,
          onEscape: cancelTransactionDialogFn(context),
        ),
        child: Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text(appBarText),
          ),
          body: Column(mainAxisSize: MainAxisSize.max, children: [
            Expanded(child: Container()),
            Text(
              currencyFormat.format(amount),
              style: style,
            ),
            const Text(""),
            _expectedCardsWidget,
            Expanded(child: Container()),
          ]),
        ),
      ),
    );
  }

  Widget get _expectedCardsWidget {
    List<Widget> widgets = [];

    if (_expectedCardTypes.contains(CardType.RF)) {
      widgets.add(CardExpectedWidget(
        imageUrl: "assets/img/tap_card.png",
        message: getLocalizations(context).tap,
      ));
    }
    if (_expectedCardTypes.contains(CardType.IC)) {
      widgets.add(CardExpectedWidget(
        imageUrl: "assets/img/insert_card.png",
        message: getLocalizations(context).insert,
      ));
    }

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(children: widgets);
    } else {
      // Se necesitan los 'Expanded' para que los elementos del 'Row' queden
      // centrados. Para 'Column' el centrado es vertical y es fuera del widget
      return Row(children: [
        Expanded(child: Container()),
        ...widgets,
        Expanded(child: Container()),
      ]);
    }
  }

  void _startCardDetection(List<CardType> cardTypes) async {
    // Si no hay tarjetas para leer es que llegamos a un punto de error
    if (cardTypes.isEmpty) {
      Navigator.popUntil(context, (route) => route.isFirst == true);
    }
    final cardReaderStream = openCardReader(cardTypes: cardTypes);
    setState(() {
      _expectedCardTypes = cardTypes;
    });

    try {
      await for (final event in cardReaderStream) {
        if (!mounted) return;
        if (event.cardType == CardType.IC) {
          await _onICCard();
        } else if (event.cardType == CardType.RF) {
          await _onRFCard();
        }
      }
    } on ChipCardException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).chipCardUseChip)));
      await closeCardReader();
      // reiniciamos la detección sin banda
      _startCardDetection(_supportedCardTypes
          .where((type) => type != CardType.Magnetic)
          .toList());
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).cardDetectionError)));

      print(stackTrace);
      Navigator.popUntil(context, (route) => route.isFirst == true);
    }
    print("****************CARD READER CLOSED*****************");
  }
  
  void Function(bool)? changeRFCardDialogFn;

  Future<void> _onICCard() async {
    transactionArgs?.entryMode = EntryMode.Contact;
    showCircularProgressDialog(context, getLocalizations(context).pleaseWait);
    _runTransaction();
  }
  Future<void> _onRFCard() async {
    transactionArgs?.entryMode = EntryMode.Contactless;
    changeRFCardDialogFn = showCardIndicatorDialog(context, true);
    _runTransaction();
  }
  Future<void> _waitIfContactlessCard() async {
    final changeDialogFn = changeRFCardDialogFn;
    if (transactionArgs?.entryMode == EntryMode.Contactless &&
        changeDialogFn != null) {
      changeDialogFn(false); // Cambiamos el semáforo a rojo
      changeRFCardDialogFn = null;
      await waitUntilRFCardRemoved(); // y esperamos al retiro de la tarjeta
    }
  }

  Future<void> _runTransaction() async {
    final amount = transactionArgs?.amountInCents ?? 0;
    final sequenceCounter = await getSequenceCounterAndIncrement();
    if (transactionArgs?.testMode == true) {
      debugMode = true;
    }
    final params = EmvTransactionParameters(
      transactionType: transactionArgs?.emvTransactionType ?? EmvTransactionType.Goods,
      transactionSequenceCounter: sequenceCounter,
      amount: amount,
      debugMode: debugMode,
    );

    final transactionStream = startEmvTransaction(params);
    transactionArgs?.emvStream = transactionStream;

    try {
      await for (final event in transactionStream) {
        if (!mounted) return; // si la pantalla no está activa cancelamos

        switch (event.runtimeType) {
          case EmvCandidateListEvent:
            final selectedIndex =
                await showCandidateListDialog(context, (event as EmvCandidateListEvent).candidateList) ?? 0;
            emvSelectCandidate(selectedIndex);
            break;
          case EmvAppSelectedEvent:
            await emvConfirmAppSelected();
            break;
          case EmvPinRequestedEvent:
            await _onPinRequested(event as EmvPinRequestedEvent);
            break;
          case EmvPinpadEntryEvent:
            await _onPinpadEntry((event as EmvPinpadEntryEvent).isOnline);
            break;
          case EmvOnlineRequestedEvent:
            await _onOnlineRequested(event as EmvOnlineRequestedEvent);
            break;
          case EmvFinishedEvent:
            return _onEmvFinished(event as EmvFinishedEvent);
        }
      }
    } on SocketException catch (e) {
      return _processEMVException(e, getLocalizations(context).commError);
    } catch (e) {
      return _processEMVException(
          e, "${getLocalizations(context).internalError}\n$e");
    }

    if (!mounted) return;
    // si llegamos aquí es porque se canceló la transacción en esta pantalla
    Navigator.popUntil(context, (route) => route.isFirst == true);
  }

  void _processEMVException(dynamic e, String message) async {
    await cancelEmvTransaction();
    if (!mounted) return; // si la pantalla no está activa cancelamos
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
    Navigator.pop(context);

    // en caso de error, nos movemos a la pantalla de cierre
    Navigator.pushReplacementNamed(
      context,
      EmvTransactionInfoView.route,
      arguments: transactionArgs,
    );
  }

  Future<void> _onPinRequested(EmvPinRequestedEvent event) async {
    if (_pinProcessFlag) return;

    _pinProcessFlag = true;
    transactionArgs?.remainingPinTries = event.remainingTries;

    await _waitIfContactlessCard();
    Navigator.pop(context); // cerramos el popup de progreso
    Navigator.pushNamed(
      context,
      PinInputView.route,
      arguments: transactionArgs,
    );
  }

  Future<void> _onPinpadEntry(bool isOnline) async {
    Navigator.pop(context);
    showCircularProgressDialog(context, getLocalizations(context).pinpadEntry);
    final pinEntryParameters = PinEntryParameters(
      timeout: 60,
      pinRSAData: null,
      allowedLength: [0, 4, 8, 23, 13, 6],
    );
    try {
      if (isOnline) {
        final onlineParameters = PinOnlineParameters(
          AppKeys.des.pinFixed,
          // Para Pinpad no hace falta pasar el PAN, el kernel se encarga de
          // obtenerlo. Por eso se deja vacío
          pan: "",
        );
        return emvConfirmPinpadEntry(pinEntryParameters, onlineParameters);
      } else {
        return emvConfirmPinpadEntry(pinEntryParameters);
      }
    } catch (e) {
      print("PIN Error: $e");
    }
    // si llegamos aquí, hubo cancelación, timeout o error
    await cancelEmvTransaction();
    print("****************PIN ENTRY CLOSED*****************");
  }

  Future<void> _onOnlineRequested(EmvOnlineRequestedEvent event) async {
    final transactionArgs = this.transactionArgs;

    await _waitIfContactlessCard();
    Navigator.pop(context); // cerramos el popup anterior
    showCircularProgressDialog(context, getLocalizations(context).processing);

    if (transactionArgs != null) {
      // si la transacción solicita ir online, ya tuvimos el 1st GENERATE AC
      transactionArgs.infoTags = await loadInfoTags();
      transactionArgs.firstGenerateTags = await emvGetGenerateCommandTags();
    if (transactionArgs.ulTestMode == true) {
        var testResponse = await processUlTest(transactionArgs);
        await emvCompleteOnline(testResponse);
      } else {
        await emvCompleteOnline(EmvOnlineResponse(authorisationResponseCode: "00"));
      }
    }
  }

  void _onEmvFinished(EmvFinishedEvent event) async {
    final transactionArgs = this.transactionArgs;
    transactionArgs?.transactionInfo = event.transactionInfo;
    bool? comparationResult;

    final pan = transactionArgs?.testPAN;
    if (debugMode && pan != null) {
      comparationResult = await testEMVPan(context, pan, transactionArgs);
    }

    await _waitIfContactlessCard();
    Navigator.pop(context); // quitamos el popup de progreso
    if (event.transactionInfo.result == EmvTransactionResult.PinTimeout) {
      await closeCardReader();
      await cancelEmvTransaction();

      Navigator.popUntil(context, (route) => route.isFirst == true);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).pinTimeout),
      ));
    } else {
      if (event.transactionInfo.onlineRequested && !event.transactionInfo.isContactless) {
        // si la transacción terminó tras irse online, ya el 1st GENERATE AC
        // debería haberse guardado y necesitamos guardar el 2nd GENERATE AC
        // si no es Contactless
        transactionArgs?.secondGenerateTags = await emvGetGenerateCommandTags();
      } else {
        // si la transacción terminó sin irse online, solo hubo 1st GENERATE AC
        transactionArgs?.infoTags = await loadInfoTags();
        transactionArgs?.firstGenerateTags = await emvGetGenerateCommandTags();
      }
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).emvModuleOk}: $comparationResult");
    }
  }
}