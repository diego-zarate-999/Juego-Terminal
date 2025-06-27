import 'package:flutter/material.dart';

import '../../utils/locale.dart';

/// Muestra el 'semáforo' para indicación de retiro de tarjeta.
///
/// Retorna una función que permite pasar un booleano para cambiar el estatus
/// [waiting] del semáforo.
void Function(bool) showCardIndicatorDialog(
  BuildContext context,
  bool waiting,
) {
  final pleaseWaitMessage = getLocalizations(context).pleaseWait;
  final removeCardMessage = getLocalizations(context).removeCard;

  StateSetter? setStateDialog;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          setStateDialog = setState;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: waiting ? Colors.green : Colors.red),
                SizedBox(width: 20),
                Text(waiting ? pleaseWaitMessage : removeCardMessage),
              ],
            ),
          );
        }),
      );
    },
  );

  return (bool flag) {
    if (setStateDialog != null) {
      setStateDialog!(() {
        waiting = flag;
      });
    }
  };
}
