import 'dart:async';

import 'package:flutter/services.dart';


const MethodChannel pinpadChannel = const MethodChannel('agnostiko/Pinpad');

enum PinpadTextAlignment { CENTER, DEFAULT, LEFT, RIGHT }

enum PinpadFontSize { LARGE, NORMAL, SMALL }

/// Parámetros asociados al texto a mostrar en pantalla del Pinpad.
class PinpadTextParameters {
  final PinpadTextAlignment textAlignment;
  final int fontColor;
  final PinpadFontSize fontSize;

  PinpadTextParameters({this.textAlignment = PinpadTextAlignment.DEFAULT, this.fontColor = 0, this.fontSize = PinpadFontSize.NORMAL });

  Map<String, dynamic> toJson() {
    return {
      "textAlignment": textAlignment.index,
      "fontColor": fontColor,
      "fontSize":  fontSize.index,
    };
  }

  factory PinpadTextParameters.fromJson(Map<String, dynamic> jsonData) {
    final textAlignment = jsonData['textAlignment'] as int;
    final fontSize = jsonData['fontSize'] as int;
    return PinpadTextParameters(
      textAlignment: PinpadTextAlignment.values[textAlignment],
      fontColor: jsonData['fontColor'],
      fontSize: PinpadFontSize.values[fontSize],
    );
  }
}

/// Regresa a la pantalla de inicio del Pinpad (home)
Future<void> showPinpadHome() async {
  await pinpadChannel.invokeMethod("showPinpadHome");
}


/// Limpia la pantalla del Pinpad
Future<void> clearPinpadScreen() async {
  await pinpadChannel.invokeMethod("clearPinpadScreen");
}


/// Muestra textos en pantalla del Pinpad.
///
/// Se debe suministrar una lista con los textos a mostrar [text] y las
/// características a aplicar a dichos textos [textParameters]
Future<void> showPinpadText(List<String> text, PinpadTextParameters textParameters) async {
  await pinpadChannel.invokeMethod("showPinpadText", {
  "text": text,
  "textParameters": textParameters.toJson(),
  });
}


/// Muestra imágenes en blanco y negro en pantalla del Pinpad.
///
/// Se debe suministrar los bytes correspondientes a la imagen monocromática
/// en formato BMP [imageData], así como las coordenadas [x] y [y].
Future<void> showPinpadImage(Uint8List imageData, int x, int y) async {
  await pinpadChannel.invokeMethod("showPinpadImage", {
    "imageData": imageData,
    "x": x,
    "y": y,
  });
}


/// Método que muestra imágenes a color en pantalla del Pinpad.
///
/// Se debe suministrar los bytes correspondientes a la imagen
/// (Bitmap de 16-bit TrueColor) [imageData], así como las coordenadas [x] y [y],
/// el ancho [width] y el alto [height].
Future<void> showPinpadColorImage(Uint8List imageData, int x, int y, int width, int height) async {
  await pinpadChannel.invokeMethod("showPinpadColorImage", {
    "imageData": imageData,
    "x": x,
    "y": y,
    "width": width,
    "height": height
  });
}
/// Método que hace ping al pinpad para verificar si aún está conectado regresando un bool
Future<bool> pingPinpad() async {
  return await pinpadChannel.invokeMethod("pingPinpad");
}