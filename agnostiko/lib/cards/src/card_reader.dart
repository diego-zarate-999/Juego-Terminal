import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:rxdart/rxdart.dart';

/// Tipos de tarjeta detectables mediante la librería universal.
enum CardType { Magnetic, IC, RF, SAM }

enum IcSlot { IC1, SAM1, SAM2, SAM3, SAM4 }

/// Info de los tracks leídos de una banda magnética.
///
/// Ya que esta clase se usa como resultado de la lectura de una banda
/// magnética, se debe tener en cuenta que los valores de los tracks pueden ser
/// 'null'.
class TracksData {
  final String? track1;
  final String? track2;
  final String? track3;

  const TracksData({this.track1, this.track2, this.track3});

  factory TracksData.fromJson(Map<String, dynamic> data) {
    return TracksData(
      track1: data['track1'],
      track2: data['track2'],
      track3: data['track3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"track1": track1, "track2": track2, "track3": track3};
  }
}

const cardEventsChannel = const HybridEventChannel('agnostiko/CardEvents');
const cardMethodsChannel = const HybridMethodChannel('agnostiko/CardMethods');

StreamSubscription<dynamic>? _cardReaderSubscription;
BehaviorSubject<CardDetectedEvent>? _streamController;
Timer? _timeoutController;

/// Evento de tarjeta de pagos detectada.
class CardDetectedEvent {
  /// Tipo de tarjeta detectada.
  final CardType cardType;

  /// Data de los Tracks leídos si la tarjeta es de tipo: [CardType.Magnetic].
  final TracksData? tracksData;

  const CardDetectedEvent(this.cardType, {this.tracksData});
}

/// Activa el módulo de detección de tarjetas de manera configurable.
///
/// Esto permite reaccionar a los eventos disparados cuando el usuario desliza
/// una tarjeta de banda o ingresa una de chip por ejemplo.
///
/// Con [cardTypes] se puede parametrizar los tipos de tarjeta que se desean
/// detectar.
///
/// Este método genera un Stream el cuál dispara un evento [CardDetectedEvent]
/// para indicar el tipo de tarjeta detectada.
///
/// Se puede establecer un [timeout] (en Segundos) para el proceso. Si no se
/// establece el valor de dicho parámetro o el valor es '0', entonces el
/// proceso correrá indefinidamente hasta que haya una detección o se cancele.
///
/// Se dispara un [TimeoutException] si se supera el [timeout] sin detectar una
/// tarjeta.
Stream<CardDetectedEvent> openCardReader({
  required List<CardType> cardTypes,
  int timeout = 0,
}) {
  if (_cardReaderSubscription != null) {
    throw StateError("La lectura de tarjetas ya está activada." +
        "Debe cancelar la subscripción activa antes de crear otra.");
  }

  final streamController = BehaviorSubject<CardDetectedEvent>();

  final cardTypesInt = cardTypes.map((val) => val.index).toList();
  final args = {'cardTypes': cardTypesInt};
  _cardReaderSubscription =
      cardEventsChannel.receiveBroadcastStream(args).listen(
    (result) {
      final resultMap = result as Map;
      final int cardTypeCode = resultMap["cardType"] as int;
      final CardType cardType = CardType.values[cardTypeCode];

      switch (cardType) {
        case CardType.Magnetic:
          final tracksDataMap = Map<String, dynamic>.from(
            resultMap["tracksData"],
          );
          final tracksData = TracksData.fromJson(tracksDataMap);
          streamController.add(CardDetectedEvent(
            cardType,
            tracksData: tracksData,
          ));
          break;
        case CardType.IC:
        case CardType.RF:
          streamController.add(CardDetectedEvent(cardType));
          break;
        case CardType.SAM:
          streamController.add(CardDetectedEvent(cardType));
          break;
      }
      closeCardReader();
    },
    onError: (dynamic error, StackTrace stackTrace) {
      streamController.addError(error, stackTrace);
      streamController.close();
      _cardReaderSubscription = null;
    },
    onDone: () {
      streamController.close();
      _cardReaderSubscription = null;
    },
    cancelOnError: true,
  );

  // habilitamos el timeout si aplica. 0 significa que no se usa timeout
  if (timeout > 0) {
    _timeoutController = Timer(Duration(seconds: timeout), () {
      streamController.addError(TimeoutException("CardReader timeout"));
      closeCardReader();
    });
  }
  _streamController = streamController;
  return streamController.stream;
}

/// Cierra la detección de tarjetas si se encuentra activa.
Future<void> closeCardReader() async {
  if (Platform.isLinux) {
    await cardMethodsChannel.invokeMethod("closeCardReader");
  }
  _timeoutController?.cancel();
  _timeoutController = null;
  await _streamController?.close();
  await _cardReaderSubscription?.cancel();
  _streamController = null;
  _cardReaderSubscription = null;
}

/// Espera hasta que se retira del terminal una tarjeta IC insertada.
///
/// Este método solo se debería llamarse luego de ser detectada una tarjeta de
/// tipo [CardType.IC] para poder determinar cuando la misma ha sido retirada
/// del lector.
Future<void> waitUntilICCardRemoved() async {
  await cardMethodsChannel.invokeMethod("waitUntilICCardRemoved");
}

/// Espera hasta que se retira del terminal una tarjeta RF detectada.
///
/// Este método solo se debería llamarse luego de ser detectada una tarjeta de tipo
/// [CardType.RF] para poder determinar cuando la misma ha sido retirada del
/// campo de detección. Por lo general, esto se utiliza durante transacciones
/// EMV Contactless para esperar a que el usuario retire la tarjeta.
Future<void> waitUntilRFCardRemoved() async {
  await cardMethodsChannel.invokeMethod("waitUntilRFCardRemoved");
}

/// Data de tracks de banda magnética encriptados con llave DUKPT
///
/// Ya que esta clase se usa como resultado de la lectura de una banda
/// magnética, se debe tener en cuenta que los valores de los tracks pueden ser
/// 'null'.
class DUKPTEncryptedTracksData {
  final DUKPTResult? track1;
  final DUKPTResult? track2;
  final DUKPTResult? track3;

  /// PAN enmascarado con los 6 primeros y 4 últimos dígitos visibles
  ///
  /// Ej: '541333******4111'. Esto es válido de acuerdo al requerimiento 3.3 de
  /// PCI DSS.
  final String? maskPAN;

  /// Código de servicio en claro
  final String? serviceCode;

  const DUKPTEncryptedTracksData(
    this.track1,
    this.track2,
    this.track3,
    this.maskPAN,
    this.serviceCode,
  );

  factory DUKPTEncryptedTracksData.fromJson(Map<String, dynamic> data) {
    final track1 = data['track1'];
    final track2 = data['track2'];
    final track3 = data['track3'];
    return DUKPTEncryptedTracksData(
      track1 != null
          ? DUKPTResult.fromJson(Map<String, dynamic>.from(track1))
          : null,
      track2 != null
          ? DUKPTResult.fromJson(Map<String, dynamic>.from(track2))
          : null,
      track3 != null
          ? DUKPTResult.fromJson(Map<String, dynamic>.from(track3))
          : null,
      data['maskPAN'],
      data['serviceCode'],
    );
  }

  Map<String, dynamic> toJson() {
    final track1Json = track1 != null ? track1?.toJson() : null;
    final track2Json = track2 != null ? track2?.toJson() : null;
    final track3Json = track3 != null ? track3?.toJson() : null;

    return {
      "track1": track1Json,
      "track2": track2Json,
      "track3": track3Json,
      "maskPan": maskPAN,
      "serviceCode": serviceCode
    };
  }
}

/// Obtiene los tracks de banda magnética en claro
Future<TracksData?> getTracksData() async {
  final result = await cardMethodsChannel.invokeMethod('getTracksData');
  if (result != null) {
    return TracksData.fromJson(Map<String, dynamic>.from(result));
  }
  return null;
}

/// Obtiene los tracks magnéticos encriptados con llave DUKPT y algoritmo 3DES
///
/// Este método permite obtener directamente valores encriptados sin manejar
/// la data en claro lo cual es especialmente necesario para seguridad en mPOS
///
/// Si el número de bytes del valor no es divisible por el tamaño de bloque
/// se paddea con 0xFF a la derecha hasta completar una longitud correcta
/// para el encriptado
Future<DUKPTEncryptedTracksData?> getDUKPTEncryptedTracksData(
  int keyIndex,
  CipherMode cipherMode, [
  Uint8List? iv,
]) async {
  final result =
      await cardMethodsChannel.invokeMethod('getDUKPTEncryptedTracksData', {
    "keyIndex": keyIndex,
    "cipherMode": cipherMode.index,
    "iv": iv,
  });
  if (result != null) {
    return DUKPTEncryptedTracksData.fromJson(Map<String, dynamic>.from(result));
  }
  return null;
}

/// Envía [cmd] a tarjetas contactless y recibe la respuesta de la misma
///
/// Se recomienda el envío de comandos nativos envueltos en ISO/IEC 7816-4, ya
/// que, son soportados en todas las marcas, mientras que los comandos en
/// formato nativo, son soportados solo en algunas.
///
/// Nota: antes de utilizar este método se debe haber detectado la tarjeta de
/// tipo [CardType.RF]. Se debe esperar que este método se termine de ejecutar
/// antes de invocarlo nuevamente, ya que la ejecución siempre debe ser
/// secuencial.
Future<Uint8List> sendCommandRF(Uint8List cmd) async {
  return await cardMethodsChannel.invokeMethod("sendCommandRF", cmd);
}

/// Envía [cmd] y [icSlot] a tarjetas IC y recibe la respuesta de la misma
///
/// Se recomienda el envío de comandos nativos envueltos en ISO/IEC 7816-4, ya
/// que, son soportados en todas las marcas, mientras que los comandos en
/// formato nativo, son soportados solo en algunas.
///
/// Nota: antes de utilizar este método se debe haber hecho el metodo initIC()
/// con el puerto [icSlot] equivalente en que se encuentra la tarjeta a utilizar
/// antes de invocarlo nuevamente, se pueden lanzar varios comandos despues de
/// hacer el initIC()
Future<Uint8List> sendCommandIC(Uint8List cmd, IcSlot icSlot) async {
  return await cardMethodsChannel.invokeMethod("sendCommandIC", {
    "command": cmd,
    "icSlot": icSlot.index,
  });
}

/// Envía [icSlot] para iniciar coneccion con tarjetas IC y poder enviar
/// comandos con el metodo de sendCommandIC()
///
/// Se recomienda verificar la ranura en la que se coloco la tarjeta deseada
/// ya que puede no coincidir la etiqueta del dispositivo con la ranura en
/// el software
///
Future<void> initIC(IcSlot icSlot) async {
  return await cardMethodsChannel.invokeMethod(
    "initIC",
    icSlot.index,
  );
}
