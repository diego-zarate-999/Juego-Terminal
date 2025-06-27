import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/locale.dart';

/// Abre un dialog para el ingreso del valor de un parámetro.
Future<String?> showParamInputDialog(
  BuildContext context, {
  required String paramName,
  required String paramValue,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  int? maxLength,
  MaxLengthEnforcement? maxLengthEnforcement,
}) {
  final _textController = TextEditingController();
  _textController.text = paramValue;

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
        title: Center(child: Text(paramName)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        content: TextField(
          controller: _textController,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLengthEnforcement:
              maxLengthEnforcement ?? MaxLengthEnforcement.none,
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
