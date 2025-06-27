import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

Future<String?> showListSelectionDialog(
  BuildContext context,
  List<String> selectionList,
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
          onDigit: (digit) {
            int index = digit - 1;
            if (index >= 0 && index < selectionList.length) {
              Navigator.pop(context, selectionList[index]);
            }
          },
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
            child: _selectionList(context, selectionList, hasKeypad),
          ),
        ),
      );
    },
  );
}

ListView _selectionList(
  BuildContext context,
  List<String> selectionList,
  bool hasKeypad,
) {
  return ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: selectionList.asMap().entries.map((entry) {
        final index = entry.key;
        String selectionLabel = entry.value;
        if (hasKeypad) {
          selectionLabel = "${index + 1} - $selectionLabel";
        }
        return ListTile(
          title: Text(selectionLabel),
          onTap: () {
            Navigator.pop(context, entry.value);
          },
        );
      }).toList(),
    ).toList(),
  );
}
