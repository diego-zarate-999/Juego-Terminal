import 'package:flutter/material.dart';

import '../../utils/locale.dart';
import '../../utils/keypad.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String message,
  required void Function() onAccept,
  required void Function() onCancel,
}) {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: rawKeypadHandler(
          context,
          onEnter: onAccept,
          onEscape: onCancel,
        ),
        child: AlertDialog(
          actionsOverflowButtonSpacing: 1,
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          contentPadding: EdgeInsets.only(left: 25, right: 25),
          title: Center(child: Text(getLocalizations(context).confirm)),
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
              child: new Text(getLocalizations(context).accept),
              onPressed: onAccept,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              child: new Text(getLocalizations(context).cancel),
              onPressed: onCancel,
            ),
          ],
        ),
      );
    },
  );
}
