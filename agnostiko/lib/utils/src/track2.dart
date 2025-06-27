import 'dart:convert';
import 'dart:typed_data';

import 'validation.dart';

/// Representa la data de un Track 2 de Banda magnética.
///
/// La representación de texto NO incluye los caracteres sentinela de inicio y
/// fin (';' y '?' respectivamente).
///
/// También se pueden utilizar [toAscii] y [toBcd] para obtener representaciones
/// en dichos formatos CON o SIN caracteres sentinela.
class Track2 {
  final String _value;

  const Track2._(this._value);

  /// Número PAN contenido en el Track 2.
  String get pan {
    return _value.substring(0, _separatorIndex);
  }

  /// Valida si el código de servicio en el track 2 empieza por '2' o '6'.
  ///
  /// De ser así, se trata de una tarjeta de chip.
  bool get isChipCard {
    int serviceCodeIndex = _separatorIndex + 5;
    String firstDigit = _value[serviceCodeIndex];
    return (firstDigit == "2" || firstDigit == "6");
  }

  /// Indíce (basado en 0) del separador '=' del Track 2.
  int get _separatorIndex {
    return _value.indexOf("=");
  }

  /// Crea el Track a partir de una cadena con el formato adecuado.
  ///
  /// La cadena NO debe incluir los caracteres sentinela de inicio y fin (';' y
  /// '?' respectivamente).
  ///
  /// Ej. de cadena: 4110970856867984=0923901661
  ///
  /// Falla con [FormatException] si el formato no se cumple o la longitud es
  /// superior al límite.
  factory Track2.fromString(String track2Str) {
    assertVarLen(track2Str, "Track 2", minLen: 4, maxLen: 40);
    _assertTrackFormat(track2Str);

    return Track2._(track2Str);
  }

  static void _assertTrackFormat(String trackStr) {
    if (!RegExp(r"^([\d]{2,19})=([\d]+)$").hasMatch(trackStr)) {
      throw FormatException(
          "El valor: '$trackStr' no concuerda con el formato de Track 2.");
    }
  }

  /// Representación en bytes con formato ASCII.
  ///
  /// El flag [includeSentinels] define si se incluyen o no los caracteres
  /// sentinelas de inicio y fin (';' y '?' respectivamente).
  Uint8List toAscii({bool includeSentinels = false}) {
    return includeSentinels
        ? AsciiCodec().encode(";$_value?")
        : AsciiCodec().encode(_value);
  }

  /// Representación en bytes con formato BCD.
  ///
  /// El flag [includeSentinels] define si se incluyen o no los caracteres
  /// sentinelas de inicio y fin (';' y '?' respectivamente).
  Uint8List toBcd({bool includeSentinels = false}) {
    final asciiBytes = toAscii(includeSentinels: includeSentinels);
    final isOddNumber = (asciiBytes.length % 2) != 0;

    int bcdLen = asciiBytes.length ~/ 2;
    bcdLen += isOddNumber ? 1 : 0;
    Uint8List bcd = Uint8List(bcdLen);

    for (int i = 0; i < asciiBytes.length; i += 2) {
      bool isLastCycle = i + 2 >= asciiBytes.length;

      // los bytes de la versión ASCII se pueden transformar directamente a los
      // nibbles de la versión BCD con la siguiente transformación
      int firstNibble = (asciiBytes[i] - 0x30) << 4;
      int secondNibble =
          isOddNumber && isLastCycle ? 0x0F : (asciiBytes[i + 1] - 0x30);
      int byte = firstNibble | secondNibble;

      bcd[i ~/ 2] = byte;
    }

    return bcd;
  }

  /// Representación de texto que NO incluye los caracteres sentinela de inicio
  /// y fin (';' y '?' respectivamente).
  @override
  String toString() {
    return _value;
  }
}
