import 'dart:async';
import 'dart:typed_data';
import 'package:agnostiko/agnostiko.dart';

const libreriaUniversalChannel = const HybridMethodChannel('agnostiko');

/// Inicializa la Librería Universal de Pagos.
///
/// Debe llamarse antes de cualquier otro método asociado a una funcionalidad
/// nativa del terminal financiero.
Future<void> initSDK({Uint8List? authToken}) async {
  await libreriaUniversalChannel.invokeMethod('initSDK', authToken);
}

/// Realiza la conexión del terminal principal con el Pinpad mediante USB.
Future<void> connectPinpad() async {
  await libreriaUniversalChannel.invokeMethod('connectPinpad');
}

/// Realiza la conexión del terminal principal con el Pinpad mediante Bluetooth.
///
/// [address] es la dirección (MAC o ID dependiendo de la plataforma) del
/// dispositivo a conectar.
Future<void> connectBluetoothPinpad(String address) async {
  await libreriaUniversalChannel.invokeMethod(
      'connectBluetoothPinpad', address);
}
