import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

Future<String?> showMapSelectionDialog(
  BuildContext context,
  Map<String, String> options,
) async {
  final mediaQuery = MediaQuery.of(context);
  bool showTitle = mediaQuery.size.height > 320;
  bool hasKeypad = (await getPlatformInfo()).hasKeypad;

  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: rawKeypadHandler(
          context,
          onDigit: (digit) {},
        ),
        child: AlertDialog(
          title: showTitle
              ? Center(child: Text(getLocalizations(context).selectOption))
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: Container(
            height: (mediaQuery.size.height * 3) / 5,
            width: mediaQuery.size.width / 2,
            child: _selectionList(context, options, hasKeypad),
          ),
        ),
      );
    },
  );
}

ListView _selectionList(
  BuildContext context,
  Map<String, String> options,
  bool hasKeypad,
) {
  return ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: options.entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          subtitle: Text(entry.value),
          onTap: () {
            Navigator.pop(context, entry.value);
          },
        );
      }).toList(),
    ).toList(),
  );
}
