import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';

import '../../mpos/mpos.dart';
import '../../ped/src/pin_entry.dart';
import '../../utils/utils.dart';
import 'emv_event.dart';

const emvEventsChannel = const HybridEventChannel('agnostiko/EmvEvents');
const emvTransactionChannel =
    const HybridMethodChannel('agnostiko/EmvTransaction');

StreamSubscription<dynamic>? _emvEventsSubscription;
BehaviorSubject<IEmvEvent>? _streamController;

// Contiene valores númericos para setear el tipo de transacción (Tag 9C).
abstract class EmvTransactionType {
  static const int Goods = 0x00;
  static const int Cash = 0x01;
  static const int Cashback = 0x09;
  static const int Inquiry = 0x31;
  static const int Transfer = 0x40;
  static const int Payment = 0x50;
  static const int Refund = 0x20;
  static const int Void = 0x02;
}

/// Parámetros específicos de transacción EMV.
class EmvTransactionParameters {
  /// Tag 9C - Transaction Type
  ///
  /// "Indica el tipo de transacción financiera, representada por los 2 primeros
  /// dígitos del 'Processing Code' de ISO 8583:1987" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 1 byte - Formato: n 2
  final int transactionType;

  /// Tag 9F41 - Transaction Sequence Counter
  ///
  /// "Contador mantenido por el terminal que es incrementado por 1 para cada
  /// transacción" - Fuente: emvlab.org
  int transactionSequenceCounter;

  /// Monto principal de transacción.
  int amount;

  /// Monto secundario de Cashback.
  int? amountOther;

  bool forceOnline;

  /// Este modo solo debe ser usado para develop
  /// ADVERTENCIA: no usar en producción
  bool debugMode;

  EmvTransactionParameters({
    required this.transactionType,
    required this.transactionSequenceCounter,
    required this.amount,
    this.amountOther,
    this.forceOnline = false,
    this.debugMode = false,
  });

  factory EmvTransactionParameters.fromJson(Map<String, dynamic> jsonData) {
    return EmvTransactionParameters(
      transactionType: jsonData['transactionType'],
      transactionSequenceCounter: jsonData['transactionSequenceCounter'],
      amount: jsonData['amount'],
      amountOther: jsonData['amountOther'],
      forceOnline: jsonData['forceOnline'],
      debugMode: jsonData['debugMode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionType': transactionType,
      'transactionSequenceCounter': transactionSequenceCounter,
      'amount': amount,
      'amountOther': amountOther,
      'forceOnline': forceOnline,
      'debugMode': debugMode,
    };
  }
}

/// Inicia una transacción EMV utilizando el Kernel nativo según aplique.
///
/// Este método retorna un Stream que puede ser escuchado múltiples veces y
/// donde se van recibiendo los distintos eventos sucitados durante la
/// transacción EMV.
///
/// Los tipos de eventos que se pueden recibir en dicho Stream son:
///  -[EmvAppSelectedEvent]
///  -[EmvPinRequestedEvent]
///  -[EmvPinpadEntryEvent]
///  -[EmvOnlineRequestedEvent]
///  -[EmvFinishedEvent]
Stream<IEmvEvent> startEmvTransaction(
    EmvTransactionParameters transactionParameters) {
  final streamController = BehaviorSubject<IEmvEvent>();

  if (_emvEventsSubscription != null) {
    throw StateError("Ya hay una transacción EMV en proceso." +
        "Debe cancelarla antes de iniciar otra.");
  }

  if (transactionParameters.transactionType != EmvTransactionType.Cashback) {
    transactionParameters.amountOther = null;
  }

  final args = transactionParameters.toJson();

  _emvEventsSubscription = emvEventsChannel.receiveBroadcastStream(args).listen(
    (data) {
      final jsonObj = Map<String, dynamic>.from(data as Map);
      final event = IEmvEvent.fromJson(jsonObj);

      streamController.add(event);
      if (event is EmvFinishedEvent) {
        streamController.close();
        _emvEventsSubscription = null;
      }
    },
    onError: (Object error, StackTrace stackTrace) {
      streamController.addError(error, stackTrace);
      streamController.close();
      _emvEventsSubscription = null;
    },
    onDone: () {
      streamController.close();
      _emvEventsSubscription = null;
    },
    cancelOnError: true,
  );

  _streamController = streamController;
  return streamController.stream;
}

/// Selecciona mediante el índice una app EMV de la lista de candidatos.
///
/// Se debe pasar la selección del usuario en [candidateIndex] para
/// continuar la transacción con la app EMV correspondiente.
Future<void> emvSelectCandidate(int candidateIndex) async {
  await emvTransactionChannel.invokeMethod("selectCandidate", candidateIndex);
}

/// Confirma al Kernel la continuación del proceso tras la selección de App.
Future<void> emvConfirmAppSelected() async {
  await emvTransactionChannel.invokeMethod("confirmAppSelected");
}

/// Envía al Kernel el resultado de la verificación de PIN.
///
/// Si [pinResult] se pasa como 'null', se interpreta como error al ingresar
/// el PIN. Si [pinResult] es un [Uint8List] vacío, se aplica el proceso de
/// 'bypass' del PIN (el usuario decidió continuar si ingresar ningún dígito).
Future<void> emvCompletePin(Uint8List? pinResult) async {
  await emvTransactionChannel.invokeMethod("completePin", pinResult);
}

/// Envía al Kernel los párametros asociados al ingreso de PIN para Pinpad
Future<void> emvConfirmPinpadEntry(
  PinEntryParameters pinEntryParameters, [
  PinOnlineParameters? pinOnlineParameters,
]) async {
  final entryParameters = pinEntryParameters.toJson();
  final onlineParameters = pinOnlineParameters?.toJson();
  final Map<String, dynamic> args = {
    'pinEntryParameters': entryParameters,
    'pinOnlineParameters': onlineParameters,
  };
  await emvTransactionChannel.invokeMethod("confirmPinpadEntry", args);
}

/// Respuesta de una transacción EMV procesada En Línea.
class EmvOnlineResponse {
  /// Tag 8A - Authorisation Response Code
  ///
  /// "Código que define la disposición de un mensaje" - Fuente: emvlab.org
  ///
  /// Ej: "00" para operación exitosa. Este dato por lo general se recibe en el
  /// campo 39 de un mensaje ISO8583 de respuesta.
  ///
  /// Longitud permitida: 2 caracteres - Formato: an
  String authorisationResponseCode;

  /// Tag 89 - Authorisation Code
  ///
  /// "Valor generado por la autoridad de autorización para una transacción
  /// aprobada" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 6 caracteres - Formato: Definido por sistema de pagos
  String? authorisationCode;

  /// Tag 91 - Issuer Authentication Data
  ///
  /// "Data enviada al ICC para autenticación en línea del emisor" - Fuente:
  /// emvlab.org
  ///
  /// Longitud permitida: 8-16 bytes - Formato: b
  Uint8List? issuerAuthenticationData;

  /// Tag 71 - Issuer Script Template 1
  ///
  /// "Contiene datos propietarios del emisor para transmitir al ICC antes del
  /// segundo comando GENERATE AC" - Fuente: emvlab.org
  ///
  /// Longitud permitida: var. - Formato: b
  Uint8List? issuerScript1;

  /// Tag 72 - Issuer Script Template 2
  ///
  /// "Contiene datos propietarios del emisor para transmitir al ICC después del
  /// segundo comando GENERATE AC" - Fuente: emvlab.org
  ///
  /// Longitud permitida: var. - Formato: b
  Uint8List? issuerScript2;

  EmvOnlineResponse({
    required String authorisationResponseCode,
    String? authorisationCode,
    Uint8List? issuerAuthenticationData,
    this.issuerScript1,
    this.issuerScript2,
  })  : this.authorisationResponseCode = assertFixedLen(
          authorisationResponseCode,
          "authorizationResponseCode",
          2,
        ),
        this.authorisationCode = assertFixedLen(
          authorisationCode,
          "authorizationCode",
          6,
        ),
        this.issuerAuthenticationData = assertVarLen(
          issuerAuthenticationData,
          "issuerAuthenticationData",
          minLen: 8,
          maxLen: 16,
        );

  Map<String, dynamic> toJson() {
    return {
      'authorisationResponseCode': authorisationResponseCode,
      'authorisationCode': authorisationCode,
      'issuerAuthenticationData': issuerAuthenticationData,
      'issuerScript1': issuerScript1,
      'issuerScript2': issuerScript2,
    };
  }
}

/// Envía al Kernel los tags de la respuesta Online del emisor.
Future<void> emvCompleteOnline(EmvOnlineResponse onlineResponse) async {
  await emvTransactionChannel.invokeMethod(
    "completeOnline",
    onlineResponse.toJson(),
  );
}

/// Cancela la transacción EMV activa.
Future<void> cancelEmvTransaction() async {
  if (Platform.isLinux) {
    await emvTransactionChannel.invokeMethod("cancelEmvTransaction");
  }
  await _streamController?.close();
  await _emvEventsSubscription?.cancel();
  _streamController = null;
  _emvEventsSubscription = null;
}
