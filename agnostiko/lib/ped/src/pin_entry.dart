import 'dart:async';
import 'package:meta/meta.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:rxdart/rxdart.dart';

const pinEntryEventsChannel =
    const HybridEventChannel('agnostiko/PinEntryEvents');

const pinEntryMethodsChannel =
    const HybridMethodChannel('agnostiko/PinEntryMethods');

StreamSubscription<dynamic>? _pinEntryEventsSubscription;
BehaviorSubject<IPinEvent>? _streamController;

/// Datos de llave pública para encriptado de PIN offline.
class PinRSAData {
  final Uint8List modulus;
  final Uint8List exponent;
  final Uint8List iccChallenge;

  PinRSAData(this.modulus, this.exponent, this.iccChallenge);

  Map<String, dynamic> toJson() {
    return {
      "modulus": modulus,
      "exponent": exponent,
      "iccChallenge": iccChallenge
    };
  }

  factory PinRSAData.fromJson(Map<String, dynamic> jsonData) {
    return PinRSAData(
      jsonData['modulus'],
      jsonData['exponent'],
      jsonData['iccChallenge'],
    );
  }
}

/// Configuración de ingreso de PIN con módulo PED nativo.
class PinEntryParameters {
  /// Tiempo máximo de espera para ingreso.
  final int timeout;

  /// Datos para encriptado de PIN offline bajo proceso de PIN cifrado.
  final PinRSAData? pinRSAData;

  /// Longitudes de PIN permitidas para el ingreso.
  ///
  /// Debe ser una lista con uno o varios de los siguientes valores:
  /// (0, 4, 5, 6, 7, 8, 9, 10, 11, 12)
  ///
  /// Por ejemplo, si se pasa la lista: (4, 6, 8) significa que el usuario
  /// puede ingresar PINs con longitud de 4, 6 u 8 dígitos.
  ///
  /// El valor '0', habilita el 'PIN Bypass' para poder saltar la verificación.
  final List<int>? allowedLength;

  PinEntryParameters({
    required int timeout,
    this.pinRSAData,
    List<int>? allowedLength,
  })  : this.timeout = assertValueInRange(
          timeout,
          "timeout",
          minVal: 5,
          maxVal: 200,
        ),
        // se filtran los valores no válidos para longitudes de PIN
        this.allowedLength = allowedLength
            ?.where(
              (element) => (element == 0) || (element >= 4 && element <= 12),
            )
            .toList();

  factory PinEntryParameters.fromJson(Map<String, dynamic> jsonData) {
    final rsaDataObj = jsonData["pinRSAData"];
    final allowedLengthArray = jsonData["allowedLength"] as List?;
    final list = allowedLengthArray?.map((it) => it as int).toList();

    return PinEntryParameters(
        timeout: jsonData["timeout"],
        pinRSAData: rsaDataObj != null
            ? PinRSAData.fromJson(Map<String, dynamic>.from(rsaDataObj as Map))
            : null,
        allowedLength: list);
  }

  Map<String, dynamic> toJson() {
    return {
      "timeout": timeout,
      "pinRSAData": pinRSAData?.toJson(),
      "allowedLength": allowedLength,
    };
  }
}

/// Configuración para manejo de PIN online con módulo PED nativo.
class PinOnlineParameters {
  /// Info de llave para encriptado del PIN Block
  final SymmetricKey key;

  /// Valor de PAN para generar el PIN Block (obligatorio en POS solamente)
  ///
  /// Para Pinpad puede estar vacío (o contener cualquier valor en realidad)
  /// ya que el kernel obtiene el PAN por otro lado y no utiliza este parámetro
  final String pan;

  PinOnlineParameters(this.key, {required this.pan});

  Map<String, dynamic> toJson() {
    return {
      "key": key.toJson(),
      "pan": pan,
    };
  }
}

/// Inicia un ingreso de PIN Offline utilizando el módulo PED nativo.
///
/// Este método retorna un Stream que puede ser escuchado múltiples veces y
/// donde se van recibiendo los distintos eventos sucitados durante el ingreso
/// de PIN.
///
/// La longitud actual del valor ingresado se notifica mediante eventos de tipo
/// [PinInputChangedEvent].
///
/// El proceso culmina con uno de los siguientes eventos:
///  -[PinCancelledEvent] si se canceló el ingreso.
///  -[PinTimeoutEvent] si se agotó el tiempo límite de espera.
///  -[PinFinishedEvent] si se llevó a cabo la validación de PIN.
Stream<IPinEvent> startOfflinePinEntry(PinEntryParameters pinEntryParameters) {
  return _startPinEntry(pinEntryParameters);
}

/// Inicia un ingreso de PIN Online utilizando el módulo PED nativo.
///
/// Este método retorna un Stream que puede ser escuchado múltiples veces y
/// donde se van recibiendo los distintos eventos sucitados durante el ingreso
/// de PIN.
///
/// Si la llave utilizada es DUKPT, el KSN se incrementa automáticamente tras
/// el resultado de la encripción.
///
/// La longitud actual del valor ingresado se notifica mediante eventos de tipo
/// [PinInputChangedEvent].
///
/// El proceso culmina con uno de los siguientes eventos:
///  -[PinCancelledEvent] si se canceló el ingreso.
///  -[PinTimeoutEvent] si se agotó el tiempo límite de espera.
///  -[PinFinishedEvent] si se llevó a cabo la validación de PIN.
@experimental
Stream<IPinEvent> startOnlinePinEntry(
  PinEntryParameters entryParameters,
  PinOnlineParameters onlineParameters,
) {
  return _startPinEntry(entryParameters, pinOnlineParameters: onlineParameters);
}

Stream<IPinEvent> _startPinEntry(PinEntryParameters pinEntryParameters,
    {PinOnlineParameters? pinOnlineParameters}) {
  final streamController = BehaviorSubject<IPinEvent>();

  if (_pinEntryEventsSubscription != null) {
    throw StateError("Ya hay un ingreso de PIN en proceso." +
        "Debe cancelarlo antes de iniciar otro.");
  }

  final entryParameters = pinEntryParameters.toJson();
  final onlineParameters = pinOnlineParameters?.toJson();
  final Map<String, dynamic> args = {
    'pinEntryParameters': entryParameters,
    'pinOnlineParameters': onlineParameters,
  };
  _pinEntryEventsSubscription =
      pinEntryEventsChannel.receiveBroadcastStream(args).listen(
    (data) {
      final jsonObj = Map<String, dynamic>.from(data as Map);
      final event = IPinEvent.fromJson(jsonObj);

      streamController.add(event);
      // cualquiera de estos eventos es de cierre de proceso
      if (event is PinCancelledEvent ||
          event is PinTimeoutEvent ||
          event is PinFinishedEvent) {
        streamController.close();
        _pinEntryEventsSubscription = null;
      }
    },
    onError: (Object error, StackTrace stackTrace) {
      streamController.addError(error, stackTrace);
      streamController.close();
      _pinEntryEventsSubscription = null;
      if (Platform.isLinux) {
        pinEntryMethodsChannel.invokeMethod("cancelPinEntry");
      }
    },
    onDone: () {
      streamController.close();
      _pinEntryEventsSubscription = null;
    },
    cancelOnError: true,
  );

  _streamController = streamController;
  return streamController.stream;
}

/// Cancela programáticamente un ingreso de PIN activo.
Future<void> cancelPinEntry() async {
  if (Platform.isLinux) {
    await pinEntryMethodsChannel.invokeMethod("cancelPinEntry");
  }
  await _streamController?.close();
  await _pinEntryEventsSubscription?.cancel();
  _streamController = null;
  _pinEntryEventsSubscription = null;
}
