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

  final maxWidth = await getPaperWidth();
  print(maxWidth);

  final premio = await const AssetImage("assets/totebag.png").toUiImage();
  final rbgaPremio = await imgToByteData(premio, ui.ImageByteFormat.rawRgba,);

  List<PrinterObject> lines = [];
  lines.add(PrinterText("Felicidades",format: TextFormat (fontFamily: regularFont)));
  lines.add(PrinterImage(rbgaPremio,premio.width, premio.height, offsetX: (maxWidth / 2) - (premio.width /2), offsetY: (maxWidth /2 ) - (premio.height /2)));


  return lines;
}
