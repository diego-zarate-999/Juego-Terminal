import 'dart:ui';
import 'dart:async';
import 'dart:typed_data';


import 'package:flutter/painting.dart';
import 'package:agnostiko/printer/src/printer_object.dart';

extension DotMatrix on Image {
  Future<Uint8List> toDotMatrix() async {
    return _rgbaToDotMatrix(await this.toRGBA());
  }
}

extension RGBA on Image {
  Future<Uint8List> toRGBA() async {
    final byteData = await this.toByteData(format: ImageByteFormat.rawRgba);
    return byteData?.buffer.asUint8List() ?? Uint8List.fromList([]);
  }
}

extension AssetDotMatrix on AssetImage {
  Future<Uint8List> toDotMatrix() async {
    return _rgbaToDotMatrix(await this.toRGBA());
  }
}

extension AssetImageToImage on AssetImage {
  Future<Image> toUiImage() async {
    Completer<ImageInfo> completer = Completer();
    this.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info);
      }),
    );

    return (await completer.future).image;
  }
}

extension AssetRGBA on AssetImage {
  Future<Uint8List> toRGBA() async {
    Image img = await this.toUiImage();
    return img.toRGBA();
  }
}

extension AssetImageToPrinterImage on AssetImage {
  Future<PrinterImage> toPrinterImage({double offsetX= 0, double offsetY= 0}) async{
    Image img = await this.toUiImage();
    Uint8List imgRgba = await img.toRGBA();
    final printerImage = PrinterImage(imgRgba, img.width, img.height, offsetX: offsetX, offsetY: offsetY);
    return printerImage;
  }
}

Future<Uint8List> _rgbaToDotMatrix(Uint8List rgba) async {
  print("Number of img bytes: ${rgba.length}");

  final numPixels = rgba.length ~/ 4;
  print("Num of pixels: $numPixels");
  final matrixLen = numPixels ~/ 8;
  print("Matrix len: $matrixLen");
  final dotMatrix = Uint8List(matrixLen);

  int pixelIndex = 0;
  for (int i = 0; i < dotMatrix.length; i++) {
    for (int j = 0; j < 8; j++) {
      final red = rgba[pixelIndex];
      final green = rgba[pixelIndex + 1];
      final blue = rgba[pixelIndex + 2];
      final alpha = rgba[pixelIndex + 3];

      final luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue);
      if (luminance < 200 && alpha > 30) {
        switch (j) {
          case 0:
            dotMatrix[i] |= 0x80;
            break;
          case 1:
            dotMatrix[i] |= 0x40;
            break;
          case 2:
            dotMatrix[i] |= 0x20;
            break;
          case 3:
            dotMatrix[i] |= 0x10;
            break;
          case 4:
            dotMatrix[i] |= 0x08;
            break;
          case 5:
            dotMatrix[i] |= 0x04;
            break;
          case 6:
            dotMatrix[i] |= 0x02;
            break;
          case 7:
            dotMatrix[i] |= 0x01;
            break;
        }
      }

      pixelIndex += 4;
    }
  }

  return dotMatrix;
}

Future<Image> bytesToUiImage(Uint8List imgBytes, int width, int height) async {
  final buffer = await ImmutableBuffer.fromUint8List(imgBytes);
  final format = PixelFormat.rgba8888;
  final desc = ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: format,
  );
  final codec = await desc.instantiateCodec();
  final frame = await codec.getNextFrame();
  return frame.image;
}

Uint8List convertRGBAtoRGB16 (Uint8List rgbaBytes, int width, int height) {
  // Crea un buffer de bytes para almacenar los bytes del rgb bitmap
  Uint8List rgbBytes = Uint8List (width * height * 2);
  // Recorre los bytes de la imagen rgba de cuatro en cuatro
  for (int i = 0; i < rgbaBytes.length; i += 4) {
    // Obtiene los valores de los canales rojo, verde y azul
    int R = rgbaBytes [i];
    int G = rgbaBytes [i + 1];
    int B = rgbaBytes [i + 2];
    // Convierte los valores de 8 bits a 5 bits para el rojo y el azul, y a 6 bits para el verde
    R = R >> 3;
    G = G >> 2;
    B = B >> 3;
    // Combina los valores en un entero de 16 bits usando el formato RGB565
    int pixel = (R << 11) | (G << 5) | B;
    // Divide el entero en dos bytes y los almacena en el buffer del rgb bitmap
    rgbBytes [i ~/ 2] = pixel & 0xFF;
    rgbBytes [i ~/ 2 + 1] = pixel >> 8;
  }
  // Retorna el Uint8List del rgb bitmap
  return rgbBytes;
}
