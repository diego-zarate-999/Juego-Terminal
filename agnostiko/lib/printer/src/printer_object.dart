import 'dart:typed_data';

/// Alineación de texto
enum TextAlignment { Left, Right, Center }

enum PrinterImageFormat {
  png,
  rgba,
}

/// Configuración de formato de texto a imprimir
class TextFormat {
  double fontSize;
  bool bold;
  bool underline;
  String? fontFamily;

  TextFormat({
    this.fontSize = 24,
    this.bold = false,
    this.underline = false,
    this.fontFamily,
  });

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'bold': bold,
      'underline': underline,
      'fontFamily': fontFamily
    };
  }

  factory TextFormat.fromJson(Map<String, dynamic> jsonData) {
    final fontSize = jsonData['fontSize'] as double;
    final bold = jsonData['bold'] as bool;
    final underline = jsonData['underline'] as bool;
    final fontFamily = jsonData['fontFamily'] as String?;
    return TextFormat(
      fontSize: fontSize,
      bold: bold,
      underline: underline,
      fontFamily: fontFamily,
    );
  }
}

/// Texto o conjunto de líneas a imprimir con un mismo formato
class PrinterText extends PrinterObject {
  static final objectName = "PrinterText";

  String text;
  TextFormat format;
  TextAlignment alignment;

  PrinterText(
    this.text, {
    required this.format,
    this.alignment = TextAlignment.Left,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'format': format.toJson(),
      'alignment': alignment.index,
    };
  }

  factory PrinterText.fromJson(Map<String, dynamic> jsonData) {
    String text = jsonData['text'];
    final alignment = jsonData['alignment'] as int;
    final newMap = Map<String, dynamic>.from(jsonData['format'] as Map);

    return PrinterText(
      text,
      format: TextFormat.fromJson(newMap),
      alignment: TextAlignment.values[alignment],
    );
  }

  /// Crea una definición de PrinterText para imprimir líneas en blanco en
  /// el ticket
  factory PrinterText.emptyLine(double fontSize) {
    return PrinterText("", format: TextFormat(fontSize: fontSize));
  }
}

/// Imagen a imprimir, con sus respectivas características
class PrinterImage extends PrinterObject {
  static final objectName = "PrinterImage";

  Uint8List imgRgba;
  int width;
  int height;
  double offsetX;
  double offsetY;

  PrinterImage(this.imgRgba, this.width, this.height,
      {this.offsetX = 0, this.offsetY = 0});


  factory PrinterImage.fromJson(Map<String, dynamic> jsonData) {
    final imgRgba = jsonData['imgRgba'] as Uint8List;
    final width = jsonData['width'] as int;
    final height = jsonData['height'] as int;
    final offsetX = jsonData['offsetX'] as double;
    final offsetY = jsonData['offsetY'] as double;

    return PrinterImage(
      imgRgba,
      width,
      height,
      offsetX: offsetX,
      offsetY: offsetY
    );
  }

}

/// Texto o conjunto de líneas de tipo split, a imprimir con un mismo formato
class PrinterSplitText extends PrinterObject {
  static final objectName = "PrinterSplitText";

  String text;
  String secondaryText;
  TextFormat format;

  PrinterSplitText(this.text, this.secondaryText, {required this.format});

  factory PrinterSplitText.fromJson(Map<String, dynamic> jsonData) {
    String text = jsonData['text'];
    String secondaryText = jsonData['secondaryText'];
    final newMap = Map<String, dynamic>.from(jsonData['format'] as Map);

    return PrinterSplitText(
      text,
      secondaryText,
      format: TextFormat.fromJson(newMap),
    );
  }
}

/// Permite colocar una lista de objetos PrinterObject ([PrinterText]) en una fila.
/// La fila se va a dividir segun la cantidad de objetos que tenga como hijos
class PrinterRow extends PrinterObject {
  static final objectName = "PrinterRow";

  List<PrinterObject> objects;

  PrinterRow(this.objects);

  factory PrinterRow.fromJson(Map<String, dynamic> jsonData) {
    final printObject = jsonData['objects'] as List;

    List<PrinterObject> objects =
    printObject.map((i) {
      final newMap = Map<String, dynamic>.from(i as Map);
      return PrinterObject.fromJson(newMap);

    }).toList();

    return PrinterRow(objects);
  }
}

/// Engloba a las 3 clases principales utilizadas para definir, los elementos
/// a ser impresos (PrinterText, PrinterSplitText y PrinterImage)
class PrinterObject {
  PrinterObject();

  factory PrinterObject.fromJson(Map<String, dynamic> jsonData) {
    final objectName = jsonData["objectName"];
    if (objectName is String) {
      if (objectName == PrinterText.objectName) {
        return PrinterText.fromJson(jsonData);
      } else if (objectName == PrinterSplitText.objectName) {
        return PrinterSplitText.fromJson(jsonData);
      } else if (objectName == PrinterImage.objectName) {
        return PrinterImage.fromJson(jsonData);
      } else if (objectName == PrinterRow.objectName) {
        return PrinterRow.fromJson(jsonData);
      }
    }
    throw StateError(
      "El valor de 'objectName' no es correcto para crear el PrinterObject.",
    );
  }
}
