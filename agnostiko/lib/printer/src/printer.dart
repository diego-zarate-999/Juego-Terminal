import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agnostiko/printer/src/printer_object.dart';
import 'package:agnostiko/utils/src/image.dart';

/// Estatus del terminal para impresión
enum PrinterStatus { Ok, Busy, OutOfPaper, LowVoltage, Overheat, Error }

/// Intensidad de impresión de letra
enum GrayIntensity { Light, Medium, Dark }

const MethodChannel printerChannel = const MethodChannel('agnostiko/Printer');

// Altura límite en píxeles, del contenido a renderizar e imprimir.
int _chunkLimit = Platform.isLinux ? 256 : 1024;

// Número máximo de imágenes para cada invocación de printBitmap.
int _numImagesLimit = Platform.isLinux ? 1 : 10;

/// Estructura que comprende los textos que forman el ticket a imprimir
class PrinterScript {
  List<PrinterObject> printObjects = [];
  GrayIntensity gray;

  PrinterScript(this.printObjects, {this.gray = GrayIntensity.Medium});

  Map<String, dynamic> toJson() {
    return {'printObjects': printObjects, 'gray': gray.index};
  }

  factory PrinterScript.fromJson(Map<String, dynamic> jsonData) {
    final printObject = jsonData['printObjects'] as List;

    final gray = jsonData['gray'] as int;

    List<PrinterObject> printObjects = printObject.map((i) {
      final newMap = Map<String, dynamic>.from(i as Map);
      return PrinterObject.fromJson(newMap);
    }).toList();

    return PrinterScript(printObjects, gray: GrayIntensity.values[gray]);
  }
}

// Resultado obtenido del trazado en canvas, de los distintos tipos de objetos
// que se pueden imprimir.
class _PrintResult {
  double offsetY = 0;
  bool isTheLimit = false;

  _PrintResult(this.offsetY, this.isTheLimit);
}

// Resultado de la generación de imágenes individuales y segmentadas a imprimir.
class _PrintImageResult {
  ui.Image image;
  int elementIndex;

  _PrintImageResult(this.image, this.elementIndex);
}

class PrintImagesResult {
  List<ui.Image> images;
  int elementIndex;

  PrintImagesResult(this.images, this.elementIndex);
}

/// Permite conocer el estatus de la impresora [PrinterStatus] correspondiente.
///
/// Debe llamarse antes de cada iniciar cada impresión, para verificar las
/// condiciones del terminal
Future<PrinterStatus> getPrinterStatus() async {
  int statusInt = await printerChannel.invokeMethod('getPrinterStatus');
  return PrinterStatus.values[statusInt];
}

// Permite dibujar un texto [PrinterText] en un canvas.
_PrintResult _printText(
  PrinterText element,
  double paperWidth,
  double offsetY,
  ui.Canvas canvas, {
  double? offsetX,
}) {
  double? fontSize = element.format.fontSize;
  ui.TextAlign textAlign;
  FontWeight bold;
  TextDecoration underline;
  String? fontFamily = element.format.fontFamily;

  switch (element.alignment) {
    case TextAlignment.Center:
      textAlign = ui.TextAlign.center;
      break;
    case TextAlignment.Left:
      textAlign = ui.TextAlign.left;
      break;
    case TextAlignment.Right:
      textAlign = ui.TextAlign.right;
      break;
    default:
      textAlign = ui.TextAlign.left;
      break;
  }

  if (element.format.bold) {
    bold = FontWeight.bold;
  } else {
    bold = FontWeight.normal;
  }

  if (element.format.underline) {
    underline = TextDecoration.underline;
  } else {
    underline = TextDecoration.none;
  }

  TextSpan span = TextSpan(
    text: element.text,
    style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: bold,
        decoration: underline,
        fontFamily: fontFamily),
  );
  TextPainter tp = TextPainter(
    text: span,
    textAlign: textAlign,
    textDirection: TextDirection.ltr,
  );

  tp.layout(minWidth: paperWidth, maxWidth: paperWidth);
  final possibleOffeset = offsetY + tp.height;

  if (tp.height <= _chunkLimit) {
    if (possibleOffeset <= _chunkLimit) {
      tp.paint(canvas, Offset(offsetX ?? 0, offsetY));
      bool isTheLimit = false;
      offsetY = possibleOffeset;
      return _PrintResult(offsetY, isTheLimit);
    } else {
      return _PrintResult(offsetY, true);
    }
  } else {
    throw Exception("La altura del texto no puede exceder los 1024 píxeles");
  }
}

// Permite dibujar un texto segmentado y alineado a la derecha y a la izquierda
// [PrinterSplitText], en un canvas.
_PrintResult _printSplitText(
  PrinterSplitText element,
  double paperWidth,
  double offsetY,
  ui.Canvas canvas,
) {
  double? fontSize = element.format.fontSize;
  FontWeight bold;
  TextDecoration underline;
  String? fontFamily = element.format.fontFamily;

  double halfSize = (paperWidth / 2) - 8;

  if (element.format.bold) {
    bold = FontWeight.bold;
  } else {
    bold = FontWeight.normal;
  }

  if (element.format.underline) {
    underline = TextDecoration.underline;
  } else {
    underline = TextDecoration.none;
  }

  TextSpan span = TextSpan(
    text: element.text,
    style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: bold,
        decoration: underline,
        fontFamily: fontFamily),
  );
  TextPainter tp = TextPainter(
    text: span,
    textAlign: TextAlign.left,
    textDirection: TextDirection.ltr,
  );
  tp.layout(minWidth: halfSize, maxWidth: halfSize);

  TextSpan span2 = TextSpan(
    text: element.secondaryText,
    style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: bold,
        decoration: underline,
        fontFamily: fontFamily),
  );
  TextPainter tp2 = TextPainter(
    text: span2,
    textAlign: TextAlign.right,
    textDirection: TextDirection.ltr,
  );
  tp2.layout(minWidth: halfSize, maxWidth: halfSize);

  final tpHeightMax = max(tp.height, tp2.height);
  final possibleOffeset = offsetY + tpHeightMax;

  if (tpHeightMax <= _chunkLimit) {
    if (possibleOffeset <= _chunkLimit) {
      tp.paint(canvas, Offset(0, offsetY));
      tp2.paint(canvas, Offset(paperWidth - halfSize, offsetY));
      offsetY = possibleOffeset;
      return _PrintResult(offsetY, false);
    } else {
      return _PrintResult(offsetY, true);
    }
  } else {
    throw Exception(
        "La altura máxima de los textos no puede exceder los 1024 píxeles");
  }
}

// Permite dibujar una imagen [PrinterImage] en un canvas.
Future<_PrintResult> _printImage(
    PrinterImage element, double offsetY, ui.Canvas canvas) async {
  final imgHeight = element.offsetY + element.height;
  if (imgHeight <= _chunkLimit) {
    final totalHeight = offsetY + imgHeight;
    if (totalHeight <= _chunkLimit) {
      offsetY += element.offsetY;
      final img =
          await bytesToUiImage(element.imgRgba, element.width, element.height);
      canvas.drawImage(img, Offset(element.offsetX, offsetY), Paint());
      offsetY = offsetY + element.height;
      return _PrintResult(offsetY, false);
    }
    return _PrintResult(offsetY, true);
  } else {
    throw Exception("La altura de la imagen no puede exceder los 1024 píxeles");
  }
}

// Permite dibujar un objeto [PrinterObject] en un canvas en forma de columnas.
Future<_PrintResult> _printRow(
  PrinterObject object,
  double paperWidth,
  double offsetY,
  ui.Canvas canvas,
) async {
  var data = (object as PrinterRow).objects;
  var fieldWidth = (paperWidth / data.length);
  _PrintResult result = _PrintResult(offsetY, false);
  _PrintResult finalResult;
  var height = offsetY;

  data.asMap().forEach((index, element) async {
    if (element is PrinterText) {
      result = _printText(
        element,
        fieldWidth,
        offsetY,
        canvas,
        offsetX: index * fieldWidth,
      );
      height = max(height, result.offsetY);
    } else if (element is PrinterImage) {
      // soporte para PrinterImage en PrinterRow
    } else if (element is PrinterSplitText) {
      // soporte para PrinterSplitText en PrinterRow
    } else if (element is PrinterSplitText) {
      // soporte para PrinterRow en PrinterRow
    }
  });

  final possibleOffset = height;
  finalResult = _PrintResult(possibleOffset, result.isTheLimit);
  return finalResult;
}

/// Genera una lista de imagenes a partir de un [PrinterScript].
///
/// Las imágenes generadas, son el resultado de segmentar el contenido a
/// renderizar e imprimir, para que no superen el límite de los 1024 píxeles de
/// altura.
///
/// Por defecto, las imágenes se calculan automáticamente para el ancho de papel
/// del dispositivo. En caso de que se desee o se necesite modificar el ancho
/// del papel para el cual se renderiza, se puede setear [customPaperWidth] con
/// el valor en pixeles deseado.
Future<PrintImagesResult> printToImages(
  List<PrinterObject> printerObjects,
  int elementIndex, {
  int? customPaperWidth,
}) async {
  List<ui.Image> images = [];
  int i = elementIndex;

  if (printerObjects.isEmpty) {
    return PrintImagesResult([], i);
  }

  do {
    final imageResult = await _printToImage(
      printerObjects,
      i,
      customPaperWidth: customPaperWidth,
    );
    if (images.length < _numImagesLimit) {
      images.add(imageResult.image);
      i = imageResult.elementIndex;
    } else {
      break;
    }
  } while (i < (printerObjects.length - 1));

  return PrintImagesResult(images, i);
}

// Genera una imagen a partir de la lista de [PrinterObject] que puedan ser
// abarcados en 1024 píxeles.
///
/// Por defecto, la imagen se calcula automáticamente para el ancho de papel
/// del dispositivo. En caso de que se desee o se necesite modificar el ancho
/// del papel para el cual se renderiza, se puede setear [customPaperWidth] con
/// el valor en pixeles deseado.
Future<_PrintImageResult> _printToImage(
  List<PrinterObject> printerObjects,
  int index, {
  int? customPaperWidth,
}) async {
  double offsetY = 0;

  _PrintResult printResult = _PrintResult(0, false);
  int elementIndex = 0;

  final int pixels = customPaperWidth ?? (await getPaperWidth());

  double paperWidth = pixels.toDouble();

  ui.PictureRecorder recorder = ui.PictureRecorder();

  ui.Canvas canvas = ui.Canvas(recorder);
  // colocamos un backround completamente blanco al canvas para que no
  // sea transparente porque eso no se imprime bien
  canvas.drawColor(ui.Color.fromARGB(255, 255, 255, 255), ui.BlendMode.src);

  for (int i = index; i < printerObjects.length; i++) {
    final element = printerObjects[i];
    if (element is PrinterText) {
      printResult = _printText(element, paperWidth, offsetY, canvas);
    } else if (element is PrinterImage) {
      printResult = await _printImage(element, offsetY, canvas);
    } else if (element is PrinterSplitText) {
      printResult = _printSplitText(element, paperWidth, offsetY, canvas);
    } else if (element is PrinterRow) {
      printResult = await _printRow(element, paperWidth, offsetY, canvas);
    }
    offsetY = printResult.offsetY;
    elementIndex = i;

    if (printResult.isTheLimit) {
      break;
    }
  }

  final image = await recorder
      .endRecording()
      .toImage(paperWidth.floor(), printResult.offsetY.floor());

  return _PrintImageResult(image, elementIndex);
}

/// Retorna un conjunto de Bytes con la imagen en formato en especifico
/// para renderizarla.
///
/// Por defecto, la impresión se calcula automáticamente para el ancho de papel
/// del dispositivo. En caso de que se desee o se necesite modificar el ancho
/// del papel para el cual se renderiza, se puede setear [customPaperWidth] con
/// el valor en pixeles deseado.
///
/// Nota: Solo se retornan los primeros 1024 píxeles de altura.
Future<Uint8List> printToBytes(
  PrinterScript printerScript,
  PrinterImageFormat format, {
  int? customPaperWidth,
}) async {
  List<PrinterObject> printerObjects = printerScript.printObjects;
  if (printerObjects.isEmpty) {
    return Uint8List.fromList([]);
  }

  final result = await printToImages(
    printerObjects,
    0,
    customPaperWidth: customPaperWidth,
  );
  late ByteData? data;

  final img = result.images[0];
  if (format == PrinterImageFormat.png) {
    data = await img.toByteData(format: ui.ImageByteFormat.png);
  } else if (format == PrinterImageFormat.rgba) {
    data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  }
  var rgba = data?.buffer.asUint8List() ?? Uint8List.fromList([]);

  return rgba;
}

/// Inicia el proceso de impresión en el terminal.
///
/// La impresión se realiza a partir de script suministrado con su respectivo
/// estilo por línea [printerScript] y se puede setear opcionalmente que se
/// tenga un feed al final de la impresión [bottomFeed] (para alinear el ticket
/// con el punto de corte del papel). En caso de no pasarse este parámetro el
/// valor por default es falso y no se deja un espacio al final.
///
/// Por defecto, la impresión se calcula automáticamente para el ancho de papel
/// del dispositivo. En caso de que se desee o se necesite modificar el ancho
/// del papel para el cual se renderiza, se puede setear [customPaperWidth] con
/// el valor en pixeles deseado.
///
/// Nota: Se recomienda la división de tickets de grandes longitudes en
/// múltiples [PrinterScript] de dimensiones moderadas e imprimirlos
/// sucesivamente para el armado de tickets largos. De esta forma, se evitan
/// posibles crasheos ya que renderizar un ticket demasiado largo puede ser muy
/// exigente sobre la memoria RAM del dispositivo.
Future<void> printScript(
  PrinterScript printerScript, {
  bool bottomFeed = false,
  int? customPaperWidth,
}) async {
  var allRgbaData = BytesBuilder();

  int i = 0;
  List<PrinterObject> printerObjects = printerScript.printObjects;

  if (printerObjects.isEmpty) {
    return;
  }

  do {
    allRgbaData.clear();
    int totalHeight = 0;
    int width = 0;
    final imageResult = await printToImages(
      printerObjects,
      i,
      customPaperWidth: customPaperWidth,
    );
    i = imageResult.elementIndex;

    for (var img in imageResult.images) {
      final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      totalHeight = totalHeight + img.height;
      width = img.width;
      var rgba = byteData?.buffer.asUint8List() ?? Uint8List.fromList([]);
      allRgbaData.add(rgba);
    }

    final rgba = allRgbaData.toBytes();

    if (i == (printerObjects.length - 1)) {
      await printBitmap(rgba, width, totalHeight, printerScript.gray,
          bottomFeed: bottomFeed);
    } else {
      await printBitmap(rgba, width, totalHeight, printerScript.gray,
          bottomFeed: false);
    }
  } while (i < (printerObjects.length - 1));
}

/// Permite la  impresión en el terminal a partir del bitmap suministrado
/// [bitmapRGBA] con sus respectivas características: alto, ancho, intensidad
/// de gris y si se desea, feed o espacio al final de la impresión [width],
/// [height], [gray] y [bottomFeed]
Future<void> printBitmap(
  Uint8List bitmapRGBA,
  int width,
  int height,
  GrayIntensity gray, {
  bool bottomFeed = false,
}) async {
  await printerChannel.invokeMethod(
    'printBitmap',
    {
      'bitmapRGBA': bitmapRGBA,
      'width': width,
      'height': height,
      'gray': gray.index,
      'bottomFeed': bottomFeed,
    },
  );
}

/// Permite conocer el número máximo de pixeles en ancho que se puede imprimir
Future<int> getPaperWidth() async {
  int paperWidth = await printerChannel.invokeMethod('getPaperWidth');
  return paperWidth;
}

/// Permite cortar el papel
Future<void> cutPaper() async {
  return await printerChannel.invokeMethod('cutPaper');
}
