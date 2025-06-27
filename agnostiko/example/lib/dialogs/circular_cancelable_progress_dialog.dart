import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/keypad.dart';
import '../utils/locale.dart';

Future<void> showCircularCancelableProgressDialog(
    BuildContext context, String message,
    {void Function()? onClose}) {
  bool enableAnimation = true;
  if (Platform.isLinux) {
    enableAnimation = false;
  }

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: rawKeypadHandler(
          context,
          onEscape: () {
            Navigator.popUntil(context, (route) => route.isFirst == true);
          },
        ),
        child: WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (enableAnimation) CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Flexible(child: Text(message)),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                    child: Text(getLocalizations(context).cancel),
                    onPressed: onClose ??
                        () {
                          Navigator.pop(context);
                        },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
