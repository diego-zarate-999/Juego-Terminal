// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

/// Permite seleccionar la opción de test de encriptado con o sin KEK
Future<int?> showSharedPreferencesTestOptionDialog(
  BuildContext context,
) async {
  final mediaQuery = MediaQuery.of(context);
  bool showTitle = mediaQuery.size.height > 320;
  bool hasKeypad = (await getPlatformInfo()).hasKeypad;

  List<String> _encryptionOptions = [
    getLocalizations(context).sharedPrefsInit,
    getLocalizations(context).sharedPrefsClear
  ];

  return showDialog<int?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: rawKeypadHandler(
          context,
          onDigit: (digit) {
            int index = digit - 1;
            if (digit == 1) {
              Navigator.pop(context, index);
            } else if (digit == 2) {
              Navigator.pop(context, index);
            }
          },
          onEscape: () {
            Navigator.pop(context, null);
          },
        ),
        child: AlertDialog(
          title: showTitle ? Center(child: Text("SharedPreferences")) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: Container(
            height: (mediaQuery.size.height * 3) / 5,
            width: mediaQuery.size.width / 2,
            child: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: _encryptionOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  String option = entry.value;

                  if (hasKeypad) {
                    option = "${index + 1} - $option";
                  }

                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      Navigator.pop(context, index);
                    },
                  );
                }).toList(),
              ).toList(),
            ),
          ),
        ),
      );
    },
  );
}
