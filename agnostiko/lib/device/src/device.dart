import 'dart:io';
import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/services.dart';

const deviceChannel = const HybridMethodChannel('agnostiko/Device');
// Versión interna del canal para separar del MPOS
const innerDeviceChannel = const MethodChannel('agnostiko/Device');

enum DeviceType { POS, MPOS, Mobile, PINPAD }

enum NetworkType { None, Wifi, Ethernet, Mobile, Bluetooth }

/// Información asociada a la memoria RAM.
class MemoryInfo {
  final int totalMemory;
  final int availableMemory;

  MemoryInfo({
    required this.totalMemory,
    required this.availableMemory,
  });

  Map<String, dynamic> toJson() {
    return {
      "totalMemory": totalMemory,
      "availableMemory": availableMemory,
    };
  }

  factory MemoryInfo.fromJson(Map<String, dynamic> jsonData) {
    return MemoryInfo(
      totalMemory: jsonData['totalMemory'],
      availableMemory: jsonData['availableMemory'],
    );
  }
}

/// Información asociada a la memoria interna.
class StorageInfo {
  final int totalInternalStorage;
  final int availableInternalStorage;

  StorageInfo({
    required this.totalInternalStorage,
    required this.availableInternalStorage,
  });

  Map<String, dynamic> toJson() {
    return {
      "totalInternalStorage": totalInternalStorage,
      "availableInternalStorage": availableInternalStorage,
    };
  }

  factory StorageInfo.fromJson(Map<String, dynamic> jsonData) {
    return StorageInfo(
      totalInternalStorage: jsonData['totalInternalStorage'],
      availableInternalStorage: jsonData['availableInternalStorage'],
    );
  }
}

/// Retorna información sobre la plataforma actual.
Future<PlatformInfo> getPlatformInfo() async {
  final jsonRes = await deviceChannel.invokeMethod('getPlatformInfo');
  final data = Map<String, dynamic>.from(jsonRes as Map);
  final platformInfo = PlatformInfo.fromJson(data);

  return platformInfo;
}

/// Retorna el tipo de dispositivo conectado al canal de plataforma
Future<DeviceType> getDeviceType() async {
  final deviceTypeValue = await deviceChannel.invokeMethod('getDeviceType');
  return DeviceType.values[deviceTypeValue as int];
}

/// Obtiene el número serial del dispositivo.
Future<String?> getSerialNumber() async {
  String? serialNumber = await deviceChannel.invokeMethod('getSerialNumber');
  return serialNumber;
}

/// Retorna la ruta para 'documentos' de la aplicación.
Future<Directory> getApplicationDocumentsDirectory() async {
  String path = await innerDeviceChannel.invokeMethod(
    'getApplicationDocumentsDirectory',
  );
  return Directory(path);
}

/// Reinicia el dispositivo.
Future<void> reboot() async {
  await deviceChannel.invokeMethod('reboot');
}

/// Apaga el dispositivo.
Future<void> shutdown() async {
  await deviceChannel.invokeMethod('shutdown');
}

/// Instala una aplicación de manera 'silenciosa' en el dispositivo.
///
/// El [appFilePath] debe apuntar a un archivo de instalador compatible con la
/// implementación. Ej: un '.apk' en Android o un '.NLD' en Newland Linux.
///
/// Falla con [FileSystemException] si el archivo no existe.
Future<void> installApp(String appFilePath) async {
  bool fileExists = await File(appFilePath).exists();
  if (!fileExists) {
    throw FileSystemException();
  }

  await deviceChannel.invokeMethod('installApp', appFilePath);
}

/// Desinstala una aplicación de manera 'silenciosa' en el dispositivo.
///
/// El [appPackageName] debe ser de acuerdo a las normas del sistema operativo
/// actual. Ej: algo como 'com.example.sample' en Android o como 'Sample' en
/// Newland Linux.
Future<void> uninstallApp(String appPackageName) async {
  await deviceChannel.invokeMethod('uninstallApp', appPackageName);
}

/// Obtiene el valor porcentual de la batería.
Future<int> getBatteryPercentage() async {
  int batteryPercentage =
      await deviceChannel.invokeMethod('getBatteryPercentage');
  return batteryPercentage;
}

/// Obtiene el valor en dBm de la intensidad de la señal inalambrica en uso
Future<String> getWirelessSignalStrength() async {
  String signalStrenght =
      await deviceChannel.invokeMethod('getWirelessSignalStrength');
  return signalStrenght;
}

/// Obtiene el uso de Ram en MB.
/// Se obtiene del Dispositivo "Master" en caso de implementacion para Pinpad
Future<MemoryInfo> getMemoryInfo() async {
  final memory = await deviceChannel.invokeMethod('getMemoryInfo') as Map;
  final map = Map<String, dynamic>.from(memory);
  MemoryInfo memoryInfo = MemoryInfo.fromJson(map);
  return memoryInfo;
}

/// Obtiene el modelo del terminal.
Future<String?> getModel() async {
  String? model = await deviceChannel.invokeMethod('getModel');
  return model;
}

/// Obtiene el tipo de conexión del terminal.
/// Se obtiene del Dispositivo "Master" en caso de implementacion para Pinpad
Future<NetworkType> getNetworkType() async {
  int networkType = await deviceChannel.invokeMethod('getNetworkType');
  return NetworkType.values[networkType];
}

/// Establece la fecha y hora del dispositvo.
///
/// [dateTime] es una cadena de fecha y hora, con el formato "yyyyMMddHHmmss"
Future<void> setDateTime(String dateTime) async {
  await deviceChannel.invokeMethod('setDateTime', dateTime);
}

/// Obtiene la versión de Firmware del dispositivo
Future<String?> getFirmwareVersion() async {
  String? firmwareVersion =
      await deviceChannel.invokeMethod('getFirmwareVersion');
  return firmwareVersion;
}

/// Información de almacenamiento accesible sin permisos de sistema
/// Se obtiene del Dispositivo "Master" en caso de implementacion para Pinpad
Future<StorageInfo> getStorageInfo() async {
  final storage = await deviceChannel.invokeMethod('getStorageInfo') as Map;
  final map = Map<String, dynamic>.from(storage);
  StorageInfo storageInfo = StorageInfo.fromJson(map);
  return storageInfo;
}

/// Actualiza la versión de Firmware del dispositivo
Future<void> updateFirmware(String firmwarePath) async {
  bool fileExists = await File(firmwarePath).exists();
  if (!fileExists) {
    throw FileSystemException();
  }
  await deviceChannel.invokeMethod('updateFirmware', firmwarePath);
}

/// Activa el beep de los terminales a partir de una frecuencia en hercios y una
/// duración en milisegundos suministrada. El rango de frecuencias recomendado
/// para la marcas conciliadas en el SDK va entre los 1000 y 3000 Hz
/// aproximadamente
Future<void> beep(int frequency, int durationMs) async {
  await deviceChannel.invokeMethod('beep', {
    "frequency": frequency,
    "durationMs": durationMs,
  });
}

enum LEDColor {
  Red,
  Green,
  Blue,
  Yellow,
}

enum LEDState {
  Off,
  On,
}

///Permite manipular los LEDs del terminal, a partir del seteo de un estado
///(encendido o apagado) sobre el color de LEDs indicado
Future<void> setLEDState(LEDColor color, LEDState state) async {
  await deviceChannel.invokeMethod('setLEDState', {
    "color": color.index,
    "state": state.index,
  });
}
