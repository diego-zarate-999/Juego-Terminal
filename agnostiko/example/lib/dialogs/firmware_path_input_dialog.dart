import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/locale.dart';

/// Abre un dialog para el ingreso de la ruta completa del firmware a actualizar.
Future<String?> showFirmwarePathDialog(BuildContext context) {
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
        title: Center(child: Text(getLocalizations(context).updateFirmware)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        content: TextField(
          controller: _textController,
          decoration: InputDecoration(
              hintText: getLocalizations(context).updateFirmwareEnterFullPath),
          keyboardType: TextInputType.text,
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
