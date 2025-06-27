import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/services.dart';

import '../../utils/locale.dart';
import 'info_dialog.dart';
import 'log_dialog.dart';

Future<void> showDeviceDialog(
  BuildContext context, {
  required void Function() onClose,
}) async {
  try {
    DeviceType deviceType = await getDeviceType();
    int battery = await getBatteryPercentage();
    MemoryInfo memory = await getMemoryInfo();
    int busyRAM = (memory.totalMemory - memory.availableMemory) ~/ 1048576;
    String? model = await getModel();
    NetworkType networkType = await getNetworkType();
    String? firmwareVersion = await getFirmwareVersion();
    StorageInfo storage = await getStorageInfo();
    int busyInternalStorage =
        (storage.totalInternalStorage - storage.availableInternalStorage) ~/
            1048576;

    return showLogDialog(
      context,
      children: [
        SizedBox(
          height: 20,
        ),
        if (deviceType == DeviceType.PINPAD)
          Text(
            getLocalizations(context).pinpadDeviceInfo,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        if (deviceType == DeviceType.PINPAD) SizedBox(height: 5),
        Text(getLocalizations(context).deviceBattery),
        SelectableText("'$battery%'"),
        Text(""),
        Text(getLocalizations(context).deviceModel),
        SelectableText("'$model'"),
        Text(""),
        Text(getLocalizations(context).deviceFirmwareVersion),
        SelectableText("'$firmwareVersion'"),
        Text(""),
        if (deviceType == DeviceType.PINPAD)
          Text(
            getLocalizations(context).masterDeviceInfo,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        if (deviceType == DeviceType.PINPAD) SizedBox(height: 5),
        Text(getLocalizations(context).deviceInternalStorage),
        SelectableText("'$busyInternalStorage MB'"),
        Text(""),
        Text(getLocalizations(context).deviceMemory),
        SelectableText("'$busyRAM MB'"),
        Text(""),
        Text(getLocalizations(context).deviceNetwork),
        SelectableText("'${networkType.name}'"),
      ],
      onClose: onClose,
    );
  } on PlatformException catch (e) {
    if (e.details == AgnostikoError.UNSUPPORTED) {
      print(e);
      return showInfoDialog(context, getLocalizations(context).unsupported);
    } else {
      print(e);
      return showInfoDialog(context,
          "${getLocalizations(context).internalError}\n${e.code}\n${e.message}\n${e.details}");
    }
  } catch (e) {
    print(e);
    return showInfoDialog(
        context, "${getLocalizations(context).internalError}\n$e");
  }
}
