import 'package:agnostiko/agnostiko.dart';

class HistoryPrinter {
  static void printHistory() {
    final printerText = PrinterText(
      "Historial",
      format: TextFormat(
        fontSize: 24,
        bold: true,
      ),
    );

    final printerScript = PrinterScript([printerText]);

    try {
      printScript(
        printerScript,
        bottomFeed: true,
      );
    } catch (e) {
      print("ERROR: ${e.toString()}");
    }
  }
}
