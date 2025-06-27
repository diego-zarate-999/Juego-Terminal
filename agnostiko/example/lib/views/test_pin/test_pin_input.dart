import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agnostiko/agnostiko.dart';

import '../../config/app_config.dart';
import '../../dialogs/info_dialog.dart';
import '../../dialogs/pin_online_dialog.dart';
import '../../models/pin_test_args.dart';
import '../../utils/aes_dukpt.dart';
import '../../utils/counters.dart';
import '../../utils/dukpt.dart';
import '../../utils/locale.dart';
import '../../utils/pin_online.dart';

const dukptMaxCounter = 3;

class TestPinInputView extends StatefulWidget {
  static String route = "test/pinInput";

  @override
  _TestPinInputViewState createState() => _TestPinInputViewState();
}

class _TestPinInputViewState extends State<TestPinInputView> {
  final _pinTextController = TextEditingController();

  String? _pinError;

  PinTestArgs? _pinArgs;
  int? _remainingPinTries;

  /// Flag para evitar el reingreso a la pantalla de PIN
  bool _pinProcessFlag = false;

  /// Flag para evitar doble proceso de detección
  bool _detectionStarted = false;

  /// Resultado del PIN Block para validar
  Uint8List? _pinBlock;

  /// Control de KSN actual para desencriptado del bloque
  Uint8List? _currentKsn;

  /// Contador de cantidad de ingresos bajo DUKPT
  int _dukptInputCounter = 0;

  @override
  void dispose() {
    _pinArgs = null;
    _remainingPinTries = null;
    closeCardReader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pinArgs ??= ModalRoute.of(context)?.settings.arguments as PinTestArgs;

    String appBarText = getLocalizations(context).sale;

    if (_detectionStarted == false) {
      _detectionStarted = true;
      final cardType = _pinArgs?.cardType;
      if (cardType != null) {
        _startCardDetection(cardType);
      } else {
        Navigator.popUntil(context, (route) => route.isFirst == true);
      }
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
              labelText: "PIN ($_remainingPinTries)",
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

  Future<void> _onPinRequested(EmvPinRequestedEvent event) async {
    if (_pinProcessFlag) return;
    _pinProcessFlag = true;

    // cuando cambie el valor de intentos de PIN restantes...
    if (_remainingPinTries != event.remainingTries) {
      setState(() {
        _remainingPinTries = event.remainingTries;
      });
    }

    final entryParameters = PinEntryParameters(
      timeout: 60,
      pinRSAData: event.pinRSAData,
      allowedLength: [0, 4, 8, 23, 13, 6],
    );

    try {
      final Stream<IPinEvent> pinEntryStream;
      if (event.isOnline) {
        final pinKey = _pinArgs?.key;
        if (pinKey == null) {
          throw StateError("missing pinArgs");
        }
        String clearPAN = "4761731000000043";

        final onlineParameters = PinOnlineParameters(pinKey, pan: clearPAN);
        pinEntryStream = startOnlinePinEntry(entryParameters, onlineParameters);
      } else {
        pinEntryStream = startOfflinePinEntry(entryParameters);
      }

      await for (final event in pinEntryStream) {
        if (!mounted) return;

        if (event is PinFinishedEvent) {
          _pinBlock = event.pinBlock;
          final key = _pinArgs?.key;
          if (key is DUKPTKey) {
            await cryptoIncrementKSN(key);
            _dukptInputCounter += 1;
            _currentKsn = event.ksn;
          }
          return emvCompletePin(event.pinBlock);
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
          _pinTextController.text = bullets;
        }
      }
    } catch (e) {
      _pinBlock = null;
      print("PIN Error: $e");
      showInfoDialog(context, e.toString());
      return emvCompletePin(null);
    }
    // si llegamos aquí, hubo cancelación o timeout
    await cancelPinEntry();
    await closeCardReader();
    await cancelEmvTransaction();
    print("****************PIN ENTRY CLOSED*****************");
  }

  void _startCardDetection(CardType cardType) async {
    final cardReaderStream = openCardReader(cardTypes: [cardType]);
    try {
      await for (final _ in cardReaderStream) {
        if (!mounted) return;
        await _runTransaction();
      }
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

  Future<void> _runTransaction() async {
    final sequenceCounter = await getSequenceCounterAndIncrement();
    final params = EmvTransactionParameters(
      transactionType: EmvTransactionType.Goods,
      transactionSequenceCounter: sequenceCounter,
      amount: 20000,
    );

    _pinProcessFlag = false;
    final transactionStream = startEmvTransaction(params);
    try {
      await for (final event in transactionStream) {
        if (!mounted) return; // si la pantalla no está activa cancelamos

        if (event is EmvAppSelectedEvent) {
          await _onAppSelected(event);
        } else if (event is EmvPinRequestedEvent) {
          await _onPinRequested(event);
        } else if (event is EmvPinpadEntryEvent) {
          await _onPinpadEntry(event.isOnline);
        } else if (event is EmvOnlineRequestedEvent) {
          await _onOnlineRequested(event);
        } else if (event is EmvFinishedEvent) {
          return _onEmvFinished(event);
        }
      }
    } catch (e) {
      return _processEMVException(
          e, "${getLocalizations(context).internalError}\n$e");
    }
  }

  void _processEMVException(dynamic e, String message) async {
    await cancelEmvTransaction();
    if (!mounted) return;
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _onAppSelected(EmvAppSelectedEvent event) async {
    await emvConfirmAppSelected();
  }

  Future<void> _onPinpadEntry(bool isOnline) async {
    final pinEntryParameters = PinEntryParameters(
      timeout: 60,
      pinRSAData: null,
      allowedLength: [0, 4, 8, 23, 13, 6],
    );
    try {
      final pinKey = _pinArgs?.key;
      if (pinKey == null) {
        throw StateError("missing pinArgs");
      }
      if (isOnline) {
        final onlineParameters = PinOnlineParameters(
          pinKey,
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
    // por aquí se obtiene el PIN Block y el KSN en pinpad
    if (event.pinBlock != null) {
      _pinBlock = event.pinBlock;
    }
    final key = _pinArgs?.key;
    if (key is DUKPTKey && event.pinBlockKSN != null) {
      await cryptoIncrementKSN(key);
      _dukptInputCounter += 1;
      _currentKsn = event.pinBlockKSN;
    }
    await emvCompleteOnline(EmvOnlineResponse(
      authorisationResponseCode: "00",
    ));
  }

  void _onEmvFinished(EmvFinishedEvent event) async {
    final pinArgs = _pinArgs;
    if (pinArgs != null) {
      if (pinArgs.key is DUKPTKey) {
        await _runDukptPinTest(pinArgs);
      } else {
        await _runFixedPinTest(pinArgs);
      }
    }
  }

  Future<void> _runFixedPinTest(PinTestArgs pinArgs) async {
    Uint8List? encryptedPinBlock = _pinBlock;
    if (encryptedPinBlock != null) {
      String fixedPIN = _extractPin(
        pinArgs.key.type,
        pinArgs.keyClearData,
        encryptedPinBlock,
      );
      await showPinOnlineDialog(
        context,
        "${getLocalizations(context).pinOnlineTestOk}: $fixedPIN",
      );
      Navigator.pop(context);
    }
  }

  // Para la prueba de PIN Online con llave DUKPT, se repite el proceso de
  // ingreso de PIN 3 veces, con la misma llave y el mismo monto para validar
  // el PIN Block y el KSN con 3 derivaciones de la misma llave.
  Future<void> _runDukptPinTest(PinTestArgs pinArgs) async {
    int counter = _dukptInputCounter;
    if (counter <= dukptMaxCounter) {
      Uint8List? encryptedPinBlock = _pinBlock;
      Uint8List? currentKsn = _currentKsn;
      if (encryptedPinBlock != null && currentKsn != null) {
        final derivateKey = _deriveDUKPTKey(
          pinArgs.key as DUKPTKey,
          pinArgs.keyClearData,
          currentKsn,
        );
        String fixedPIN = _extractPin(
          pinArgs.key.type,
          derivateKey,
          encryptedPinBlock,
        );
        final success = await showPinOnlineDialog(
          context,
          "${getLocalizations(context).pinOnlineTestOk}: $fixedPIN",
          messageChanged: "PIN Online - Intento $counter",
        );
        if (success == true) {
          if (counter < dukptMaxCounter) {
            _pinTextController.text = "";
            setState(() {
              // cambiamos este flag para que arranque de nuevo la transacción
              _detectionStarted = false;
              _remainingPinTries = null;
            });
          } else {
            await showInfoDialog(context,
                "PIN ONLINE - DUKPT: ${getLocalizations(context).approved}");
            Navigator.pop(context);
          }
        } else {
          await showInfoDialog(
              context, "PIN ONLINE DUKPT: ${getLocalizations(context).failed}");
          Navigator.pop(context);
        }
      }
    } else {
      await showInfoDialog(
          context, "${getLocalizations(context).pinOnlineTestOk}: false");
      Navigator.pop(context);
    }
  }

  String _extractPin(
    KeyType keyType,
    Uint8List clearKeyData,
    Uint8List encryptedPinBlock,
  ) {
    switch (keyType) {
      case KeyType.DES:
        return Iso9564.format0.extractPIN(
          clearKeyData,
          encryptedPinBlock,
          AppConfig.clearTestPAN,
        );
      case KeyType.AES:
        return Iso9564.format4.extractPIN(
          clearKeyData,
          encryptedPinBlock,
          AppConfig.clearTestPAN,
        );
    }
  }

  /// Obtiene la llave DUKPT derivada de acuerdo a la inicial y el KSN actual
  Uint8List _deriveDUKPTKey(
    DUKPTKey pinKey,
    Uint8List keyClearData,
    Uint8List currentKsn,
  ) {
    switch (pinKey.type) {
      case KeyType.DES:
        return dukptDerivePinKey(keyClearData, currentKsn);
      case KeyType.AES:
        return AESDUKPT.algorithm.deriveWorkingKey(
          keyClearData,
          currentKsn,
          DerivationKeyType.AES128,
          DerivationKeyUsage.PINEncryption,
          DerivationKeyType.AES128,
        );
    }
  }
}
