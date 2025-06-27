import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';
import 'confirm_dialog.dart';

/// Retorna una función para asignar a callback 'onWillPop'.
///
/// Si se acepta, este Dialog cancela cualquier proceso de detección de tarjetas
/// o transacción que se esté llevando a cabo.
Future<bool> Function() cancelTransactionDialogFn(BuildContext context) {
  Future<bool> Function() showDialogFn = () async {
    final value = await showConfirmDialog(
      context,
      message: getLocalizations(context).confirmCancelTransaction,
      onAccept: () async {
        // Importante cerrar estos procesos correctamente para no tener problemas
        await closeCardReader();
        await cancelEmvTransaction();

        Navigator.popUntil(context, (route) => route.isFirst == true);
      },
      onCancel: () {
        Navigator.pop(context, false);
      },
    );
    return value == true;
  };

  return showDialogFn;
}
