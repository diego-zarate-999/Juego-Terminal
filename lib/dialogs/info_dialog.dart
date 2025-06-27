import 'package:flutter/material.dart';

import '../../utils/locale.dart';
import '../utils/keypad.dart';

Future<void> showInfoDialog(
  BuildContext context,
  String message, {
  void Function()? onClose,
}) {
  return showDialog(
    context: context,
    barrierDismissible: onClose == null ? true : false,
    builder: (context) {
      return RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: rawKeypadHandler(
          context,
          onEscape: () {
            Navigator.popUntil(context, (route) => route.isFirst == true);
          },
          onBackspace: () {
            Navigator.pop(context);
          },
          onEnter: (() {
            Navigator.pop(context);
          }),
        ),
        child: WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            actionsOverflowButtonSpacing: 1,
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Center(child: Text(getLocalizations(context).info)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            content: Text(message),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
                child: Text(getLocalizations(context).close),
                onPressed: onClose ??
                    () {
                      Navigator.pop(context);
                    },
              ),
            ],
          ),
        ),
      );
    },
  );
}
