import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agnostiko/agnostiko.dart';

import 'package:agnostiko_example/pharos/void_response.dart';

import '../../config/app_config.dart';
import '../../config/app_keys.dart';
import '../../dialogs/info_dialog.dart';
import '../../dialogs/cancel_transaction_dialog.dart';
import '../../dialogs/candidate_list_dialog.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../dialogs/card_indicator_dialog.dart';
import '../../models/transaction_args.dart';
import '../../pharos/pharos.dart';
import '../../views/emv_transaction_info/emv_transaction_info.dart';
import '../../views/pin_input/pin_input.dart';
import '../../utils/emv.dart';
import '../../utils/comm.dart';
import '../../utils/counters.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

String firstKsn = "ffff7790169673800001";

const dukptMaxCounter = 3;

class CardInputView extends StatefulWidget {
  static String route = "/cardInput";

  @override
  _CardInputViewState createState() => _CardInputViewState();
}

class _CardInputViewState extends State<CardInputView> {
  TransactionArgs? transactionArgs;

  bool _isFallback = false;

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

    final _currencyFormat = AppConfig.getCurrencyFormat(context);

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
              _currencyFormat.format(amount),
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
    if (_expectedCardTypes.contains(CardType.Magnetic)) {
      widgets.add(CardExpectedWidget(
        imageUrl: "assets/img/swipe_card.png",
        message: getLocalizations(context).swipe,
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

        if (event.cardType == CardType.Magnetic) {
          final iv = "0000000000000000".toHexBytes();
          final encryptedTracksData = await getDUKPTEncryptedTracksData(
            AppKeys.des.transaction.index,
            CipherMode.CBC,
            iv,
          );
          await _onMagneticCard(encryptedTracksData);
        } else if (event.cardType == CardType.IC) {
          await _onICCard();
        } else if (event.cardType == CardType.RF) {
          await _onRFCard();
        }
      }
    } on ChipCardException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).chipCardUseChip),
      ));
      await closeCardReader();
      // reiniciamos la detección sin banda
      _startCardDetection(_supportedCardTypes
          .where((type) => type != CardType.Magnetic)
          .toList());
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).cardDetectionError),
      ));
      print("Error: $e");
      print(stackTrace);
      Navigator.popUntil(context, (route) => route.isFirst == true);
    }
    print("****************CARD READER CLOSED*****************");
  }

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

  Future<void> _onMagneticCard(DUKPTEncryptedTracksData? tracksData) async {
    if (!mounted) return;
    transactionArgs?.entryMode = EntryMode.Magstripe;

    final serviceCode = tracksData?.serviceCode;
    if (serviceCode == null) {
      throw StateError("service code missing");
    }
    final isChipCard =
        serviceCode.startsWith("2") || serviceCode.startsWith("6");

    if (!_isFallback &&
        isChipCard &&
        _supportedCardTypes.contains(CardType.IC)) {
      throw ChipCardException();
    } else {
      // Deshabilitado el ingreso de CVV ya que (al menos por ahora) no hay
      // forma segura de ingresar este dato en MPOS
      //_goToCvvInput();
      _doMagneticStripeSale();
    }
  }

  // Si la transacción es CTLSS, permite esperar a que se retire la tarjeta
  Future<void> _waitIfContactlessCard() async {
    final changeDialogFn = changeRFCardDialogFn;
    if (transactionArgs?.entryMode == EntryMode.Contactless &&
        changeDialogFn != null) {
      changeDialogFn(false); // Cambiamos el semáforo a rojo
      changeRFCardDialogFn = null;
      await waitUntilRFCardRemoved(); // y esperamos al retiro de la tarjeta
    }
  }

  void Function(bool)? changeRFCardDialogFn;

  Future<void> _runTransaction() async {
    final amount = transactionArgs?.amountInCents ?? 0;
    final sequenceCounter = await getSequenceCounterAndIncrement();
    final params = EmvTransactionParameters(
      transactionType:
          transactionArgs?.emvTransactionType ?? EmvTransactionType.Goods,
      transactionSequenceCounter: sequenceCounter,
      amount: amount,
      debugMode: debugMode,
    );

    _pinProcessFlag = false;
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
    MPOSController.instance.showHomeScreen();
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
    MPOSController.instance.showMessage(getLocalizations(context).processing);
    showCircularProgressDialog(context, getLocalizations(context).processing);

    String? responseCode;
    if (transactionArgs != null) {
      // si la transacción solicita ir online, ya tuvimos el 1st GENERATE AC
      transactionArgs.infoTags = await loadInfoTags();
      transactionArgs.firstGenerateTags = await emvGetGenerateCommandTags();

      final pharosMsg = await pharosGenerateSaleMsg(transactionArgs);
      print("PHAROS MSG: ${jsonEncode(pharosMsg)}");

      try {
        final response = await processSalePharos(pharosMsg);
        responseCode = response.resultCode;
        await emvCompleteOnline(EmvOnlineResponse(
          authorisationResponseCode: responseCode,
        ));
      } catch (e) {
        final stan = transactionArgs.stan;
        if (stan != null) {
          final response = await runVoidPharos(stan);
          String? responseCode = response.resultCode;

          Navigator.pop(context);

          String infoDialogText;
          if (responseCode == "00") {
            infoDialogText = getLocalizations(context).voidAccepted;
          } else {
            infoDialogText = getLocalizations(context).voidRejected;
          }

          String exception;

          if (transactionArgs.emvTransactionType ==
              EmvTransactionType.Refund) {
            exception = getLocalizations(context).refundFailed;
          } else {
            exception = getLocalizations(context).saleFailed;
          }

          showInfoDialog(context, "$exception. $infoDialogText",
              onClose: () async {
            await cancelEmvTransaction();
            Navigator.popUntil(context, (route) => route.isFirst == true);
          });
        } else {
          Navigator.pop(context);
          throw StateError("La venta falló. El stan no puede ser un valor nulo para el reverso");
        }
      }
    }
  }

  Future<PharosVoidResponse> runVoidPharos(int stan) async {
    print('Tiempo de espera excedido para la venta');
    final pharosVoidMsg = await pharosGenerateVoidMsg(stan.toString());
    print("Pharos Void MSG: $pharosVoidMsg");
    final response = await processVoidPharos(pharosVoidMsg);
    return response;
  }

  void _onEmvFinished(EmvFinishedEvent event) async {
    final transactionArgs = this.transactionArgs;
    transactionArgs?.transactionInfo = event.transactionInfo;

    await _waitIfContactlessCard();
    MPOSController.instance.showHomeScreen();
    Navigator.pop(context); // quitamos el popup de progreso
    if (event.transactionInfo.result == EmvTransactionResult.Fallback) {
      transactionArgs?.isFallback = true;
      setState(() {
        _isFallback = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).chipError),
      ));
      _startCardDetection(
        _supportedCardTypes.where((type) => type != CardType.IC).toList(),
      );
    } else if (event.transactionInfo.result == EmvTransactionResult.ReferPaymentDevice) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Refer to your payment device for instructions"),
      ));
      await closeCardReader();
      _startCardDetection(_supportedCardTypes);
    } else if (event.transactionInfo.result == EmvTransactionResult.PinTimeout) {
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
      Navigator.pushReplacementNamed(
        context,
        EmvTransactionInfoView.route,
        arguments: transactionArgs,
      );
    }
  }

  void _doMagneticStripeSale() async {
    final transactionArgs = this.transactionArgs;
    if (transactionArgs == null) return;

    showCircularProgressDialog(context, getLocalizations(context).processing);

    final pharosMsg = await pharosGenerateSaleMsg(transactionArgs);

    print("PHAROS MSG: ${jsonEncode(pharosMsg)}");
    final response = await processSalePharos(pharosMsg);
    String responseCode = response.resultCode;

    Navigator.pop(context);
    showInfoDialog(context, "Result: $responseCode", onClose: () {
      Navigator.popUntil(context, (route) => route.isFirst == true);
    });
  }
}

class CardExpectedWidget extends StatelessWidget {
  const CardExpectedWidget({
    Key? key,
    required this.imageUrl,
    required this.message,
  }) : super(key: key);

  final String imageUrl;
  final String message;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top + kToolbarHeight;
    final imageWidth = mediaQuery.orientation == Orientation.portrait
        ? (mediaQuery.size.height - statusBarHeight) / 5
        : mediaQuery.size.width / 4;

    return Column(children: [
      Image(
        image: AssetImage(imageUrl),
        width: imageWidth,
        height: imageWidth,
      ),
      Text(message, style:const TextStyle(color: Colors.grey, fontSize: 16)),
    ]);
  }
}
/// Error para indicar que se está utilizando banda con una tarjeta de chip.
class ChipCardException implements Exception {
  @override
  String toString() => 'ChipCardException';
}
