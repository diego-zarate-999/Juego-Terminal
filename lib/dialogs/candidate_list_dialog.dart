import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

/// Permite seleccionar una aplicación EMV y retorna el índice seleccionado
Future<int?> showCandidateListDialog(
  BuildContext context,
  List<EmvCandidateApp> candidateList,
) async {
  final mediaQuery = MediaQuery.of(context);
  bool showTitle = mediaQuery.size.height > 320;
  bool hasKeypad = (await getPlatformInfo()).hasKeypad;

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
            if (index >= 0 && index < candidateList.length) {
              Navigator.pop(context, index);
            }
          },
        ),
        child: AlertDialog(
          title: showTitle
              ? Center(child: Text(getLocalizations(context).selectApp))
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: Container(
            height: (mediaQuery.size.height * 3) / 5,
            width: mediaQuery.size.width / 2,
            child: _candidateList(context, candidateList, hasKeypad),
          ),
        ),
      );
    },
  );
}

ListView _candidateList(
  BuildContext context,
  List<EmvCandidateApp> candidateList,
  bool hasKeypad,
) {
  final mediaQuery = MediaQuery.of(context);
  bool showSubtitle = mediaQuery.size.height > 320;

  return ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: candidateList.asMap().entries.map((entry) {
        final index = entry.key;
        final candidate = entry.value;

        String appName = candidate.appName;
        if (hasKeypad) {
          appName = "${index + 1} - $appName";
        }

        return ListTile(
          title: Text(appName),
          subtitle: showSubtitle
              ? Text(candidate.aid.toHexStr().toUpperCase())
              : null,
          onTap: () {
            Navigator.pop(context, index);
          },
        );
      }).toList(),
    ).toList(),
  );
}
