import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

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
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/printer_templates.dart';

class SettingsPinpadView extends StatefulWidget {
  static String route = "/settings/pinpad";

  @override
  _SettingsPinpadViewState createState() => _SettingsPinpadViewState();
}

class _SettingsPinpadViewState extends State<SettingsPinpadView> {
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) {
          if (digit == 2) {
          } else if (digit == 3) {}
        },
        onEscape: () {
          Navigator.pop(context, true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).pinpad),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).goBackHome),
                onTap: _goBackHome,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).clearScreen),
                onTap: _clearScreen,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).displayText),
                onTap: _displayText,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).displayImg),
                onTap: _displayImage,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).displayColorImg),
                onTap: _displayColorImage,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).pingPinpad),
                onTap: _pingPinpad,
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }

  Future<void> _goBackHome() async {
    await showPinpadHome();
  }

  Future<void> _clearScreen() async {
    await clearPinpadScreen();
  }

  Future<void> _displayText() async {
    final textParameters = PinpadTextParameters();
    await showPinpadText([
      getLocalizations(context).pinpadTest,
      "",
      getLocalizations(context).pinpadHelloWorld
    ], textParameters);
  }

  Future<void> _displayImage() async {
    ByteData data = await rootBundle.load('assets/img/panda_icon.bmp');
    Uint8List imageData = data.buffer.asUint8List();
    await showPinpadImage(imageData, 5, 5);
  }

  Future<void> _displayColorImage() async {
    //final byteData = await rootBundle.load('assets/img/garfield_image.bin'); //100*100
    //final imageData = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    final assetsImg = await  AssetImage("assets/img/mario_2d.jpg").toUiImage();

    final byteDataImg = await assetsImg.toByteData(format: ui.ImageByteFormat.rawRgba);
    final rgbaImg = byteDataImg?.buffer.asUint8List() ?? Uint8List.fromList([]);

    final imageData = convertRGBAtoRGB16(rgbaImg, assetsImg.width, assetsImg.height);
    await showPinpadColorImage(imageData, 0, 0, assetsImg.width, assetsImg.height);
  }

  Future<void> _pingPinpad() async {
    final ping = await pingPinpad();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ping.toString())));
  }
}
