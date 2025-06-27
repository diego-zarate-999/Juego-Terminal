import 'package:flutter/material.dart';

class AcceptInputButton extends ElevatedButton {
  AcceptInputButton({required Function() onPressed, required String label})
      : super(
          onPressed: onPressed,
          child: Text(label, style: TextStyle(fontFamily: "Roboto")),
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
}
