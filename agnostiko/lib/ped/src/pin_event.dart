import 'dart:typed_data';

import '../../utils/utils.dart';

/// Evento suscitado durante el ingreso de PIN.
abstract class IPinEvent {
  IPinEvent();

  factory IPinEvent.fromJson(Map<String, dynamic> jsonData) {
    final eventName = jsonData["eventName"];
    if (eventName is String) {
      if (eventName == PinCancelledEvent.eventName) {
        return PinCancelledEvent();
      } else if (eventName == PinTimeoutEvent.eventName) {
        return PinTimeoutEvent();
      } else if (eventName == PinInputChangedEvent.eventName) {
        return PinInputChangedEvent.fromJson(jsonData);
      } else if (eventName == PinFinishedEvent.eventName) {
        return PinFinishedEvent.fromJson(jsonData);
      }
    }
    throw StateError(
      "El valor de 'eventName' no es correcto para crear el evento.",
    );
  }

  Map<String, dynamic> toJson();
}

/// Ingreso de PIN cancelado.
class PinCancelledEvent extends IPinEvent {
  static final eventName = "cancelled";

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

/// Se agotó el tiempo de espera para el ingreso de PIN.
class PinTimeoutEvent extends IPinEvent {
  static final eventName = "timeout";

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

/// Cambió la longitud del PIN en el PinPad (por ingreso del usuario).
class PinInputChangedEvent extends IPinEvent {
  static final eventName = "inputChanged";

  /// Longitud actual del PIN en el PinPad interno.
  final int inputLength;

  PinInputChangedEvent(this.inputLength);

  factory PinInputChangedEvent.fromJson(Map<String, dynamic> jsonData) {
    return PinInputChangedEvent(jsonData["inputLength"]);
  }

  Map<String, dynamic> toJson() {
    return {"eventName": eventName, "inputLength": inputLength};
  }
}

/// Se llevó a cabo la verificación de PIN.
class PinFinishedEvent extends IPinEvent {
  static const eventName = "finished";

  /// PIN block (PIN Online) o resultado de PIN (PIN Offline)
  ///
  /// Para PIN Offline:
  /// Resultado de la verificación de PIN como Status Word (SW).
  /// Este valor es para validación por parte de la tarjeta y debe compartirse
  /// al kernel EMV mediante [emvCompletePin].
  ///
  /// Para PIN Online:
  /// PIN block encriptado para enviar al host para autorización.
  @Deprecated("Use 'pinBlock' value instead")
  final Uint8List pinResultSw;

  /// PIN block (PIN Online) o resultado de PIN (PIN Offline)
  ///
  /// En caso de bypass (si se permitió al inicializar el ingreso de PIN), este
  /// valor será un [Uint8List] vacío.
  ///
  /// Para PIN Offline:
  /// Resultado de la verificación de PIN como Status Word (SW).
  /// Este valor es para validación por parte de la tarjeta y debe compartirse
  /// al kernel EMV mediante [emvCompletePin].
  ///
  /// Para PIN Online:
  /// PIN block encriptado para enviar al host para autorización. Igualmente
  /// debe enviarse al kernel EMV mediante [emvCompletePin] para que sepa que
  /// debe continuar la transacción con ingreso de PIN realizado.
  final Uint8List pinBlock;

  /// Valor de KSN en caso que el PIN Block haya sido encriptado bajo DUKPT
  final Uint8List? ksn;

  PinFinishedEvent(this.pinResultSw, this.pinBlock, this.ksn);

  factory PinFinishedEvent.fromJson(Map<String, dynamic> jsonData) {
    return PinFinishedEvent(
      jsonData['pinResultSw'],
      jsonData['pinBlock'],
      jsonData['ksn'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "eventName": eventName,
      "pinResultSw": pinResultSw,
      "pinBlock": pinBlock,
      "ksn": ksn,
    };
  }
}
