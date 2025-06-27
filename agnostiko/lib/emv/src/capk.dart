import 'dart:convert';
import 'dart:typed_data';

import '../../utils/utils.dart';

class CAPK {
  /// RID - 5 bytes que representan una marca bajo el estándar EMV.
  final Uint8List rid;

  /// Indíce de la llave pública dentro de su respectiva marca (RID).
  final Uint8List index;

  /// Valor de exponente de la llave pública.
  ///
  /// Por lo general es igual a 1 byte con valor '0x03' o 3 bytes con valor
  /// '(0x01, 0x00, 0x01)'.
  final Uint8List exponent;

  final Uint8List modulus;

  /// Valor de 'Check Sum' bajo algoritmo SHA-1 para validación de la llave.
  ///
  /// Debe tener longitud fija de 20 bytes.
  final Uint8List checksum;

  final DateTime expirationDate;

  CAPK({
    required Uint8List rid,
    required Uint8List index,
    required Uint8List exponent,
    required this.modulus,
    required Uint8List checksum,
    required this.expirationDate,
  })  : rid = assertFixedLen(rid, "rid", 5),
        index = assertFixedLen(index, "index", 1),
        exponent = assertVarLen(exponent, "exponent", minLen: 1, maxLen: 3),
        checksum = assertFixedLen(checksum, "checksum", 20);

  static List<CAPK> parseJsonArray(String jsonData) {
    final resList = jsonDecode(jsonData) as List;

    final list = resList.asMap().entries.map((entry) {
      final capkData = entry.value;

      // Hacemos este relanzado del error para identificar con número el CAPK
      // específico que ocasionó la falla
      try {
        return CAPK.fromJson(capkData);
      } catch (e) {
        throw Exception("Error en carga de CAPK #${entry.key}: $e");
      }
    }).toList();

    return list;
  }

  factory CAPK.fromJson(Map<String, dynamic> jsonData) {
    final expDateJson = jsonData['expirationDate'] as Map<String, dynamic>?;

    if (expDateJson == null) {
      throw StateError("El valor de 'Expiration Date' no puede ser nulo.");
    }

    int? year = expDateJson['year'];
    int? month = expDateJson['month'];
    int? day = expDateJson['day'];

    if (year == null || month == null || day == null) {
      throw StateError(
        "Los valores de 'year', 'month' o 'day' del 'Expiration Date' no " +
            "pueden ser nulos.",
      );
    }

    return CAPK(
      rid: assertBytesFromJson(jsonData, 'rid'),
      index: assertBytesFromJson(jsonData, 'index'),
      exponent: assertBytesFromJson(jsonData, 'exponent'),
      modulus: assertBytesFromJson(jsonData, 'modulus'),
      checksum: assertBytesFromJson(jsonData, 'checksum'),
      expirationDate: DateTime(year, month, day),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rid': rid,
      'index': index,
      'exponent': exponent,
      'modulus': modulus,
      'checksum': checksum,
      'expirationDate': {
        'year': expirationDate.year,
        'month': expirationDate.month,
        'day': expirationDate.day,
      }
    };
  }
}
