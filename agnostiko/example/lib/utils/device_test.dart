import 'package:agnostiko/agnostiko.dart';

import 'log_test.dart';

final deviceInfoTestSet = [
  LogTest("Battery Percentage", _getBatteryPercentage),
  LogTest("Memory", _getRAM),
  LogTest("Model", _getModel),
  LogTest("Network Type", _getNetworkType),
  LogTest("Firmware Version", _getFirmwareVersion),
  LogTest("Internal Storage", _getStorage),
];

Future<LogTestResult> _getBatteryPercentage() async{
  final battery = await getBatteryPercentage();
  return LogTestResult(true, infoMsg: "$battery%");
}

Future<LogTestResult> _getRAM() async {
  MemoryInfo memory = await getMemoryInfo();
  int busyRAM = (memory.totalMemory - memory.availableMemory) ~/ 1048576;
  final type = await getDeviceType();
  if(type == DeviceType.PINPAD){
    return LogTestResult(true, infoMsg: "$busyRAM MB [Warning] Master Device Info");
  }else{
    return LogTestResult(true, infoMsg: "$busyRAM MB");
  }
}

Future<LogTestResult> _getModel() async{
  final model = await getModel();
  return LogTestResult(true, infoMsg: model);
}

Future<LogTestResult> _getNetworkType() async{
  final type = await getDeviceType();
  final networkType = await getNetworkType();
  if(type == DeviceType.PINPAD){
    return LogTestResult(true, infoMsg: "${networkType.name} [Warning] Master Device Info");
  }else{
    return LogTestResult(true, infoMsg: networkType.name);
  }
}

Future<LogTestResult> _getFirmwareVersion() async{
  final firmware = await getFirmwareVersion();
  return LogTestResult(true, infoMsg: firmware);
}

Future<LogTestResult> _getStorage() async {
  StorageInfo storage = await getStorageInfo();
  int busyInternalStorage =
      (storage.totalInternalStorage - storage.availableInternalStorage) ~/
          1048576;
  final type = await getDeviceType();
  if(type == DeviceType.PINPAD){
    return LogTestResult(true, infoMsg: "$busyInternalStorage MB [Warning] Master Device Info");
  }else{
    return LogTestResult(true, infoMsg: "$busyInternalStorage MB");
  }
}

