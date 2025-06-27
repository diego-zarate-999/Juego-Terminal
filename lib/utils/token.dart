import 'dart:io';
import 'dart:typed_data';


import 'package:agnostiko/agnostiko.dart';

const _tokenFilename = "token";

/// Chequea si existe un token guardado previamente en la aplicación
Future<Uint8List?> checkToken() async {
  String? tokenStr;
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_tokenFilename');
  bool fileExists = await file.exists();
  if(fileExists){
    tokenStr = await file.readAsString();
    return tokenStr.toHexBytes();
  }else{
    return null;
  }
}

Future<Uint8List?> checkTokenMpos(String tokenMposFileName) async {
  String? tokenStr;
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$tokenMposFileName');
  bool fileExists = await file.exists();
  if(fileExists){
    tokenStr = await file.readAsString();
    return tokenStr.toHexBytes();
  }else{
    return null;
  }
}

Future<void> saveToken(String tokenStr) async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_tokenFilename');
  await file.writeAsString('$tokenStr');

}

Future<void> saveTokenMpos(String tokenMposFileName, String tokenStr) async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$tokenMposFileName');
  await file.writeAsString('$tokenStr');

}

Future<void> deleteTokenFile() async {
  try {
    final externalPath = (await getApplicationDocumentsDirectory()).path;
    final file = File('$externalPath/$_tokenFilename');
    await file.delete();

  } catch (e) {
    print("Error borrando el archivo del Token");
  }
}



