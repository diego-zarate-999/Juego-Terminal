import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import "package:flutter/material.dart";
import 'package:agnostiko/emv/src/emv_module.dart';
import 'package:agnostiko/utils/src/image.dart';

class OpenPainter extends CustomPainter {
  final ui.Image img;
  OpenPainter({required this.img});



  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Color.fromARGB(255, 255, 255, 255), BlendMode.overlay);

  /*  final assetsImage = AssetImage("assets/img/insert_card.png");
    final img = await assetsImage.toUiImage();*/

   /* Completer<ImageInfo> completer = Completer();
    assetsImage.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info);
      }),
    );

    ui.Image img = (await completer.future).image;*/


    double offsetY = 0;


    double normalFontSize = 8;
    double bigFontSize = 16;

    TextSpan span = TextSpan(
      text: "NOMBRE DEL COMERCIO\nDIRECCION DEL COMERCIO\n1234567-00000001\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        //fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: size.width, maxWidth: size.width);
    tp.paint(canvas, Offset(0, offsetY));
    offsetY = tp.height;

    double halfSize = (size.width / 2) - normalFontSize;

    TextSpan fechaLeft = TextSpan(
      text: "FECHA 16DIC05",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
      ),
    );
    TextPainter tpFechaLeft = TextPainter(
      text: fechaLeft,
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    );
    tpFechaLeft.layout(minWidth: halfSize, maxWidth: halfSize);
    tpFechaLeft.paint(canvas, Offset(0, offsetY));
    TextSpan fechaRight = TextSpan(
      text: "HORA 16:13",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
      ),
    );
    TextPainter tpFechaRight = TextPainter(
      text: fechaRight,
      textAlign: TextAlign.end,
      textDirection: TextDirection.ltr,
    );
    tpFechaRight.layout(minWidth: halfSize, maxWidth: halfSize);
    tpFechaRight.paint(canvas, Offset(size.width - halfSize, offsetY));

    offsetY += max(tpFechaLeft.height, tpFechaRight.height);

    TextSpan span2 = TextSpan(
      text: "\n************9999\n",
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: bigFontSize,
      ),
    );
    TextPainter tp2 = TextPainter(
      text: span2,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp2.layout(minWidth: size.width, maxWidth: size.width);
    tp2.paint(canvas, Offset(0, offsetY));
    offsetY += tp2.height;

    TextSpan span3 = TextSpan(
      text: "BBVA BANCOMER CREDITO\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        //fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp3 = TextPainter(
      text: span3,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp3.layout(minWidth: size.width, maxWidth: size.width);
    tp3.paint(canvas, Offset(0, offsetY));
    offsetY += tp3.height;

    TextSpan span4 = TextSpan(
      text: "VENTA\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp4 = TextPainter(
      text: span4,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp4.layout(minWidth: size.width, maxWidth: size.width);
    tp4.paint(canvas, Offset(0, offsetY));
    offsetY += tp4.height;

    TextSpan montoLeft = TextSpan(
      text: "TOTAL M.N.\nI@1\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tpMontoLeft = TextPainter(
      text: montoLeft,
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    );
    tpMontoLeft.layout(minWidth: halfSize, maxWidth: halfSize);
    tpMontoLeft.paint(canvas, Offset(0, offsetY));
    TextSpan montoRight = TextSpan(
      text: "\$1.00",
      style: TextStyle(
          color: Colors.black,
          fontSize: normalFontSize,
          fontWeight: FontWeight.bold),
    );
    TextPainter tpMontoRight = TextPainter(
      text: montoRight,
      textAlign: TextAlign.end,
      textDirection: TextDirection.ltr,
    );
    tpMontoRight.layout(minWidth: halfSize, maxWidth: halfSize);
    tpMontoRight.paint(canvas, Offset(size.width - halfSize, offsetY));

    offsetY += max(tpMontoLeft.height, tpMontoRight.height);

    final emv = EmvModule.instance;
   // final auxAid1 = await emv.getTagValue(0x9f06);

    TextSpan span5 = TextSpan(
      text: "APROBACIÓN: 123456\nARQC: E47BF856EDEB5B31\nAID:AXXXXXXXXX\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp5 = TextPainter(
      text: span5,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp5.layout(minWidth: size.width, maxWidth: size.width);
    tp5.paint(canvas, Offset(0, offsetY));
    offsetY += tp5.height;

    TextSpan span6 = TextSpan(
      text: "AUTORIZADO SIN AUTENTICACIÓN DEL TARJETAHABIENTE\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        //fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp6 = TextPainter(
      text: span6,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp6.layout(minWidth: size.width, maxWidth: size.width);
    tp6.paint(canvas, Offset(0, offsetY));
    offsetY += tp6.height;

    TextSpan span7 = TextSpan(
      text: "PAGADERE NEGOCIABLE UNICAMENTE CON INSTITUCIONES DE CRÉDITO\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        //fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp7 = TextPainter(
      text: span7,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp7.layout(minWidth: size.width, maxWidth: size.width);
    tp7.paint(canvas, Offset(0, offsetY));
    offsetY += tp7.height;


   TextSpan span8 = TextSpan(
      text: "POR ESTE PAGARE ME OBLIGO INCONDICIONALMENTE A PAGAR A LA ORDEN DE\n"
          "BANCO ACREDITANTE EL IMPORTE DE ESTE TÍTULO.\n"
          "ESTE PAGARE PROCEDE DEL CONTRATO DE APERTURA DE CREDITO QUE EL BANCO\n"
          "ACREDITANTE Y EL TARJETAHABIENTE TIENEN CELEBRADO\n",
      style: TextStyle(
        color: Colors.black,
        fontSize: normalFontSize,
        //fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp8 = TextPainter(
      text: span8,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp8.layout(minWidth: size.width, maxWidth: size.width);
    tp8.paint(canvas, Offset(0, offsetY));
    offsetY += tp8.height;

    canvas.drawImage(img, Offset(100, offsetY-40), Paint());

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
