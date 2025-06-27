import 'package:flutter/services.dart';

import 'bluetooth_device.dart';

const bluetoothChannel = MethodChannel('agnostiko/Bluetooth');

/// Retorna la lista de dispositivos bluetooth emparejados
Future<List<BluetoothDevice>> getBondedBluetoothDevices() async {
  final list = await bluetoothChannel.invokeMethod("getBondedDevices") as List;
  return list
      .map((data) =>
          BluetoothDevice.fromJson(Map<String, dynamic>.from(data as Map)))
      .toList();
}

/// Indica si el dispositivo tiene el bluetooth disponible y listo para usar
Future<bool> isBluetoothEnabled() async {
  final isEnabled =
      await bluetoothChannel.invokeMethod("isBluetoothEnabled") as bool;
  return isEnabled;
}
