import 'dart:io';
import 'package:flutter/services.dart';

import 'package:agnostiko/agnostiko.dart';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

/// Utilidades para el manejo de claves RSA para encriptación y desencriptación
/// de llaves
/// 
/// Para generar claves de prueba se usa el archivo [ejemplo.pem] del cual de
/// obtienen las llaves publica y privada de RSA

/// Guarda el archivo de prueba en la carpeta temporal ya que en por el momento
/// no se pudo cargar como ruta relativa
Future<String> getAbsolutePath(String path, String name) async {
  final tempDir = Directory.systemTemp.path;
  String newFilePath = '$tempDir/$name';

  ByteData data = await rootBundle.load(path);
  Uint8List bytes = data.buffer.asUint8List();

  File file = File(newFilePath);
  await file.writeAsBytes(bytes, flush: true);

  return file.path;
}

/// Genera la llave publica y privada de RSA
/// para uso de encriptación y desencriptación
Future<RSAPublicKey> getPublicKey<RSAPublicKey extends RSAAsymmetricKey>(String path) async {
  final file = File(path);
  final pem = await file.readAsString();
  final parser = RSAKeyParser();
  final key = parser.parse(pem) as RSAPublicKey;

  return key;
}
Future<RSAPrivateKey> getPrivKey<RSAPrivateKey extends RSAAsymmetricKey>(String path) async {
  final file = File(path);
  final pem = await file.readAsString();
  final parser = RSAKeyParser();
  final key =  parser.parse(pem) as RSAPrivateKey;

  return key;
}

/// Desencripta con RSA en formato de PKCS#1 con SHA-256
///
/// De ser necesario se puede modificar o cambiar el algoritmo
Uint8List decryptRSA(Uint8List data, RSAPrivateKey key) {
  final decryptor = OAEPEncoding.withSHA256(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(key));

  return decryptor.process(data);
}

/// Función para desencriptar:
/// 
/// data es la data de la llave Asymetrica
/// path es la ruta de la llave en formato PEM
/// name es el nombre de la llave ya que al momento no se puede cargar como ruta
/// relativa
Future<String> rsaDecryptResult(Uint8List data, String path, String name) async {
  final absPath = await getAbsolutePath(path, name);
  final privKey = await getPrivKey<RSAPrivateKey>(absPath);

  final p = AsymmetricBlockCipher("RSA/PKCS1");
  p.init(false, PrivateKeyParameter<RSAPrivateKey>(privKey));

  Uint8List decryptedData  = decryptRSA(data, privKey);
  return decryptedData.toHexStr();
}
