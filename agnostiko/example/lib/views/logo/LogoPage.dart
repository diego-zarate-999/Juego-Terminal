import 'package:flutter/material.dart';
import 'OpenPainter.dart';
import 'dart:ui' as ui;

class LogoPage extends StatefulWidget {
  static String route = "/logoPage";

  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<LogoPage> {
  @override
  Widget build(BuildContext context) {
    final img = ModalRoute.of(context)?.settings.arguments as ui.Image;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("LOGO"),
      ),
      body: Container(
          child: Center(
        child: Container(
          width: 192,
          height: 480,
          child: CustomPaint(
            painter: OpenPainter(img: img),
          ),
        ),
      )),
    );
  }
}
