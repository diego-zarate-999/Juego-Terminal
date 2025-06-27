import 'dart:async';
import 'dart:typed_data';

import 'package:agnostiko/serialport/serialport.dart';
import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';

showSerialPortTestDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return serialPortView();
    },
  );
}

class serialPortView extends StatefulWidget {
  const serialPortView({super.key});

  @override
  State<serialPortView> createState() => _serialPortViewState();
}

class _serialPortViewState extends State<serialPortView> {
  String serialStatus = "";
  String dataReceived = "";
  bool serialEnabled = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsOverflowButtonSpacing: 1,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      title:const Center(child: Text("Serial session")),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 250.0,
          height: 250.0,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text("Session state:"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(serialStatus),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text("Data: $dataReceived"),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
                onPressed: serialEnabled
                    ? () {
                        _sendDataToSerial();
                      }
                    : null,
                child: const Text("write test to serial"),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          ),
          onPressed: serialEnabled
              ? null
              : () {
                  _startSerialSession();
                  serialStatus = "on";
                  setState(() {});
                },
          child: const Text("Init Serial"),
        ),
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          ),
          onPressed: serialEnabled
              ? () {
                  _closeSerialSession();
                  serialStatus = "off";
                  setState(() {});
                  Navigator.pop(context);
                }
              : null,
          child: const Text("Close Serial"),
        ),
      ],
    );
  }

  _closeSerialSession() async {
    serialEnabled = false;
    await closeSerial();
  }

  _startSerialSession() async {
    serialEnabled = true;
    final serialDataStream = openSerial();
    try {
      await for (final event in serialDataStream) {
        if (!mounted) return;
        setState(() {
          dataReceived = event.data.toString();
        });
      }
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serial port open error"),
      ));
      debugPrint("Error: $e");
      debugPrint(stackTrace.toString());
      Navigator.popUntil(context, (route) => route.isFirst == true);
    }
  }

  _sendDataToSerial() async {
    Uint8List dataString = Uint8List.fromList([0x31, 0x32, 0x33]);
    await writeSerial(dataString);
  }
}
