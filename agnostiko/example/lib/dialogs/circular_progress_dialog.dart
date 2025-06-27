import 'dart:io';

import 'package:flutter/material.dart';

void showCircularProgressDialog(BuildContext context, String message,
    {Future<bool> Function()? onWillPop}) {
  // por defecto no se permite cerrar el dialog
  if (onWillPop == null) onWillPop = () async => false;

  bool enableAnimation = true;
  if (Platform.isLinux) {
    enableAnimation = false;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Dialog(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (enableAnimation) CircularProgressIndicator(),
                SizedBox(width: 20),
                Flexible(child: Text(message)),
              ],
            ),
          ),
        ),
      );
    },
  );
}
