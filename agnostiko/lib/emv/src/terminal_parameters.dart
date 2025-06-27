import "dart:typed_data";

import '../../utils/utils.dart';

/// Parámetros de Terminal necesarios para la operación del Kernel EMV.
///
/// Todos los parámetros son obligatorios ya que la necesidad de utilizar los
/// mismos depende mucho del dispositivo y su fabricante y por lo tanto es
/// necesario intentar cubrir la mayor cantidad de valores para evitar errores
/// durante la transacción.
class TerminalParameters {
  /// Tag 9F35 - Terminal Type.
  ///
  /// "Indica el ambiente del terminal, su capacidad de comunicación, y su
  /// control operacional." - Fuente: emvlab.org
  ///
  /// Longitud permitida: 1 byte - Formato: n 2
  Uint8List terminalType;

  /// Default Dynamic Data Authentication Data Object List (DDOL)
  ///
  /// "DDOL para ser utilizado al construir el comando 'INTERNAL AUTHENTICATE'
  /// si el DDOL de la tarjeta no está presente" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 0-252 bytes - Formato: b
  Uint8List defaultDDOL;

  /// Default Transaction Certificate Data Object List (TDOL)
  ///
  /// "TDOL para ser utilizado al generar el 'TC Hash Value' si el TDOL de la
  /// tarjeta no está presente" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 0-252 bytes - Formato: b
  Uint8List defaultTDOL;

  /// Tag 9F1B - Terminal Floor Limit
  ///
  /// "Indica el límite de piso en el terminal en conjunto con el AID" - Fuente:
  /// emvlab.org
  ///
  /// Longitud permitida: 4 bytes - Formato: b
  Uint8List terminalFloorLimit;

  /// Tag 9F33 - Terminal Capabilities
  ///
  /// "Indica el ingreso de datos de la tarjeta, CVM, y capacidades de seguridad
  /// del terminal" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 3 bytes - Formato: b
  Uint8List terminalCapabilities;

  /// Tag 9F40 - Additional Terminal Capabilities
  ///
  /// "Indica el ingreso de datos y la capacidad de salida del terminal" -
  /// Fuente: emvlab.org
  ///
  /// Longitud permitida: 5 bytes - Formato: b
  Uint8List additionalTerminalCapabilities;

  /// Tag 9F1A - Terminal Country Code
  ///
  /// "Indica el país del terminal, representado de acuerdo al ISO 3166" -
  /// Fuente: emvlab.org
  ///
  /// Longitud permitida: 2 bytes - Formato: n 3
  Uint8List terminalCountryCode;

  /// Tag 5F2A - Transaction Currency Code
  ///
  /// "Indica el código de moneda de la transacción de acuerdo con ISO 4217" -
  /// Fuente: emvlab.org
  ///
  /// Longitud permitida: 2 bytes - Formato: n 3
  Uint8List transactionCurrencyCode;

  /// Tag 5F36 - Transaction Currency Exponent
  ///
  /// "Indica la posición ímplicita del punto decimal desde la derecha del monto
  /// de la transacción representada de acuerdo a ISO 4217." - Fuente:
  /// emvlab.org
  ///
  /// Longitud permitida: 1 byte - Formato: n 1
  int transactionCurrencyExp;


  /// Transaction Reference Currency Conversion
  ///
  /// "Factor utilizado en la conversión del Transaction Currency Code al
  /// Transaction Reference Currency Code" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 4 byte - Formato: n 8
  Uint8List referenceCurrencyConversion;

  /// Tag 9F3C - Transaction Reference Currency Code
  ///
  /// "Código que define la moneda común utilizada por el terminal en caso que
  /// el código de moneda de la transacción sea diferente del código de moneda
  /// de la aplicación." - Fuente: emvlab.org
  ///
  /// Longitud permitida: 2 bytes - Formato: n 3
  Uint8List referenceCurrencyCode;

  /// Tag 9F3D - Transaction Reference Currency Exponent
  ///
  /// "Indica la posición ímplicita del punto decimal desde la derecha del monto
  /// de la transacción, con el código de moneda de referencia de transacción
  /// representado de acuerdo a ISO 4217." - Fuente: emvlab.org
  ///
  /// Longitud permitida: 1 byte - Formato: n 1
  int referenceCurrencyExp;

  /// Tag 9F1C - Terminal Identification
  ///
  /// "Designa la localización única de un terminal en un comerciante" - Fuente:
  /// emvlab.org
  ///
  /// Longitud permitida: 8 caracteres - Formato: an 8
  String terminalId;

  /// Tag 9F1E - Interface Device (IFD) Serial Number
  ///
  /// "Número serial único y permanente asignado al IFD por el fabricante" -
  /// Fuente: emvlab.org
  ///
  /// Longitud permitida: 8 caracteres - Formato: an 8
  String ifdSerialNumber;

  /// Tag 9F01 - Acquirer Identification
  ///
  /// "Identificación única del adquiriente dentro de un sistema de pagos" -
  /// Fuente: emvlab.org
  ///
  /// Longitud permitida: 6 bytes - Formato: n 6-11
  Uint8List acquirerId;

  /// Tag 9F16 - Merchant Identifier
  ///
  /// "Cuando se concatena con el Identificador del Adquiriente, identifica de
  /// manera única al comerciante" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 15 caracteres - Formato: ans 15
  String merchantId;

  /// Tag 9F15 - Merchant Category Code
  ///
  /// "Clasifica el tipo de negocio llevado a cabo por el comerciante,
  /// representado de acuerdo a ISO 8583:1993 para 'Card Acceptor Business
  /// Code'" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 2 bytes - Formato: n 4
  Uint8List merchantCategoryCode;

  /// Tag 9F4E - Merchant Name and Location
  ///
  /// "Indica el nombre y la localización del comerciante" - Fuente: emvlab.org
  ///
  /// Longitud permitida: 0-20 caracteres - Formato: ans
  String merchantNameAndLocation;

  /// Threshold Value for Biased Random Selection
  ///
  /// "Valor utilizado en la gestión de riesgos del terminal para la selección
  /// aleatoria de transacción." - Fuente: emvlab.org
  ///
  /// Longitud permitida: 4 bytes - Formato: b
  ///
  /// Para más información, consultar el Libro 3 de EMV - sección 10.6.2
  Uint8List thresholdValue;

  /// Target Percentage to be Used for Random Selection
  ///
  /// "Valor utilizado en la gestión de riesgos del terminal para la selección
  /// aleatoria de transacción." - Fuente: emvlab.org
  ///
  /// Para más información, consultar el Libro 3 de EMV - sección 10.6.2
  int targetPercentage;

  /// Maximum Target Percentage to be Used for Biased Random Selection
  ///
  /// "Valor utilizado en la gestión de riesgos del terminal para la selección
  /// aleatoria de transacción." - Fuente: emvlab.org
  ///
  /// Para más información, consultar el Libro 3 de EMV - sección 10.6.2
  int maxTargetPercentage;

  TerminalParameters({
    required Uint8List terminalType,
    required Uint8List defaultDDOL,
    required Uint8List defaultTDOL,
    required Uint8List terminalFloorLimit,
    required Uint8List terminalCapabilities,
    required Uint8List additionalTerminalCapabilities,
    required Uint8List terminalCountryCode,
    required String terminalId,
    required String ifdSerialNumber,
    required Uint8List acquirerId,
    required String merchantId,
    required Uint8List merchantCategoryCode,
    required String merchantNameAndLocation,
    required Uint8List transactionCurrencyCode,
    required this.transactionCurrencyExp,
    required Uint8List referenceCurrencyConversion,
    required Uint8List referenceCurrencyCode,
    required this.referenceCurrencyExp,
    required Uint8List thresholdValue,
    required int targetPercentage,
    required int maxTargetPercentage,
  })  : terminalType = assertFixedLen(
          terminalType,
          "terminalType",
          1,
        ),
        defaultDDOL = assertVarLen(
          defaultDDOL,
          "defaultDDOL",
          minLen: 0,
          maxLen: 252,
        ),
        defaultTDOL = assertVarLen(
          defaultTDOL,
          "defaultTDOL",
          minLen: 0,
          maxLen: 252,
        ),
        terminalFloorLimit = assertFixedLen(
          terminalFloorLimit,
          "terminalFloorLimit",
          4,
        ),
        terminalCapabilities = assertFixedLen(
          terminalCapabilities,
          "terminalCapabilities",
          3,
        ),
        additionalTerminalCapabilities = assertFixedLen(
          additionalTerminalCapabilities,
          "additionalTerminalCapabilities",
          5,
        ),
        terminalCountryCode = assertFixedLen(
          terminalCountryCode,
          "terminalCountryCode",
          2,
        ),
        terminalId = assertFixedLen(terminalId, "terminalId", 8),
        ifdSerialNumber = assertFixedLen(ifdSerialNumber, "ifdSerialNumber", 8),
        acquirerId = assertFixedLen(acquirerId, "acquirerId", 6),
        merchantId = assertFixedLen(merchantId, "merchantId", 15),
        merchantCategoryCode = assertFixedLen(
          merchantCategoryCode,
          "merchantCategoryCode",
          2,
        ),
        merchantNameAndLocation = assertVarLen(
          merchantNameAndLocation,
          "merchantNameAndLocation",
          minLen: 0,
          maxLen: 20,
        ),
        transactionCurrencyCode = assertFixedLen(
          transactionCurrencyCode,
          "transactionCurrencyCode",
          2,
        ),
        referenceCurrencyConversion = assertFixedLen(
          referenceCurrencyConversion,
          "referenceCurrencyConversion",
          4,
        ),
        referenceCurrencyCode = assertFixedLen(
          referenceCurrencyCode,
          "referenceCurrencyCode",
          2,
        ),
        thresholdValue = assertFixedLen(
          thresholdValue,
          "thresholdValue",
          4,
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
        );

  factory TerminalParameters.fromJson(Map<String, dynamic> jsonData) {
    return TerminalParameters(
      terminalType: assertBytesFromJson(jsonData, 'terminalType'),
      defaultDDOL: assertBytesFromJson(jsonData, 'defaultDDOL'),
      defaultTDOL: assertBytesFromJson(jsonData, 'defaultTDOL'),
      terminalFloorLimit: assertBytesFromJson(jsonData, 'terminalFloorLimit'),
      terminalCapabilities:
          assertBytesFromJson(jsonData, 'terminalCapabilities'),
      additionalTerminalCapabilities:
          assertBytesFromJson(jsonData, 'additionalTerminalCapabilities'),
      terminalCountryCode: assertBytesFromJson(jsonData, 'terminalCountryCode'),
      transactionCurrencyCode:
          assertBytesFromJson(jsonData, 'transactionCurrencyCode'),
      transactionCurrencyExp: jsonData['transactionCurrencyExp'],
      referenceCurrencyConversion:
          assertBytesFromJson(jsonData, 'referenceCurrencyConversion'),
      referenceCurrencyCode:
          assertBytesFromJson(jsonData, 'referenceCurrencyCode'),
      referenceCurrencyExp: jsonData['referenceCurrencyExp'],
      terminalId: jsonData['terminalId'],
      ifdSerialNumber: jsonData['ifdSerialNumber'],
      acquirerId: assertBytesFromJson(jsonData, 'acquirerId'),
      merchantId: jsonData['merchantId'],
      merchantCategoryCode:
          assertBytesFromJson(jsonData, 'merchantCategoryCode'),
      merchantNameAndLocation: jsonData['merchantNameAndLocation'],
      thresholdValue: assertBytesFromJson(jsonData, 'thresholdValue'),
      targetPercentage: jsonData['targetPercentage'],
      maxTargetPercentage: jsonData['maxTargetPercentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terminalType': terminalType,
      'defaultDDOL': defaultDDOL,
      'defaultTDOL': defaultTDOL,
      'terminalFloorLimit': terminalFloorLimit,
      'terminalCapabilities': terminalCapabilities,
      'additionalTerminalCapabilities': additionalTerminalCapabilities,
      'terminalCountryCode': terminalCountryCode,
      'transactionCurrencyCode': transactionCurrencyCode,
      'transactionCurrencyExp': transactionCurrencyExp,
      'referenceCurrencyConversion': referenceCurrencyConversion,
      'referenceCurrencyCode': referenceCurrencyCode,
      'referenceCurrencyExp': referenceCurrencyExp,
      'terminalId': terminalId,
      'ifdSerialNumber': ifdSerialNumber,
      'acquirerId': acquirerId,
      'merchantId': merchantId,
      'merchantCategoryCode': merchantCategoryCode,
      'merchantNameAndLocation': merchantNameAndLocation,
      'thresholdValue': thresholdValue,
      'targetPercentage': targetPercentage,
      'maxTargetPercentage': maxTargetPercentage,
    };
  }
}
