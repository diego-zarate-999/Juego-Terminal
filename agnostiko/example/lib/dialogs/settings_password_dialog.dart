import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/keypad.dart';
import '../utils/locale.dart';
import '../utils/password.dart';

Future<bool?> showSettingsPasswordDialog(BuildContext context) {
  final _textController = TextEditingController();
  final passwordLength = 8;

  return showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        actionsOverflowButtonSpacing: 1,
        actionsPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        contentPadding: EdgeInsets.only(left: 25, right: 25),
        title: Center(child: Text(getLocalizations(context).password)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        content: TextField(
          controller: _textController,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: passwordLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
            child: Text(getLocalizations(context).accept),
            onPressed: () async {
              bool ok = await verifySettingsPassword(_textController.text);
              Navigator.pop(context, ok);
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
            child: Text(getLocalizations(context).cancel),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
        ],
      );
    },
  );
}

void onAccept(BuildContext context) {
  Navigator.popUntil(context, (route) => route.isFirst == true);
}

void onCancel() {}
