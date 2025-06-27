import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';
import 'log_dialog.dart';

Future<void> showIsoLogDialog(
  BuildContext context,
  IsoMessage isoMsg, {
  required void Function() onClose,
}) {
  int lineWidth = 10;
  var isoInHex = "";
  final pack = isoMsg.pack();
  for (int i = 0; i < pack.length; i += lineWidth) {
    int end = i + lineWidth <= pack.length ? i + lineWidth : pack.length;
    final sub = pack.sublist(i, end);
    final subStr =
        sub.map((val) => val.toRadixString(16).padLeft(2, '0').toUpperCase());
    final hexStr = subStr.join(" ");

    isoInHex += "$hexStr\n";
  }

  var fieldsStr = "";
  for (final entry in isoMsg.fields.entries) {
    fieldsStr += "#${entry.key}: '${entry.value}'\n";
  }

  return showLogDialog(
    context,
    children: [
      SizedBox(
        height: 20,
      ),
      Text(""),
      Text(getLocalizations(context).isoMessageString),
      SelectableText("'$isoMsg'"),
      Text(""),
      Text(getLocalizations(context).isoMessageBCD),
      SelectableText(isoInHex),
      Text(""),
      Text(getLocalizations(context).isoMessageFields),
      SelectableText(fieldsStr),
    ],
    onClose: onClose,
  );
}
