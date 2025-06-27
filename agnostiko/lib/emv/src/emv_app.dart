import 'dart:typed_data';
import '../../utils/utils.dart';

/// Configuración de parámetros de una app EMV (AID) para manejo del kernel.
class EmvApp {
  /// Tag 9F06 - Application Identifier (AID) - terminal
  ///
  /// "Identifica la aplicación como se describe en ISO/IEC 7816-5" - Fuente:
  /// emvlab.org
  ///
  /// Longitud permitida: 5-16 bytes - Formato: b
  Uint8List aid;

  /// Kernel Identifier
  ///
  /// "Identifica la preferencia del Kernel a utilizar para procesar la
  /// aplicación contactless."
  ///
  /// Longitud permitida: 1 byte
  Uint8List kernelId;

  /// Tag 9F09 - Application Version Number
  ///
  /// "Número de versión asignado por el sistema de pagos para la aplicación" -
  /// Fuente: emvlab.org
  ///
  /// Longitud permitida: 2 bytes - Formato: b
  Uint8List appVersionNum;

  /// Terminal Action Code - Denial
  ///
  /// "Especifica las condiciones del adquiriente que causan el rechazo de una
  /// transacción sin intentar irse en línea" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 5 bytes - Formato: b
  Uint8List tacDenial;

  /// Terminal Action Code - Online
  ///
  /// "Especifica las condiciones del adquiriente que causan que una transacción
  /// sea transmitida en línea" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 5 bytes - Formato: b
  Uint8List tacOnline;

  /// Terminal Action Code - Default
  ///
  /// "Especifica las condiciones del adquiriente que causan que una transacción
  /// sea rechazada si pudo haber sido aprobada en línea, pero el terminal fue
  /// incapaz de procesar la transacción en línea" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 5 bytes - Formato: b
  Uint8List tacDefault;

  /// Tag 9F1B - Terminal Floor Limit
  ///
  /// "Indica el límite de piso en el terminal en conjunto con el AID" - Fuente:
  /// emvlab.org
  ///
  /// Longitud permitida: 4 bytes - Formato: b
  Uint8List? terminalFloorLimit;

  /// Reader Contactless Floor Limit
  ///
  /// "Indica el monto de transacción sobre el cuál las transacciones deben ser
  /// autorizadas en línea" - Fuente: eftlab.com
  ///
  /// Longitud permitida: 6 bytes - Formato: n 12
  Uint8List? contactlessFloorLimit;

  /// Reader Contactless Transaction Limit
  ///
  /// "Indica el monto sobre el cuál la transacción no es permitida." -
  /// Fuente: eftlab.com
  ///
  /// Longitud permitida: 6 bytes - Formato: n 12
  Uint8List? contactlessTransactionLimit;

  /// Reader CVM Required Limit
  ///
  /// "Indica el monto de transacción sobre el cuál el Kernel instancia las
  /// 'CVM capabilities' del terminal." - Fuente: eftlab.com
  ///
  /// Longitud permitida: 6 bytes - Formato: n 12
  Uint8List? cvmRequiredLimit;

  /// Tag 9F1D - Terminal Risk Management Data
  ///
  /// "Valor específico de cada aplicación utilizado por la tarjeta para gestión
  /// de riesgos" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 1-8 bytes - Formato: b
  Uint8List? riskManagementData;

  /// Threshold Value for Biased Random Selection
  ///
  /// "Valor utilizado en la gestión de riesgos del terminal para la selección
  /// aleatoria de transacción." - Fuente: emvlab.org
  ///
  /// Longitud permitida: 4 bytes - Formato: b
  ///
  /// Para más información, consultar el Libro 3 de EMV - sección 10.6.2
  Uint8List? thresholdValue;

  /// Target Percentage to be Used for Random Selection
  ///
  /// "Valor utilizado en la gestión de riesgos del terminal para la selección
  /// aleatoria de transacción." - Fuente: emvlab.org
  ///
  /// Para más información, consultar el Libro 3 de EMV - sección 10.6.2
  int? targetPercentage;

  /// Maximum Target Percentage to be Used for Biased Random Selection
  ///
  /// "Valor utilizado en la gestión de riesgos del terminal para la selección
  /// aleatoria de transacción." - Fuente: emvlab.org
  ///
  /// Para más información, consultar el Libro 3 de EMV - sección 10.6.2
  int? maxTargetPercentage;

  /// Tag 9F66 - Terminal Transaction Qualifiers (TTQ)
  ///
  /// Longitud permitida: 4 bytes - Formato: b
  Uint8List? terminalTransactionQualifiers;

  EmvApp({
    required Uint8List aid,
    required Uint8List kernelId,
    required Uint8List appVersionNum,
    required Uint8List tacDenial,
    required Uint8List tacOnline,
    required Uint8List tacDefault,
    Uint8List? terminalFloorLimit,
    Uint8List? contactlessFloorLimit,
    Uint8List? contactlessTransactionLimit,
    Uint8List? cvmRequiredLimit,
    Uint8List? riskManagementData,
    Uint8List? thresholdValue,
    int? targetPercentage,
    int? maxTargetPercentage,
    Uint8List? terminalTransactionQualifiers,
  })  : aid = assertVarLen(
          aid,
          "AID",
          minLen: 5,
          maxLen: 16,
        ),
        kernelId = assertFixedLen(
          kernelId,
          "kernelId",
          1,
        ),
        appVersionNum = assertFixedLen(
          appVersionNum,
          "appVersionNum",
          2,
        ),
        tacDenial = assertFixedLen(
          tacDenial,
          "tacDenial",
          5,
        ),
        tacOnline = assertFixedLen(
          tacOnline,
          "tacOnline",
          5,
        ),
        tacDefault = assertFixedLen(
          tacDefault,
          "tacDefault",
          5,
        ),
        terminalFloorLimit = assertFixedLen(
          terminalFloorLimit,
          "terminalFloorLimit",
          4,
        ),
        contactlessFloorLimit = assertFixedLen(
          contactlessFloorLimit,
          "contactlessFloorLimit",
          6,
        ),
        contactlessTransactionLimit = assertFixedLen(
          contactlessTransactionLimit,
          "contactlessTransactionLimit",
          6,
        ),
        cvmRequiredLimit = assertFixedLen(
          cvmRequiredLimit,
          "cvmRequiredLimit",
          6,
        ),
        thresholdValue = assertFixedLen(
          thresholdValue,
          "thresholdValue",
          4,
        ),
        riskManagementData = assertVarLen(
          riskManagementData,
          "riskManagementData",
          minLen: 1,
          maxLen: 8,
        ),
        targetPercentage = assertValueInRange(
          targetPercentage,
          "targetPercentage",
          minVal: 0,
          maxVal: 99,
        ),
        maxTargetPercentage = assertValueInRange(
          maxTargetPercentage,
          "maxTargetPercentage",
          minVal: 0,
          maxVal: 99,
        ),
        terminalTransactionQualifiers = assertFixedLen(
          terminalTransactionQualifiers,
          "terminalTransactionQualifiers",
          4,
        );

  factory EmvApp.fromJson(Map<String, dynamic> jsonData) {
    return EmvApp(
      aid: assertBytesFromJson(jsonData, 'aid'),
      kernelId: assertBytesFromJson(jsonData, 'kernelId'),
      appVersionNum: assertBytesFromJson(jsonData, 'appVersionNum'),
      tacDenial: assertBytesFromJson(jsonData, 'tacDenial'),
      tacOnline: assertBytesFromJson(jsonData, 'tacOnline'),
      tacDefault: assertBytesFromJson(jsonData, 'tacDefault'),
      terminalFloorLimit: assertBytesFromJson(jsonData, 'terminalFloorLimit'),
      contactlessFloorLimit:
          assertBytesFromJson(jsonData, 'contactlessFloorLimit'),
      contactlessTransactionLimit:
          assertBytesFromJson(jsonData, 'contactlessTransactionLimit'),
      cvmRequiredLimit: assertBytesFromJson(jsonData, 'cvmRequiredLimit'),
      riskManagementData: assertBytesFromJson(jsonData, 'riskManagementData'),
      thresholdValue: assertBytesFromJson(jsonData, 'thresholdValue'),
      targetPercentage: assertBytesFromJson(jsonData, 'targetPercentage'),
      maxTargetPercentage: assertBytesFromJson(jsonData, 'maxTargetPercentage'),
      terminalTransactionQualifiers:
          assertBytesFromJson(jsonData, 'terminalTransactionQualifiers'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aid': aid,
      'kernelId': kernelId,
      'appVersionNum': appVersionNum,
      'tacDenial': tacDenial,
      'tacOnline': tacOnline,
      'tacDefault': tacDefault,
      'terminalFloorLimit': terminalFloorLimit,
      'contactlessFloorLimit': contactlessFloorLimit,
      'contactlessTransactionLimit': contactlessTransactionLimit,
      'cvmRequiredLimit': cvmRequiredLimit,
      'riskManagementData': riskManagementData,
      'thresholdValue': thresholdValue,
      'targetPercentage': targetPercentage,
      'maxTargetPercentage': maxTargetPercentage,
      'terminalTransactionQualifiers': terminalTransactionQualifiers,
    };
  }
}
