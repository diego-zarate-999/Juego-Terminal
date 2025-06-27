import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../dialogs/circular_cancelable_progress_dialog.dart';
import '../../dialogs/date_time_input_dialog.dart';
import '../../dialogs/device_dialog.dart';
import '../../dialogs/firmware_path_input_dialog.dart';
import '../../dialogs/info_dialog.dart';
import '../../dialogs/confirm_dialog.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../utils/comm.dart';
import '../../utils/device_test.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/log_test.dart';
import '../test_logger/test_logger.dart';

class SettingsDeviceView extends StatefulWidget {
  static String route = "/settings/device";

  @override
  _SettingsDeviceViewState createState() => _SettingsDeviceViewState();
}

class _SettingsDeviceViewState extends State<SettingsDeviceView> {
  bool _hasScannerHw = false;
  bool _isPinpad = false;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      final platformInfo = await getPlatformInfo();
      final deviceType = await getDeviceType();
      setState(() {
        _hasScannerHw = platformInfo.hasScannerHw;
        _isPinpad = deviceType == DeviceType.PINPAD ? true : false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) {
          if (digit == 2) {
            _rebootDevice();
          } else if (digit == 3) {
            _shutdownDevice();
          }
        },
        onEscape: () {
          Navigator.pop(context, true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).device),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).deviceInformation),
                onTap: _getDeviceInformation,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).rebootDevice),
                onTap: _rebootDevice,
              ),
              ListTile(
                enabled: !_isPinpad,
                title: Text(getLocalizations(context).shutdownDevice),
                onTap: _shutdownDevice,
              ),
              ListTile(
                enabled: !_isPinpad,
                title: Text(getLocalizations(context).downloadApp),
                onTap: _downloadApp,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).installApp),
                onTap: _installApp,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).uninstallApp),
                onTap: _uninstallApp,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).updateFirmware),
                onTap: _updateFirmware,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).beeper),
                onTap: _testBeeper,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).led),
                onTap: _testLED,
              ),
              ListTile(
                enabled: _hasScannerHw,
                enableFeedback: true,
                title: Text(getLocalizations(context).scanner),
                onTap: _testStartScanner,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).datetime),
                onTap: _setDateTime,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).signalStrength),
                onTap: _getSignalStrength,
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }

  void _getSignalStrength() async {
    var strength = await getWirelessSignalStrength();
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            contentPadding: EdgeInsets.only(left: 30, right: 30),
            title: Center(
              child: Text(getLocalizations(context).signalStrength),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            content: SizedBox(
              height: 100,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text("$strength dBm"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(getLocalizations(context).exit),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _runSet(List<LogTest> testSet) {
    Navigator.pushNamed(
      context,
      TestLoggerView.route,
      arguments: testSet,
    );
  }

  void _getDeviceInformation() {
    _runSet(deviceInfoTestSet);

  }

  Future<void> _downloadApp() async {
    // nos aseguramos de obtener el permiso de almacenamiento antes de seguir
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses[Permission.storage] != PermissionStatus.granted) {
        showInfoDialog(
          context,
          getLocalizations(context).storagePermissionRequired,
        );
        return;
      }
    }

    String filePath;
    String url;
    if (Platform.isAndroid) {
      filePath = "/mnt/sdcard/Download/sample.apk";
      url =
          "https://github.com/willians06/sample/releases/download/0.0.1/sample.apk";
    } else if (Platform.isLinux) {
      var model = await getModel();
      if (model == 'ME60') {
        filePath = "/tmp/wifi.nld";
      } else {
        filePath = "/app/LUP-Example/wifi.nld";
      }
      url =
          "http://github.com/willians06/sample/releases/download/0.0.1/wifi.nld";
    } else {
      return;
    }

    showCircularProgressDialog(
      context,
      getLocalizations(context).downloadingApp,
    );

    try {
      await downloadFile(url, filePath);
      Navigator.pop(context);
      showInfoDialog(context, getLocalizations(context).appDownloadSuccess);
    } catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).internalError}\n$e");
      print("Error: $e");
    }
  }

  Future<void> _installApp() async {
    String appFilePath;
    if (_isPinpad) {
      appFilePath = "/mnt/sdcard/Download/sample.NLP";
    } else {
      if (Platform.isAndroid) {
        appFilePath = "/mnt/sdcard/Download/sample.apk";
      } else if (Platform.isLinux) {
        var model = await getModel();
        if (model == 'ME60') {
          appFilePath = "/tmp/wifi.nld";
        } else {
          appFilePath = "/app/LUP-Example/wifi.nld";
        }
      } else {
        return;
      }
    }

    showCircularProgressDialog(
      context,
      getLocalizations(context).installingApp(appFilePath),
    );

    try {
      await installApp(appFilePath);
      Navigator.pop(context);
      showInfoDialog(context, getLocalizations(context).appInstallSuccess);
    } on FileSystemException {
      Navigator.pop(context);
      showInfoDialog(context, getLocalizations(context).appInstallerNotExist);
    } catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).internalError}\n$e");
      print("Error: $e");
    }
  }

  Future<void> _uninstallApp() async {
    String appPackageName;
    if (Platform.isAndroid) {
      appPackageName = "com.apps2go.sample";
    } else if (Platform.isLinux) {
      appPackageName = "wifi";
    } else {
      return;
    }

    showCircularProgressDialog(
      context,
      getLocalizations(context).uninstallingApp(appPackageName),
    );

    try {
      await uninstallApp(appPackageName);
      Navigator.pop(context);
      showInfoDialog(context, getLocalizations(context).appUninstallSuccess);
    } on PlatformException catch (e) {
      if (e.details == AgnostikoError.UNSUPPORTED) {
        Navigator.pop(context);
        showInfoDialog(context, getLocalizations(context).unsupported);
        print("Error: $e");
      } else {
        Navigator.pop(context);
        showInfoDialog(
            context, "${getLocalizations(context).internalError}\n$e");
        print("Error: $e");
        print("Details: ${e.details}");
      }
    } on FileSystemException catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "Error: ${e.message}");
    } catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).internalError}\n$e");
      print("Error: $e");
    }
  }

  void _rebootDevice() {
    showConfirmDialog(
      context,
      message: getLocalizations(context).rebootDeviceConfirmation,
      onAccept: () async {
        await reboot();
        final deviceType = await getDeviceType();
        if (deviceType == DeviceType.PINPAD) {
          exit(0);
        }
      },
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  void _shutdownDevice() {
    showConfirmDialog(
      context,
      message: getLocalizations(context).shutdownDeviceConfirmation,
      onAccept: () {
        shutdown();
      },
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  void _setDateTime() async {
    final dateTime = await showDateTimeInputDialog(context);
    if (dateTime != null) {
      await setDateTime(dateTime);
    }
  }

  void _updateFirmware() async {
    // nos aseguramos de obtener el permiso de almacenamiento antes de seguir
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    if (statuses[Permission.storage] != PermissionStatus.granted) {
      showInfoDialog(
        context,
        getLocalizations(context).storagePermissionRequired,
      );
      return;
    }

    final firmwarePath = await showFirmwarePathDialog(context);
    if (firmwarePath != null) {
      try {
        showCircularProgressDialog(
          context,
          getLocalizations(context).updatingFirmware,
        );
        await updateFirmware(firmwarePath);
        Navigator.pop(context);
      } on PlatformException catch (e) {
        if (e.details == AgnostikoError.UNSUPPORTED) {
          Navigator.pop(context);
          showInfoDialog(context, getLocalizations(context).unsupported);
          print("Error: $e");
        } else {
          Navigator.pop(context);
          showInfoDialog(
              context, "${getLocalizations(context).internalError}\n$e");
          print("Error: $e");
          print("Details: ${e.details}");
        }
      } catch (e) {
        Navigator.pop(context);
        showInfoDialog(
            context, "${getLocalizations(context).internalError}\n$e");
        print("Error: $e");
      }
    }
  }

  void _testBeeper() async {
    await beep(500, 500);
    await Future.delayed(Duration(seconds: 1));
    await beep(1000, 500);
    await Future.delayed(Duration(seconds: 1));
    await beep(1500, 500);
    await Future.delayed(Duration(seconds: 1));
    await beep(2000, 500);
    await Future.delayed(Duration(seconds: 1));
    await beep(2500, 500);
    await Future.delayed(Duration(seconds: 1));
    await beep(3000, 500);
    await Future.delayed(Duration(seconds: 1));
  }

  void _testLED() async {
    await setLEDState(LEDColor.Red, LEDState.On);
    await Future.delayed(Duration(milliseconds: 500));
    await setLEDState(LEDColor.Red, LEDState.Off);

    await setLEDState(LEDColor.Blue, LEDState.On);
    await Future.delayed(Duration(milliseconds: 500));
    await setLEDState(LEDColor.Blue, LEDState.Off);

    await setLEDState(LEDColor.Green, LEDState.On);
    await Future.delayed(Duration(milliseconds: 500));
    await setLEDState(LEDColor.Green, LEDState.Off);

    await setLEDState(LEDColor.Yellow, LEDState.On);
    await Future.delayed(Duration(milliseconds: 500));
    await setLEDState(LEDColor.Yellow, LEDState.Off);

    await Future.delayed(Duration(milliseconds: 500));
    await setLEDState(LEDColor.Red, LEDState.On);
    await setLEDState(LEDColor.Blue, LEDState.On);
    await setLEDState(LEDColor.Green, LEDState.On);
    await setLEDState(LEDColor.Yellow, LEDState.On);
    await Future.delayed(Duration(milliseconds: 500));
    await setLEDState(LEDColor.Red, LEDState.Off);
    await setLEDState(LEDColor.Blue, LEDState.Off);
    await setLEDState(LEDColor.Green, LEDState.Off);
    await setLEDState(LEDColor.Yellow, LEDState.Off);
  }

  Future<void> _testStartScanner() async {
    showCircularCancelableProgressDialog(
        context, getLocalizations(context).scanning,
        onClose: _testCancelScanner);
    try {
      final content = await startScannerHw(timeout: 30);
      Navigator.pop(context);
      if (content != null) {
        showInfoDialog(
            context, "${getLocalizations(context).scannerContent}: $content");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getLocalizations(context).scannerNullResult),
        ));
      }
    } on TimeoutException {
      Navigator.pop(context);
      showInfoDialog(context, getLocalizations(context).scannerTimeout);
    } catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).internalError}\n$e");
      print("Error: $e");
    }
  }

  Future<void> _testCancelScanner() async {
    try {
      await cancelScannerHw();
      showInfoDialog(context, getLocalizations(context).scannerStop);
    } catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).internalError}\n$e");
      print("Error: $e");
    }
  }
}
