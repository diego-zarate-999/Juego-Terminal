import 'dart:math';
import 'dart:typed_data';
import 'codecs.dart';

/// Algoritmo para verificar números PAN de Tarjetas de Débito/Crédito.
///
/// Este algoritmo se conoce como "Algoritmo de Luhn" o "Algoritmo de módulo 10"
/// y se utiliza para verificar números de identificación (el número PAN de una
/// tarjeta financiera en este caso).
///
/// Este método lanza un [FormatException] si el valor [pan] contiene
/// caracteres fuera del rango númerico 0-9.
///
/// Para más información sobre el algoritmo:
/// https://www.geeksforgeeks.org/luhn-algorithm/
bool checkLuhn(String pan) {
  int sum = int.parse(pan[pan.length - 1]);
  int digitsCount = pan.length;
  int parity = digitsCount % 2;

  for (int i = 0; i <= digitsCount - 2; i++) {
    int digit = int.parse(pan[i]);

    if (i % 2 == parity) digit = digit * 2;
    if (digit > 9) digit = digit - 9;

    sum = sum + digit;
  }

  return ((sum % 10) == 0);
}

/// Genera una llave DES (o 3DES) con longitud = [length].
///
/// Este método se asegura de que la llave generada tenga los bits bajo la
/// 'paridad' correcta para ser completamente estándar de acuerdo a la
/// definición del algoritmo y mantener compatibilidad con sistemas antiguos.
Uint8List generateRandomDESKey(int length) {
  final random = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (i) {
      final randomValue = random.nextInt(128);
      return applyOddParity(randomValue);
    }),
  );
}

Uint8List calculateCRC32(Uint8List data) {
  int crc, mask;
  int i = 0;
  crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc = crc ^ byte;
    for (int j = 7; j >= 0; j--) {
      // Do eight times.
      mask = -(crc & 1);
      crc = (crc >> 1) ^ (0xEDB88320 & mask);
    }
    i = i + 1;
  }
  return (~crc)
      .toUnsigned(4 * 8) // necesario para un valor correcto (4 bytes * 8 bits)
      .toRadixString(16)
      .padLeft(8, "0")
      .toHexBytes();
}

/// Genera rangos en formato de iterables de enteros.
///
/// Se debe indicar los valores de [start] (inclusivo) y [end] (exclusivo).
Iterable<int> range(int start, int end) sync* {
  if (end <= start) {
    throw Exception("Rango no permitido");
  } else {
    for (int i = start; i < end; i++) {
      yield i;
    }
  }
}

/// Ordena de menor a mayor una lista rangos suministrados [ranges].
List<Iterable<int>> orderRanges(List<Iterable<int>> ranges) {
  if (ranges.isEmpty) {
    throw Exception("No se puede pasar una lista vacía");
  }
  List<Iterable<int>> result = [];
  ranges.sort((a, b) => a.toList().first.compareTo(b.toList().first));
  result.addAll(ranges);
  return result;
}

/// Genera una lista con índices a ignorar a partir de un conjunto de [ranges].
List<int> generateIndexesToIgnore(List<Iterable<int>> ranges) {
  final rangesInOrder = orderRanges(ranges);

  List<int> positionList = [];

  for (var element in rangesInOrder) {
    List<int> positions = element.toList();
    positionList.addAll(positions);
  }

  return positionList;
}

/// Compara el contenido de dos cadenas en formato Uint8List.
///
/// Facilita la posibilidad de ignorar el contenido correspondiente a una lista
/// de índices suministrados [ignoreIndex] durante la comparación.
///
/// Retorna true en caso de que las cadenas sean iguales.
bool compareContent(
    Uint8List fileBytesContent, Uint8List referenceFileBytesContent,
    {List<int>? ignoreIndex}) {
  bool result = false;
  List<int> positionList = [];

  if (ignoreIndex != null) {
    positionList = ignoreIndex;
    positionList.sort((a, b) => a.compareTo(b));
  }

  bool found = false;
  List<int> aux = positionList;

  if (fileBytesContent.length != referenceFileBytesContent.length) {
    return false;
  }

  external:
  for (int i = 0; i < fileBytesContent.length; i++) {
    if (found == true) {
      if (aux.length > 0) {
        aux.removeAt(0);
        found = false;
      }
    }
    if (!found) {
      int? element;
      if (aux.isNotEmpty) {
        element = aux[0];
      }
      if (i != element || aux.isEmpty) {
        result = fileBytesContent[i] == referenceFileBytesContent[i];
        if (!result) {
          break external;
        }
        continue;
      } else {
        found = true;
      }
    }
  }
  return result;
}

extension CompareWithIgnore on Uint8List {
  /// Retorna true si la cadena es igual a una suministrada como referencia.
  ///
  /// Permite ignorar rangos de índices durante la comparación, evitando que
  /// afecten el resultado si tienen valores diferentes.
  bool compareWithIgnore(Uint8List secondUint8List, {List<int>? ignoreIndex}) {
    return compareContent(this, secondUint8List, ignoreIndex: ignoreIndex);
  }
}
