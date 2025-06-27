import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/cupertino.dart';

Future<Uint8List> imgToByteData(ui.Image img, ui.ImageByteFormat format) async {
  final byteData = await img.toByteData(format: format);
  return byteData?.buffer.asUint8List() ?? Uint8List.fromList([]);
}

/// Ticket básico para probar el proceso de renderizado e impresión
Future<PrinterScript> buildNormalTicket(GrayIntensity gray) async {
  final lines = await _buildContentNormalObject();
  return PrinterScript(lines, gray: gray);
}

Future<List<PrinterObject>> _buildContentNormalObject() async {
  const regularFont = "Roboto";
  const specialFont = "DancingScript";

  final logo = await const AssetImage("assets/img/tap_card.png").toUiImage();
  final rgbaLogo = await imgToByteData(logo, ui.ImageByteFormat.rawRgba);

  final maxWidth = await getPaperWidth();

  final lines = [
    PrinterText(
      "FontSize.XS",
      format: TextFormat(fontSize: 12, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ),
    PrinterText(
      "FontSize.S",
      format: TextFormat(fontSize: 16, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ),
    PrinterText(
      "FontSize.M",
      format: TextFormat(fontSize: 24, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ),
    PrinterText(
      "FontSize.L",
      format: TextFormat(fontSize: 32, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ),
    PrinterText(
      "FontSize.XL",
      format: TextFormat(fontSize: 48, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ),
    PrinterText(
      "Center",
      format: TextFormat(fontSize: 24, fontFamily: regularFont),
      alignment: TextAlignment.Center,
    ),
    PrinterText(
      "Right",
      format: TextFormat(fontSize: 24, fontFamily: regularFont),
      alignment: TextAlignment.Right,
    ),
    PrinterText(
      "FamilyFont",
      format: TextFormat(fontSize: 24, fontFamily: specialFont),
      alignment: TextAlignment.Left,
    ),
    PrinterText(
      "Bold",
      format: TextFormat(fontSize: 24, bold: true, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ),
    PrinterText(
      "Underline",
      format: TextFormat(
        fontSize: 24,
        underline: true,
        fontFamily: regularFont,
      ),
      alignment: TextAlignment.Left,
    ),
    PrinterSplitText(
      "Split",
      "Text",
      format: TextFormat(fontSize: 24, fontFamily: regularFont),
    ),
    PrinterImage(rgbaLogo, logo.width, logo.height, offsetX: maxWidth / 4),
    PrinterRow([
      PrinterText(
        "Head 1",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Head 2",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Head 3",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Head 4",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 3.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 4.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 3.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 4.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 3.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 4.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Head 1",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Head 2",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Head 3",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 3.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 3.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 3.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Head 1",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Head 2",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.1",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.2",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ]),
    PrinterRow([
      PrinterText(
        "Field 1.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Field 2.3",
        format: TextFormat(fontSize: 16, fontFamily: regularFont),
        alignment: TextAlignment.Left,
      ),
    ])
  ];

  return lines;
}

/// Ticket ultra largo que se utiliza para probar los límites de la impresión
///
/// En los dispositivos Android, este ticket por lo general se separa por el
/// motor de renderizado en 3 partes las cuales a su vez llevan a cabo un
/// proceso de impresión por separado para cada una
Future<PrinterScript> buildLongTicket() async {
  const regularFont = "Roboto";
  const specialFont = "DancingScript";

  final maxWidth = await getPaperWidth();

  final logoNecs =
      await const AssetImage("assets/img/logo_necs.png").toUiImage();
  final rgbaNecs = await imgToByteData(
    logoNecs,
    ui.ImageByteFormat.rawRgba,
  );
  final logoCard =
      await const AssetImage("assets/img/tap_card.png").toUiImage();
  final rgbaCard = await imgToByteData(
    logoCard,
    ui.ImageByteFormat.rawRgba,
  );

  List<PrinterObject> lines = [];
  for (var i = 0; i < 13; i++) {
    // Probamos imprimir un logo centrado
    lines.add(PrinterImage(
      rgbaNecs,
      logoNecs.width,
      logoNecs.height,
      offsetX: (maxWidth / 2) - (logoNecs.width / 2),
    ));

    // Probamos a imprimir en negrita y con subrayado
    lines.add(PrinterText(
      "Test Bold",
      format: TextFormat(fontSize: 20, fontFamily: regularFont, bold: true),
      alignment: TextAlignment.Center,
    ));
    lines.add(PrinterText(
      "Test Underline",
      format:
          TextFormat(fontSize: 20, fontFamily: regularFont, underline: true),
      alignment: TextAlignment.Center,
    ));
    lines.add(PrinterText(
      "Test Underline Bold",
      format: TextFormat(
        fontSize: 20,
        fontFamily: regularFont,
        underline: true,
        bold: true,
      ),
      alignment: TextAlignment.Center,
    ));
    lines.add(PrinterText(
      " ",
      format: TextFormat(fontSize: 20),
    ));

    // Probamos el split para imprimir 2 textos separados y alineados a
    // izquierda y derecha respectivamente
    lines.add(PrinterSplitText(
      "Test",
      "Split",
      format: TextFormat(fontSize: 20),
    ));
    lines.add(PrinterSplitText(
      "Test Long Split with line break",
      "Test Long Split with line break",
      format: TextFormat(fontSize: 24),
    ));
    lines.add(PrinterText(
      " ",
      format: TextFormat(fontSize: 20),
    ));

    // Probamos a imprimir con diferentes alineaciones y tamaños de fuente
    lines.add(PrinterText(
      "LEFT",
      format: TextFormat(fontSize: 20, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ));
    lines.add(PrinterText(
      "CENTER",
      format: TextFormat(fontSize: 20, fontFamily: regularFont),
      alignment: TextAlignment.Center,
    ));
    lines.add(PrinterText(
      "RIGHT",
      format: TextFormat(fontSize: 20, fontFamily: regularFont),
      alignment: TextAlignment.Right,
    ));
    lines.add(PrinterText(
      "LEFT",
      format: TextFormat(fontSize: 48, fontFamily: regularFont),
      alignment: TextAlignment.Left,
    ));
    lines.add(PrinterText(
      "CENTER",
      format: TextFormat(fontSize: 48, fontFamily: regularFont),
      alignment: TextAlignment.Center,
    ));
    lines.add(PrinterText(
      "RIGHT",
      format: TextFormat(fontSize: 48, fontFamily: regularFont),
      alignment: TextAlignment.Right,
    ));

    // Probamos a imprimir con una fuente custom que cargamos como un asset
    lines.add(PrinterText(
      "Test Font",
      format: TextFormat(fontSize: 24, fontFamily: specialFont),
      alignment: TextAlignment.Left,
    ));
    lines.add(PrinterText(
      "Test Font",
      format: TextFormat(fontSize: 24, fontFamily: specialFont, bold: true),
      alignment: TextAlignment.Center,
    ));
    lines.add(PrinterText(
      "Test Font",
      format: TextFormat(
        fontSize: 24,
        fontFamily: specialFont,
        underline: true,
      ),
      alignment: TextAlignment.Right,
    ));
    lines.add(PrinterText(
      " ",
      format: TextFormat(fontSize: 16),
    ));

    // Probamos a imprimir en filas tabuladas
    lines.add(PrinterRow([
      PrinterText(
        "Column 1",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Column 2",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Column 3",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Column 4",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
    ]));
    lines.add(PrinterRow([
      PrinterText(
        "Column 1",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Column 2",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Center,
      ),
      PrinterText(
        "Column 3",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Right,
      ),
    ]));
    lines.add(PrinterRow([
      PrinterText(
        "Column 1",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Column 2",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Left,
      ),
      PrinterText(
        "Column 3",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Left,
      ),
    ]));
    lines.add(PrinterRow([
      PrinterText(
        "Column 1",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Right,
      ),
      PrinterText(
        "Column 2",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Right,
      ),
      PrinterText(
        "Column 3",
        format: TextFormat(
          fontSize: 16,
          fontFamily: regularFont,
          bold: true,
        ),
        alignment: TextAlignment.Right,
      ),
    ]));
    lines.add(PrinterText(
      " ",
      format: TextFormat(fontSize: 16),
    ));

    // Probamos a imprimir una misma imagen en diferentes posiciones del papel
    lines.add(PrinterImage(
      rgbaCard,
      logoCard.width,
      logoCard.height,
      offsetX: 0,
    ));
    lines.add(PrinterImage(
      rgbaCard,
      logoCard.width,
      logoCard.height,
      offsetX: (maxWidth / 2) - (logoCard.width / 2),
    ));
    lines.add(PrinterImage(
      rgbaCard,
      logoCard.width,
      logoCard.height,
      offsetX: maxWidth - (logoCard.width * 3 / 4),
    ));
    lines.add(PrinterImage(
      rgbaCard,
      logoCard.width,
      logoCard.height,
      offsetX: maxWidth - (logoCard.width / 2),
    ));
    lines.add(PrinterText(
      " ",
      format: TextFormat(fontSize: 16),
    ));
  }

  // Marca de FIN de impresión
  lines.add(PrinterText(
    "FIN",
    format: TextFormat(fontSize: 64, bold: true),
    alignment: TextAlignment.Center,
  ));
  return PrinterScript(lines, gray: GrayIntensity.Medium);
}
