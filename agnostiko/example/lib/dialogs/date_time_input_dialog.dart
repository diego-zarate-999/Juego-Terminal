import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/locale.dart';

/// Abre un dialog para el ingreso del valor de un parámetro.
Future<String?> showDateTimeInputDialog(BuildContext context) {
  final _textController = TextEditingController();

  return showDialog<String?>(
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
        title: Center(child: Text(getLocalizations(context).datetime)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        content: TextField(
          controller: _textController,
          decoration: InputDecoration(hintText: "yyyyMMddHHmmss"),
          keyboardType: TextInputType.number,
          maxLength: 14,
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
            onPressed: () {
              Navigator.pop(context, _textController.text);
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
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
