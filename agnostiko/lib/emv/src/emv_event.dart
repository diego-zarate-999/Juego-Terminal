import 'dart:typed_data';

import 'emv_candidate_app.dart';
import '../../ped/ped.dart';

class IEmvEvent {
  IEmvEvent();

  factory IEmvEvent.fromJson(Map<String, dynamic> jsonData) {
    final eventName = jsonData["eventName"];
    if (eventName is String) {
      if (eventName == EmvCandidateListEvent.eventName) {
        return EmvCandidateListEvent.fromJson(jsonData);
      } else if (eventName == EmvAppSelectedEvent.eventName) {
        return EmvAppSelectedEvent.fromJson(jsonData);
      } else if (eventName == EmvPinRequestedEvent.eventName) {
        return EmvPinRequestedEvent.fromJson(jsonData);
      } else if (eventName == EmvPinpadEntryEvent.eventName) {
        return EmvPinpadEntryEvent.fromJson(jsonData);
      } else if (eventName == EmvOnlineRequestedEvent.eventName) {
        return EmvOnlineRequestedEvent.fromJson(jsonData);
      } else if (eventName == EmvFinishedEvent.eventName) {
        return EmvFinishedEvent.fromJson(jsonData);
      }
    }
    throw StateError(
      "El valor de 'eventName' no es correcto para crear el evento.",
    );
  }
}

/// Evento recibido para seleccionar una app AID de la lista de candidatos.
///
/// Tras recibir este evento, se debe llamar [emvSelectCandidate] con el índice
/// de la app que se desea seleccionar de acuerdo al usuario.
///
/// Este evento solo se dispara si hay más de una app a seleccionar entre el
/// terminal y la tarjeta.
class EmvCandidateListEvent extends IEmvEvent {
  static final eventName = "candidateList";

  final List<EmvCandidateApp> candidateList;

  EmvCandidateListEvent(this.candidateList);

  factory EmvCandidateListEvent.fromJson(Map<String, dynamic> jsonData) {
    final jsonList = jsonData["candidateList"] as List;
    final appList = jsonList
        .map((data) =>
            EmvCandidateApp.fromJson(Map<String, dynamic>.from(data as Map)))
        .toList();
    return EmvCandidateListEvent(appList);
  }

  Map<String, dynamic> toJson() {
    final appList = candidateList.map((data) => data.toJson()).toList();
    return {"eventName": eventName, "candidateList": appList};
  }
}

/// Evento recibido tras el proceso de selección de app en el kernel EMV.
///
/// Tras recibir este evento, se debe llamar [emvConfirmAppSelected] para
/// continuar.
class EmvAppSelectedEvent extends IEmvEvent {
  static final eventName = "appSelected";

  final Uint8List selectedAid;
  final String? appLabel;

  EmvAppSelectedEvent(this.selectedAid, this.appLabel);

  factory EmvAppSelectedEvent.fromJson(Map<String, dynamic> jsonData) {
    return EmvAppSelectedEvent(
      jsonData["selectedAid"],
      jsonData["appLabel"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventName": eventName,
      "selectedAid": selectedAid,
      "appLabel": appLabel,
    };
  }
}

/// Evento recibido cuando el Kernel EMV solicita el ingreso de PIN.
///
/// Tras recibir este evento, se debe llamar [emvCompletePin] con la data de PIN
/// correspondiente para verificación del ICC.
class EmvPinRequestedEvent extends IEmvEvent {
  static final eventName = "pinRequested";

  final bool isOnline;
  final int? remainingTries;
  final PinRSAData? pinRSAData;

  EmvPinRequestedEvent(this.isOnline, this.remainingTries, this.pinRSAData);

  factory EmvPinRequestedEvent.fromJson(Map<String, dynamic> jsonData) {
    final pinRSAData = jsonData['pinRSAData'] != null
        ? PinRSAData.fromJson(
            Map<String, dynamic>.from(jsonData['pinRSAData'] as Map),
          )
        : null;
    return EmvPinRequestedEvent(
      jsonData["isOnline"],
      jsonData["remainingTries"],
      pinRSAData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventName": eventName,
      "isOnline": isOnline,
      "remainingTries": remainingTries,
      "pinRSAData": pinRSAData?.toJson(),
    };
  }
}

/// Evento recibido cuando el kernel solicita el ingreso de pin para Pinpad.
///
/// Tras recibir este evento, se debe llamar [emvConfirmPinpadEntry] con los
/// parámetros a setear para el ingreso de Pin.
class EmvPinpadEntryEvent extends IEmvEvent {
  static final eventName = "pinpadEntry";

  final bool isOnline;

  EmvPinpadEntryEvent(this.isOnline);

  factory EmvPinpadEntryEvent.fromJson(Map<String, dynamic> jsonData) {
    return EmvPinpadEntryEvent(jsonData["isOnline"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "eventName": eventName,
      "isOnline": isOnline,
    };
  }
}

/// Evento recibido cuando el kernel solicita enviar la transacción online.
///
/// Tras recibir este evento, se debe llamar [emvCompleteOnline] con los datos
/// de la respuesta del emisor solicitados para culminar el proceso.
class EmvOnlineRequestedEvent extends IEmvEvent {
  static const eventName = "onlineRequested";
  final Uint8List? pinBlock;
  final Uint8List? pinBlockKSN;

  EmvOnlineRequestedEvent(this.pinBlock, this.pinBlockKSN);

  factory EmvOnlineRequestedEvent.fromJson(Map<String, dynamic> jsonData) {
    return EmvOnlineRequestedEvent(
      jsonData["pinBlock"],
      jsonData["pinBlockKSN"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventName": eventName,
      "pinBlock": pinBlock,
      "pinBlockKSN": pinBlockKSN,
    };
  }
}

/// Resultado de una transacción EMV.
enum EmvTransactionResult {
  /// Transacción aprobada
  Approved,

  /// Transacción declinada
  Denied,

  /// El kernel indica fallback, la aplicación debe elegir si lo aplica
  Fallback,

  /// Falló contactless e indica que se intente con otra interfaz (ej. contacto)
  TryAnother,

  /// Código de error genérico
  Fail,

  /// Fallo al comunicarse con la tarjeta (se retiró o desconectó)
  CmdError,

  /// Aplicación EMV bloqueada
  AppBlock,

  /// Tarjeta bloqueada
  CardBlock,

  /// Indica chequeo de CVM especial en dispositivo de tarjetahabiente
  ReferPaymentDevice,

  /// Timeout de ingreso de PIN en Pinpad
  PinTimeout,

  /// Cancelado el ingreso de PIN en Pinpad
  PinCancel,
}

enum ContactlessKernelType {
  PayPass,
  PayWave,
  Expresspay,
}

/// Información de una transacción EMV culminada.
class EmvTransactionInfo {
  final EmvTransactionResult result;
  final bool pinRequested;
  final bool onlineRequested;
  final Uint8List scriptResults;
  final bool isContactless;
  final ContactlessKernelType? kernelType;

  EmvTransactionInfo({
    required this.result,
    required this.pinRequested,
    required this.onlineRequested,
    required this.scriptResults,
    required this.isContactless,
    this.kernelType,
  });

  Map<String, dynamic> toJson() {
    return {
      "result": result.index,
      "pinRequested": pinRequested,
      "onlineRequested": onlineRequested,
      "scriptResults": scriptResults,
      "isContactless": isContactless,
      "kernelType": kernelType?.index
    };
  }

  factory EmvTransactionInfo.fromJson(Map<String, dynamic> jsonData) {
    int resultCode = jsonData['result'];

    int? kernelTypeCode = jsonData['kernelType'];
    ContactlessKernelType? kernelType = kernelTypeCode != null
        ? ContactlessKernelType.values[kernelTypeCode]
        : null;

    return EmvTransactionInfo(
      result: EmvTransactionResult.values[resultCode],
      pinRequested: jsonData['pinRequested'],
      onlineRequested: jsonData['onlineRequested'],
      scriptResults: jsonData['scriptResults'],
      isContactless: jsonData['isContactless'],
      kernelType: kernelType,
    );
  }
}

/// Evento recibido cuando se ha culminado el proceso de transacción EMV.
class EmvFinishedEvent extends IEmvEvent {
  static final eventName = "finished";

  final EmvTransactionInfo transactionInfo;

  EmvFinishedEvent(this.transactionInfo);

  factory EmvFinishedEvent.fromJson(Map<String, dynamic> jsonData) {
    final newMap =
        Map<String, dynamic>.from(jsonData["transactionInfo"] as Map);
    return EmvFinishedEvent(
      EmvTransactionInfo.fromJson(newMap),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventName": eventName,
      "transactionInfo": transactionInfo.toJson(),
    };
  }
}
