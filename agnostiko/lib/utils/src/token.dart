import 'dart:convert';
import "dart:typed_data";
import "dart:io";

import 'package:http/http.dart' as http;

/// Obtiene el token para autorizar la inicialización del SDK.
///
/// Se necesita la [baseUrl] del server que autoriza, la marca y serial, y la
/// [appId] de la aplicación a autorizar, este valor debe coincidir con el
/// registrado en el server de licenciamiento.
///
/// Falla con [HttpException] si la respuesta del server no es exitosa lo cual
/// implica que ocurrió un error o el token no está registrado.
Future<Uint8List> getSDKToken(
  String baseUrl,
  String brand,
  String serialNumber,
  String appId,
) async {
  const version = "2";
  final response = await http.get(Uri.parse(
    '$baseUrl/token/$brand/${serialNumber.toUpperCase()}?version=$version&app=$appId',
  ));
  if (response.statusCode == 200) {
    final bytes = base64Decode(response.body);
    return bytes;
  } else {
    throw const HttpException("wrong token response");
  }
}
