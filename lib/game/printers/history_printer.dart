import 'package:agnostiko/agnostiko.dart';
import 'package:prueba_ag/widgets/history_container.dart';

abstract class Printer {
  PrinterScript buildTicket();
  Future<void> printTicket();
}

class HistoryPrinter extends Printer {
  HistoryPrinter(this._history);

  final History _history;

  @override
  PrinterScript buildTicket() {
    const regularFont = "Roboto";

    List<PrinterObject> lines = [
      PrinterText(
        "HISTORIAL DE JUEGOS",
        format: TextFormat(
          fontSize: 48,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterRow([
        PrinterText(
          "NO. JUEGO",
          alignment: TextAlignment.Center,
          format: TextFormat(fontSize: 20, fontFamily: regularFont),
        ),
        PrinterText(
          "NÚMERO SECRETO",
          alignment: TextAlignment.Center,
          format: TextFormat(fontSize: 20, fontFamily: regularFont),
        ),
        PrinterText(
          "RESULTADO",
          alignment: TextAlignment.Center,
          format: TextFormat(fontSize: 20, fontFamily: regularFont),
        ),
      ]),
    ];

    for (int i = 0; i < _history.secretNumbers.length; i++) {
      lines.add(
        PrinterRow([
          PrinterText(
            "${i + 1}",
            format: TextFormat(fontSize: 24, fontFamily: regularFont),
          ),
          PrinterText(
            "${_history.secretNumbers[i]}",
            format: TextFormat(fontSize: 24, fontFamily: regularFont),
          ),
          PrinterText(
            _history.results[i] ? "GANASTE" : "PERDISTE",
            format: TextFormat(fontSize: 24, fontFamily: regularFont),
          ),
        ]),
      );
    }

    lines.add(PrinterText(
      " ",
      format: TextFormat(fontSize: 64),
    ));

    lines.add(PrinterText(
      "---FIN---",
      format: TextFormat(fontSize: 64, bold: true),
      alignment: TextAlignment.Center,
    ));

    return PrinterScript(lines);
  }

  @override
  Future<void> printTicket() async {
    try {
      final printerScript = buildTicket();

      final historyWidth = await getPaperWidth() - 10;

      await printScript(
        printerScript,
        bottomFeed: false,
        customPaperWidth: historyWidth,
      );
    } catch (e) {
      throw Exception("¡Error al imprimir!");
    }
  }
}
