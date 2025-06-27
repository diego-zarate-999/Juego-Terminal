import 'package:flutter/material.dart';

import '../../utils/keypad.dart';
import '../../utils/locale.dart';

Future<T?> showSelectionDialog<T>(
  BuildContext context,
  Map<String, T> options,
) async {
  final mediaQuery = MediaQuery.of(context);
  bool showTitle = mediaQuery.size.height > 320;

  if (!context.mounted) return null;
  return showDialog<T?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: rawKeypadHandler(
          context,
          onDigit: (digit) {
            Navigator.pop(context, options[digit]);
          },
        ),
        child: AlertDialog(
          title: showTitle
              ? Center(child: Text(getLocalizations(context).selectOption))
              : null,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: SizedBox(
            height: (mediaQuery.size.height * 3) / 5,
            width: mediaQuery.size.width / 2,
            child: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: options.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    onTap: () {
                      Navigator.pop(context, entry.value);
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
