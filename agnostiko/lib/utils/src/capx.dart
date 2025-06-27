import 'package:encrypt/encrypt.dart';
import 'package:dart_des/dart_des.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:flutter/services.dart';

import '../../cards/cards.dart';
import '../../emv/emv.dart';
import '../../ped/ped.dart';
import 'algorithms.dart';

/// Implementación de "Capítulo X" para esquema de encriptado de México.
class CapX {
  /// Índice de llave DUKPT a utilizar para el encriptado bajo "Capítulo X".
  final int keyIndex;

  final Uint8List _transportKey;

  CapX(int dukptIndex)
      : keyIndex = dukptIndex,
        _transportKey = generateRandomDESKey(16);

  /// Verifica si la llave de "Capítulo X" está cargada en el índice [keyIndex].
  Future<bool> checkKeyExists() {
    return cryptoDataCheckKey(DUKPTKey(type: KeyType.DES, index: keyIndex));
  }

  /// Encriptado de datos bajo esquema DUKPT de acuerdo a "Capítulo X".
  ///
  /// Falla si la llave no ha sido correctamente inicializada anteriormente o
  /// hay algún error durante el encriptado
  Future<DUKPTResult> encrypt(Uint8List data) {
    // TODO resolver el problema de sustituir DUKPTResult con CryptoResult
    //return cryptoDataEncrypt(DUKPTKey(type: KeyType.DES, index: keyIndex), data);
    return cryptoDUKPTEncrypt(keyIndex, data, CipherMode.ECB);
  }

  /// Obtiene el Tag 57(Track 2) directamente encriptado del kernel EMV
  ///
  /// Puede retornar nulo si no se encuentra el tag
  ///
  /// El track 2 se paddea automáticamente con 'F' a la derecha para completar
  /// los bloques para el encriptado DES
  ///
  /// Falla si la llave no ha sido correctamente inicializada anteriormente o
  /// hay algún error durante el encriptado
  Future<DUKPTResult?> getEncryptedTag57() {
    // TODO resolver el problema de sustituir DUKPTResult con CryptoResult
    // realmente de momento no hay alternativa a usar este método
    return EmvModule.instance.getDUKPTEncryptedTagValue(
      0x57, // Tag 57 - Track 2 Equivalent Data
      keyIndex,
      CipherMode.ECB,
    );
  }

  /// Obtiene la data de tracks de banda magnética directamente encriptados
  ///
  /// Los tracks se paddean automáticamente con 'F' a la derecha para completar
  /// los bloques para el encriptado DES
  ///
  /// Falla si la llave no ha sido correctamente inicializada anteriormente o
  /// hay algún error durante el encriptado
  Future<DUKPTEncryptedTracksData?> getEncryptedMagneticTracks() async {
    // TODO analizar como se pudiera resolver esto y desligarlo para Pinpad
    // realmente de momento no hay alternativa a usar este método
    return getDUKPTEncryptedTracksData(keyIndex, CipherMode.ECB);
  }

  /// Llave de transporte encriptada con llave RSA ubicada en [rsaKeyPath].
  ///
  /// La ruta del [rsaKeyPath] es relativa a los assets de la aplicación.
  ///
  /// Falla si el archivo no existe o si hay error al parsear la llave RSA.
  Future<TransportKey> getEncryptedTransportKey(String rsaKeyPath) async {
    final publicPem = await rootBundle.loadString(rsaKeyPath);
    final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;
    final encrypter = Encrypter(
      RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1),
    );
    final keyData = encrypter.encryptBytes(_transportKey).bytes;

    final transportDES = DES3(
      key: _transportKey.toList(),
      mode: DESMode.ECB,
      paddingType: DESPaddingType.None,
    );
    final kcvInts = transportDES.encrypt(List.filled(8, 0x00)).sublist(0, 3);
    final kcv = Uint8List.fromList(kcvInts);

    return TransportKey(keyData, kcv);
  }

  /// Carga la llave IPEK con el KSN inicial y la K0 encriptada del Host.
  ///
  /// La llave K0 del Host deberá venir encriptada con la llave de transporte
  /// obtenida mediante [getEncryptedTransportKey].
  ///
  /// OJO: la llave de transporte es aleatoria y varía en cada objeto [CapX].
  /// Solo se debe utilizar una vez para inicialización de la llave DUKPT.
  Future<void> loadEncryptedIPEK(Uint8List ksn, Uint8List encryptedIPEK) async {
    final transportDES = DES3(
      key: _transportKey.toList(),
      mode: DESMode.ECB,
      paddingType: DESPaddingType.None,
    );
    final ipek =
        Uint8List.fromList(transportDES.decrypt(encryptedIPEK.toList()));
    await cryptoDataLoadKey(DUKPTKey(
      type: KeyType.DES,
      index: keyIndex,
      data: ipek,
      ksn: ksn,
    ));
  }

  /// Incrementa el contador KSN asociado a la llave DUKPT
  Future<void> incrementKSN() async {
    await cryptoIncrementKSN(DUKPTKey(
      type: KeyType.DES,
      index: keyIndex,
    ));
  }
}
