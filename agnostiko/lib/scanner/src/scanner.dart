import 'dart:async';

import 'package:flutter/services.dart';


const MethodChannel scannerChannel = const MethodChannel('agnostiko/Scanner');

/// Inicia el escaneo mediante hardware y retorna el contenido del código leído.
///
/// Se puede pasar opcionalmente un [timeout]. En caso de no ser suministrado,
/// el scanner permanece esperando hasta el tiempo máximo aceptado por cada
/// marca.
Future<String?> startScannerHw({int timeout = 0}) async {
  dynamic future;
  if(timeout>=120){
    throw Exception("Se excedió el valor máximo del timeout");
  }
  if (timeout > 0 && timeout < 120) {
    future = await Future.any([
      Future.delayed(Duration(seconds: timeout), () => -1),
      scannerChannel.invokeMethod("startScannerHw")
    ]);
    if(future is int){
      cancelScannerHw();
      throw TimeoutException("Scanner timeout");
    }
    else{
      return future as String?;
    }
  }else{
    return await scannerChannel.invokeMethod("startScannerHw");
  }
}


/// Cancela programáticamente un escaneo de hardware activo.
Future<void> cancelScannerHw() async {
  await scannerChannel.invokeMethod("cancelScannerHw");
}