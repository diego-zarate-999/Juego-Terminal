import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:agnostiko/agnostiko.dart';
import 'package:agnostiko_example/dialogs/circular_progress_dialog.dart';
import 'package:agnostiko_example/utils/locale.dart';
import 'package:flutter/material.dart';

import '../../utils/printer_templates.dart';

class TicketPreview extends StatefulWidget {
  static String route = "/settings/printer/ticket_preview";

  @override
  _TicketPreviewState createState() => _TicketPreviewState();
}

class _TicketPreviewState extends State<TicketPreview> {
  static String route = "/settings/printer/ticket_preview";

  PrinterScript? ticketLight;
  PrinterScript? ticketMedium;
  PrinterScript? ticketDark;

  @override
  initState() {
    super.initState();
    _init();
  }

  _init() async {
    ticketLight = await buildNormalTicket(GrayIntensity.Light);
    ticketMedium = await buildNormalTicket(GrayIntensity.Medium);
    ticketDark = await buildNormalTicket(GrayIntensity.Dark);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Ticket Preview"),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () =>
                _printTicket(ticketLight, ticketMedium, ticketDark),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: _ticketPreview(),
        ),
      ),
      backgroundColor: Colors.white24,
    );
  }

  Widget _ticketPreview() {
    final ticket = ticketMedium;
    if (ticket == null) return Center(child: CircularProgressIndicator());

    return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
                constraints: BoxConstraints(
                  maxWidth: 380,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.memory(snapshot.data as Uint8List),
                ));
          }
          return Center(child: CircularProgressIndicator());
        },
        future: printToBytes(ticket, PrinterImageFormat.png));
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
