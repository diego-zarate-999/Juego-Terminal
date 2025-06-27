import 'package:agnostiko/cards/cards.dart';

/// Información sobre la plataforma donde se está utilizando la librería.
class PlatformInfo {
  /// Nombre del sistema operativo
  final String baseOs;

  /// Versión del sistema operativo
  final String version;

  /// Marca del fabricante del dispositivo
  final String deviceBrand;

  /// Indica si el dispositivo cuenta con lector de tarjetas
  final bool hasCardReader;

  /// Indica si el dispositivo cuenta con módulo financiero EMV
  final bool hasEmvModule;

  /// Indica si el dispositivo cuenta con Keypad físico
  final bool hasKeypad;

  /// Indica si el dispositivo cuenta con módulo MDB
  final bool hasMDB;

  /// Indica si el dispositivo cuenta con impresora
  final bool hasPrinter;

  /// Indica si el dispositivo cuenta con módulo de ingreso seguro de PIN
  final bool hasPinEntryDevice;

  /// Indica si el dispositivo cuenta con scanner de hardware
  final bool hasScannerHw;

  /// Tipos de tarjeta soportados por el lector del dispositivo
  final List<CardType> supportedCardTypes;

  PlatformInfo({
    required this.baseOs,
    required this.version,
    required this.deviceBrand,
    required this.hasCardReader,
    required this.hasEmvModule,
    required this.hasKeypad,
    required this.hasMDB,
    required this.hasPrinter,
    required this.hasPinEntryDevice,
    required this.hasScannerHw,
    required this.supportedCardTypes,
  });

  factory PlatformInfo.fromJson(Map<String, dynamic> jsonData) {
    List<dynamic> cardTypes = jsonData['supportedCardTypes'];
    List<CardType> cardTypesList =
        cardTypes.map((index) => CardType.values[index]).toList();

    return PlatformInfo(
      baseOs: jsonData['baseOs'],
      version: jsonData['version'],
      deviceBrand: jsonData['deviceBrand'],
      hasCardReader: jsonData['hasCardReader'],
      hasEmvModule: jsonData['hasEmvModule'],
      hasKeypad: jsonData['hasKeypad'],
      hasMDB: jsonData['hasMDB'],
      hasPrinter: jsonData['hasPrinter'],
      hasPinEntryDevice: jsonData['hasPinEntryDevice'],
      hasScannerHw: jsonData['hasScannerHw'],
      supportedCardTypes: cardTypesList,
    );
  }

  Map<String, dynamic> toJson() {
    List<int> cardTypesList =
        supportedCardTypes.map((type) => type.index).toList();

    return {
      'baseOs': baseOs,
      'version': version,
      'deviceBrand': deviceBrand,
      'hasCardReader': hasCardReader,
      'hasEmvModule': hasEmvModule,
      'hasKeypad': hasKeypad,
      'hasMDB': hasMDB,
      'hasPrinter': hasPrinter,
      'hasPinEntryDevice': hasPinEntryDevice,
      'hasScannerHw': hasScannerHw,
      'supportedCardTypes': cardTypesList,
    };
  }
}
