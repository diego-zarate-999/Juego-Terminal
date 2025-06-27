import "dart:typed_data";
import 'package:meta/meta.dart';

import 'package:pointycastle/asymmetric/api.dart';

import 'package:agnostiko/agnostiko.dart';

const cryptoChannel = const HybridMethodChannel('agnostiko/Crypto');

enum CipherMode {
  ECB,
  CBC,
}

/// Parámetros para algoritmos de encripción simétrica DES o AES
class AlgorithmParameters {
  /// Modo de cifrado. Normalmente ECB o CBC.
  CipherMode cipherMode;

  /// Vector de inicialización para modo de encriptado CBC o similar
  Uint8List? iv;

  AlgorithmParameters({
    this.cipherMode = CipherMode.ECB,
    this.iv,
  }) {
    if (cipherMode == CipherMode.CBC && iv == null) {
      throw StateError("CBC cipher mode requires initialization vector");
    }
  }

  Map<String, dynamic> toJson() {
    return {"cipherMode": cipherMode.index, "iv": iv};
  }
}

/// Resultado de un encriptado bajo llaves DUKPT.
class DUKPTResult {
  /// Data cifrada bajo DUKPT.
  Uint8List data;

  /// Key Serial Number (KSN) de la llave utilizada para el encriptado.
  Uint8List ksn;

  // Longitud original de la data antes de paddear y encriptar
  int actualDataLen;

  DUKPTResult({
    required this.data,
    required this.ksn,
    required this.actualDataLen,
  });

  Map<String, dynamic> toJson() {
    return {"data": data, "ksn": ksn, "actualDataLen": actualDataLen};
  }

  factory DUKPTResult.fromJson(Map<String, dynamic> json) {
    return DUKPTResult(
      data: json["data"],
      ksn: json["ksn"],
      actualDataLen: json["actualDataLen"],
    );
  }
}

class CryptoResult {
  Uint8List data;

  /// Key Serial Number (KSN) de la llave utilizada para el encriptado.
  Uint8List? ksn;

  CryptoResult({
    required this.data,
    required this.ksn,
  });

  Map<String, dynamic> toJson() {
    return {"data": data, "ksn": ksn};
  }

  factory CryptoResult.fromJson(Map<String, dynamic> json) {
    return CryptoResult(
      data: json["data"],
      ksn: json["ksn"],
    );
  }
}

/// Elimina todas las llaves cargadas en el módulo seguro del dispositivo.
Future<void> cryptoDeleteAllKeys() async {
  await cryptoChannel.invokeMethod("deleteAllKeys");
}

/// Elimina la llave DUKPT con índice: [keyIndex]
Future<void> cryptoDUKPTDeleteKey(int keyIndex) async {
  await cryptoChannel.invokeMethod("dukptDeleteKey", keyIndex);
}

/// Contenedor para datos de llave criptográfica de transporte
class TransportKey {
  final Uint8List keyData;
  final Uint8List kcv;

  TransportKey(this.keyData, this.kcv);

  factory TransportKey.fromJson(Map<String, dynamic> data) {
    return TransportKey(data["keyData"], data["kcv"]);
  }

  Map<String, dynamic> toJson() {
    return {"keyData": keyData, "kcv": kcv};
  }
}

/// Genera una llave DES de transporte encriptada con llave pública RSA
///
/// El valor 'en claro' de dicha llave de transporte puede ser luego utilizado
/// para encriptar un IPEK y cargarlo de forma segura(mediante [cryptoLoadIPEK])
Future<TransportKey> cryptoGenerateTransportKey(RSAPublicKey publicKey) async {
  final modulus = publicKey.modulus?.toHexBytes();
  final exponent = publicKey.exponent?.toHexBytes();
  if (modulus == null || exponent == null) {
    throw ArgumentError("modulus or exponent missing");
  }

  final result = await cryptoChannel.invokeMethod("generateTransportKey", {
    "modulus": modulus,
    "exponent": exponent,
  });
  return TransportKey.fromJson(Map<String, dynamic>.from(result));
}

/// Carga de llave IPEK (Initial PIN Encryption Key) para derivación DUKPT.
///
/// El rango recomendado para el índice de la llave es 1-9, el índice 0 no es
/// válido. La longitud de llave soportada es de 128 bits únicamente.
///
/// El parámetro opcional [kekIndex] se utiliza para identificar el índice de
/// la llave precargada en el terminal que se utilizó para encriptar la IPEK.
/// Esta es la forma recomendada de cargar llaves y en algunas marcas el
/// intentar cargar llaves IPEK en claro ya no funciona.
///
/// Se puede setear el [kcv] para validar que la llave se cargó correctamente.
///
/// Si la llave está en claro se puede obviar el parámetro [useTransportKey].
/// En caso de que la llave venga encriptada con una llave de transporte
/// generada anteriormente con [cryptoGenerateTransportKey], se debe setear
/// dicho parámetro a 'true'.
@Deprecated("use 'dataLoadKey' instead")
Future<void> cryptoLoadIPEK(int keyIndex, Uint8List ksn, Uint8List ipek,
    {int? kekIndex, bool useTransportKey = false, Uint8List? kcv}) async {
  if (ksn.length != 10) {
    throw StateError("La longitud del KSN debe ser 10 bytes.");
  }
  if (ipek.length != 16) {
    throw StateError(
      "La longitud de la llave IPEK debe ser de 16 bytes.",
    );
  }
  await cryptoChannel.invokeMethod("loadIPEK", {
    "keyIndex": keyIndex,
    "ksn": ksn,
    "ipek": ipek,
    "useTransportKey": useTransportKey,
    "kekIndex": kekIndex,
    "kcv": kcv,
  });
}

/// Indica si un grupo DUKPT existe en módulo seguro de acuerdo a su [keyIndex].
@Deprecated("use 'cryptoDataCheckKey' instead")
Future<bool> cryptoDUKPTCheckKeyExists(int keyIndex) async {
  bool keyExists = await cryptoChannel.invokeMethod(
    "dukptCheckKeyExists",
    keyIndex,
  );
  return keyExists;
}

/// Encriptado de datos bajo llaves DUKPT con algoritmo 3DES
///
/// La longitud de [data] debe ser múltiplo del tamaño de bloque 3DES(8 bytes).
///
/// El parámetro [iv] (Vector de Inicialización) es obligatorio para el modo de
/// encriptado [CipherMode.CBC].
@Deprecated("use 'cryptoDataEncrypt' instead")
Future<DUKPTResult> cryptoDUKPTEncrypt(
  int keyIndex,
  Uint8List data,
  CipherMode cipherMode, [
  Uint8List? iv,
]) async {
  if (cipherMode == CipherMode.CBC && iv == null) {
    throw StateError(
      "El modo de cifrado 'CBC' requiere un vector de inicialización.",
    );
  }
  if ((data.length % 8) != 0) {
    throw StateError(
      "La longitud del cifrado debe ser múltiplo del tamaño de bloque (8 bytes)",
    );
  }
  final result = await cryptoChannel.invokeMethod("dukptEncrypt", {
    "keyIndex": keyIndex,
    "data": data,
    "cipherMode": cipherMode.index,
    "iv": iv,
  });
  return DUKPTResult.fromJson(Map<String, dynamic>.from(result));
}

/// Retorna el KSN de la llave DUKPT con índice: [keyIndex] o null si no existe
@Deprecated("use 'cryptoGetKSN' instead")
Future<Uint8List?> cryptoDUKPTGetKSN(int keyIndex) async {
  final result = await cryptoChannel.invokeMethod("dukptGetKSN", keyIndex);
  return result as Uint8List?;
}

/// Incrementa el contador KSN asociado a la llave DUKPT con índice [keyIndex]
@Deprecated("use 'cryptoIncrementKSN' instead")
Future<void> cryptoDUKPTIncrementKSN(int keyIndex) {
  return cryptoChannel.invokeMethod("dukptIncrementKSN", keyIndex);
}

/// Carga de llave para PIN Online.
///
/// El rango recomendado para el índice de la llave es 1-9, el índice 0 no es
/// válido. La longitud de llave soportada es de 8, 16 o 24 bytes para llave
/// fija y 16 bytes para DUKPT.
///
/// El parámetro opcional [kek] se utiliza para identificar la llave precargada
/// en el terminal que se utilizó para encriptar la PIN key.
/// Esta es la forma recomendada de cargar llaves y en algunas marcas el
/// intentar cargar llaves de PIN en claro ya no funciona por requerimiento de
/// PCI. Si la llave está encriptada y el modo de cifrado es diferente a ECB,
/// se debe setear [AlgorithmParameters] con los valores correctos.
@experimental
Future<void> cryptoPINLoadKey(
  SymmetricKey pinKey, {
  SymmetricKey? kek,
  AlgorithmParameters? algorithmParameters,
}) async {
  if (kek is DUKPTKey) {
    throw StateError("KEK cannot be DUKPT");
  }
  await cryptoChannel.invokeMethod("pinLoadKey", {
    "pinKey": pinKey.toJson(),
    "kek": kek?.toJson(),
    "algorithmParameters": algorithmParameters?.toJson(),
  });
}

/// Carga de llave para Criptografía de datos.
///
/// El rango recomendado para el índice de la llave es 1-9, el índice 0 no es
/// válido. La longitud de llave soportada es de 8, 16 o 24 bytes para llave
/// fija y 16 bytes para DUKPT.
///
/// El parámetro opcional [kek] se utiliza para identificar la llave precargada
/// en el terminal que se utilizó para encriptar la llave de datos.
/// Esta es la forma recomendada de cargar llaves y en algunas marcas el
/// intentar cargar llaves de datos en claro ya no funciona por requerimiento de
/// PCI. Si la llave está encriptada y el modo de cifrado es diferente a ECB,
/// se debe setear [AlgorithmParameters] con los valores correctos.
@experimental
Future<void> cryptoDataLoadKey(
  SymmetricKey dataKey, {
  SymmetricKey? kek,
  AlgorithmParameters? algorithmParameters,
}) async {
  if (kek is DUKPTKey) {
    throw StateError("KEK cannot be DUKPT");
  }
  await cryptoChannel.invokeMethod("dataLoadKey", {
    "dataKey": dataKey.toJson(),
    "kek": kek?.toJson(),
    "algorithmParameters": algorithmParameters?.toJson(),
  });
}

/// Elimina la llave de PIN del tipo e índice especificado
@experimental
Future<void> cryptoPINDeleteKey(SymmetricKey pinKey) async {
  await cryptoChannel.invokeMethod("pinDeleteKey", pinKey.toJson());
}

/// Elimina la llave de datos del tipo e índice especificado
@experimental
Future<void> cryptoDataDeleteKey(SymmetricKey dataKey) async {
  await cryptoChannel.invokeMethod("dataDeleteKey", dataKey.toJson());
}

/// Indica si una llave de PIN está cargada de acuerdo a su tipo e índice
@experimental
Future<bool> cryptoPINCheckKey(SymmetricKey pinKey) async {
  bool result = await cryptoChannel.invokeMethod(
    "pinCheckKey",
    pinKey.toJson(),
  );
  return result;
}

/// Indica si una llave de datos está cargada de acuerdo a su tipo e índice
@experimental
Future<bool> cryptoDataCheckKey(SymmetricKey dataKey) async {
  bool result = await cryptoChannel.invokeMethod(
    "dataCheckKey",
    dataKey.toJson(),
  );
  return result;
}

/// Encriptado de datos.
///
/// La longitud de [data] debe ser múltiplo del tamaño de bloque 3DES(8 bytes).
///
/// El parámetro para el Vector de Inicialización es obligatorio para el modo de
/// encriptado [CipherMode.CBC].
@experimental
Future<CryptoResult> cryptoDataEncrypt(
  SymmetricKey dataKey,
  Uint8List data,
  AlgorithmParameters algorithmParameters,
) async {
  if (algorithmParameters.cipherMode == CipherMode.CBC &&
      algorithmParameters.iv == null) {
    throw StateError(
      "El modo de cifrado 'CBC' requiere un vector de inicialización.",
    );
  }
  if ((data.length % 8) != 0) {
    throw StateError(
      "La longitud del cifrado debe ser múltiplo del tamaño de bloque (8 bytes)",
    );
  }

  final result = await cryptoChannel.invokeMethod("dataEncrypt", {
    "dataKey": dataKey.toJson(),
    "data": data,
    "algorithmParameters": algorithmParameters.toJson(),
  });

  return CryptoResult.fromJson(Map<String, dynamic>.from(result));
}

/// Desencriptado de datos.
///
/// La longitud de [data] debe ser múltiplo del tamaño de bloque 3DES(8 bytes).
///
/// El parámetro para el Vector de Inicialización es obligatorio para el modo de
/// desencriptado [CipherMode.CBC].
@experimental
Future<CryptoResult> cryptoDataDecrypt(
  SymmetricKey dataKey,
  Uint8List data,
  AlgorithmParameters algorithmParameters,
) async {
  if (algorithmParameters.cipherMode == CipherMode.CBC &&
      algorithmParameters.iv == null) {
    throw StateError(
      "El modo de cifrado 'CBC' requiere un vector de inicialización.",
    );
  }
  if ((data.length % 8) != 0) {
    throw StateError(
      "La longitud del cifrado debe ser múltiplo del tamaño de bloque (8 bytes)",
    );
  }

  final result = await cryptoChannel.invokeMethod("dataDecrypt", {
    "dataKey": dataKey.toJson(),
    "data": data,
    "algorithmParameters": algorithmParameters.toJson(),
  });

  return CryptoResult.fromJson(Map<String, dynamic>.from(result));
}

/// Retorna el KSN de la llave DUKPT [key] si existe
///
/// Si la llave no existe este método lanza una PlatformException con código
/// de error [AgnostikoError.KEY_MISSING]
@experimental
Future<Uint8List> cryptoGetKSN(DUKPTKey key) async {
  final result = await cryptoChannel.invokeMethod("getKSN", key.toJson());
  return result as Uint8List;
}

/// Incrementa el contador KSN asociado a la llave DUKPT [key] si existe
///
/// Si la llave no existe este método lanza una PlatformException con código
/// de error [AgnostikoError.KEY_MISSING]
@experimental
Future<void> cryptoIncrementKSN(DUKPTKey key) {
  return cryptoChannel.invokeMethod("incrementKSN", key.toJson());
}

/// Permite inyectar una llave Fija o DUKPT en formato TR31
///
/// El valor de [tr31Key] incluye el bloque TR31 a decodear y desencriptar.
///
/// El índice de [kek] permite indicar cual llave KEK previamente cargada se
/// utiliza para el desencriptado de la llave a inyectar.
@experimental
Future<void> cryptoTR31LoadKey(SymmetricKey tr31Key, SymmetricKey kek) async {
  if (kek is DUKPTKey) {
    throw StateError("KEK cannot be DUKPT");
  }
  await cryptoChannel.invokeMethod("tr31LoadKey", {
    "tr31Key": tr31Key.toJson(),
    "kek": kek.toJson(),
  });
}

/// Carga llave KEK para pruebas
///
/// NOTA: Este método es solo para uso interno del SDK.
Future<void> loadTestKEK() async {
  await cryptoChannel.invokeMethod("loadTestKEK");
}

@experimental
Future<Uint8List> generateKeyWithAsymKey(AsymmetricKey asymKey, SymmetricKey tr31Key) async {
  Uint8List result = await cryptoChannel.invokeMethod("generateKeyWithAsymKey", {
    "asymKey": asymKey.toJson(),
    "tr31Key": tr31Key.toJson(),
  });
  return result;
}