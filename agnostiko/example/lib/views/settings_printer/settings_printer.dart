import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../dialogs/circular_progress_dialog.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/printer_templates.dart';
import '../printer/ticket_preview.dart';

class SettingsPrinterView extends StatefulWidget {
  static String route = "/settings/printer";

  @override
  _SettingsPrinterViewState createState() => _SettingsPrinterViewState();
}

class _SettingsPrinterViewState extends State<SettingsPrinterView> {
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) async {
          if (digit == 1) {
            final ticketLight = await buildNormalTicket(GrayIntensity.Light);
            final ticketMedium = await buildNormalTicket(GrayIntensity.Medium);
            final ticketDark = await buildNormalTicket(GrayIntensity.Dark);
            _printTicket(ticketLight, ticketMedium, ticketDark);
          } else if (digit == 2) {
            _printLongTicket();
          }
        },
        onEscape: () {
          Navigator.pop(context, true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).printer),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).printerTestNormalTicket),
                onTap: () => Navigator.pushNamed(context, TicketPreview.route),
              ),
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).printerTestLargeTicket),
                onTap: _printLongTicket,
              ),
              ListTile(
                enableFeedback: true,
                title: Text("Cut Paper (kiosco)"),
                onTap: _cutTicket,
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }

  void _cutTicket() async {
    try {
      await cutPaper();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error, Does not support cutting"),
      ));
    }
  }

  void _printLongTicket() async {
    final ticket = await buildLongTicket();
    try {
      await printScript(ticket, bottomFeed: true);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).printingError),
      ));
    }
  }

  void _printTicket(PrinterScript? ticketLight, PrinterScript? ticketMedium,
      PrinterScript? ticketDark) async {
    if (ticketLight == null) return;
    if (ticketMedium == null) return;
    if (ticketDark == null) return;

    showCircularProgressDialog(context, getLocalizations(context).printing);

    try {
      final ticketWidth = await getPaperWidth();
      final threeQuartersWidth = (ticketWidth * 3) ~/ 4;
      final halfWidth = ticketWidth ~/ 2;
      // el primer ticket se imprime en 'light' y con full ancho de papel
      await printScript(ticketLight, bottomFeed: false);
      // el 2do con intensidad 'media' y utilizando solo 3/4 del ancho del papel
      await printScript(ticketMedium,
          bottomFeed: false, customPaperWidth: threeQuartersWidth);
      // el 3ro es el más oscuro en papel y utiliza solo la mitad del ancho
      await printScript(ticketDark,
          bottomFeed: true, customPaperWidth: halfWidth);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).printingError),
      ));
    } finally {
      // cerramos el dialog anterior
      Navigator.pop(context);
    }
  }
}
