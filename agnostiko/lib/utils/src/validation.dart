import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import './codecs.dart';
import '../../emv/src/capk.dart';

/// Verifica si la longitud ("length") de un objeto está en el rango permitido.
///
/// El rango estará definido desde [minLen] (inclusivo) hasta [maxLen]
/// (inclusivo).
///
/// Lanza error de tipo 'StateError' con un mensaje descriptivo incluyendo
/// [valueName] como nombre del valor si no se cumple con la longitud adecuada.
dynamic assertVarLen(
  dynamic value,
  String valueName, {
  required int minLen,
  required int maxLen,
}) {
  if (value == null) {
    return value;
  }

  if (value.length < minLen || value.length > maxLen) {
    throw StateError("La longitud del valor '$valueName' es ${value.length} " +
        "pero debería estar en el rango: $minLen - $maxLen.");
  }
  return value;
}

/// Verifica si la longitud ("length") de un objeto es la especificada: [len].
///
/// Lanza error de tipo 'StateError' con un mensaje descriptivo incluyendo
/// [valueName] como nombre del valor si no se cumple con la longitud adecuada.
dynamic assertFixedLen(dynamic value, String valueName, int len) {
  if (value == null) {
    return value;
  }

  if (value.length != len) {
    throw StateError("La longitud del valor '$valueName' es: ${value.length} " +
        "pero debería ser: $len.");
  }
  return value;
}

/// Verifica si la longitud ("length") de un objeto es par.
///
/// Lanza error de tipo 'StateError' con un mensaje descriptivo incluyendo
/// [valueName] como nombre del valor si la longitud es impar.
dynamic assertEvenLen(dynamic value, String valueName) {
  if (value == null) {
    return value;
  }

  if (!value.length.isEven) {
    throw StateError(
      "La longitud del valor '$valueName' no es par y debería serlo.",
    );
  }
  return value;
}

/// Verifica si el valor de un objeto está en el rango permitido.
///
/// El rango estará definido desde [minVal] (inclusivo) hasta [maxVal]
/// (inclusivo).
///
/// Lanza error de tipo 'StateError' con un mensaje descriptivo incluyendo
/// [valueName] como nombre del valor si no se cumple con el valor adecuado.
///
/// Esto es útil para validación de números de tipo 'num' o 'int'.
dynamic assertValueInRange(
  dynamic value,
  String valueName, {
  required dynamic minVal,
  required dynamic maxVal,
}) {
  if (value == null) {
    return value;
  }

  if (value < minVal || value > maxVal) {
    throw StateError(
      "El valor de '$valueName' debería estar en el rango $minVal-$maxVal " +
          " pero es '$value'.",
    );
  }
  return value;
}

/// Valida si [fieldName] es una lista de bytes como [String] o [List].
///
/// Esta utilidad valida si el campo es un [String] hexadecimal o una [List]
/// de [int]'s y retorna su valor si es válido como un [Uint8List].
///
/// Si el valor es nulo o de un tipo incorrecto, se retorna sin modificar ni
/// validar (necesario para dejar pasar parámetros opcionales).
///
/// Lanza error de tipo 'StateError' si hay un error con el parseo del campo.
dynamic assertBytesFromJson(Map<String, dynamic> jsonData, String fieldName) {
  dynamic value = jsonData[fieldName];
  if (value is String) {
    return strHexToBytes(assertEvenLen(value, fieldName));
  } else if (value is List) {
    return Uint8List.fromList(value.map((v) => v as int).toList());
  }
  return value;
}

class CAPKChecksumException extends StateError {
  CAPKChecksumException(String message) : super(message);
}

/// Lleva a cabo la validación de Checksum de un CAPK.
///
/// Lanza [CAPKChecksumException] si falla la validación.
void assertCAPKChecksum(CAPK capk) {
  // Se lleva a cabo una verificación de Checksum
  final list = capk.rid + capk.index + capk.modulus + capk.exponent;
  final bytes = Uint8List.fromList(list);

  final digest = sha1.convert(bytes);
  final digestedBytes = Uint8List.fromList(digest.bytes);

  if (digestedBytes.toHexStr() != capk.checksum.toHexStr()) {
    throw CAPKChecksumException("La validación de Checksum falló para " +
        "el CAPK con RID: '${capk.rid.toHexStr()}' e " +
        "índice: '${capk.index.toHexStr()}'.");
  }
}

///Valida la fecha de expiración del token suministrado como parámetro
///[authToken] a partir de los últimos 6 bytes de la cadena.
///
/// Retorna true si el token está vencido.
bool validateExpDateToken(Uint8List authToken){
  try{
    if(authToken.length >= 263){
      final expDateHex = authToken.sublist(257, 263);
      final expDateStr =  expDateHex.toHexStr();
      final expDateToken = int.parse(expDateStr, radix: 16);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      if(expDateToken < timestamp) print("Token vencido, obteniendo otro online");
      return expDateToken < timestamp;

    }else{
      print("El tamaño del token es inferior al requerido");
      return true;
    }

  }catch(e){
    print("Error: $e");
    return true;
  }

}
