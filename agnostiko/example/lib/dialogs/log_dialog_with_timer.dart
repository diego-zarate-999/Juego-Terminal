import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/locale.dart';

Future<void> showLogDialogWithTimer(
  BuildContext context, {
  required List<Widget> children,
  required void Function() onClose,
  String title = "Log",
}) {
  bool _isButtonDisabled = true;
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          Timer(const Duration(seconds: 2), () {
            if (!context.mounted) return;
            setState(() {
              _isButtonDisabled = false;
            });
          });
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              actionsOverflowButtonSpacing: 1,
              actionsPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              contentPadding: EdgeInsets.only(left: 25, right: 25),
              title: Center(child: Text(title)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              content: Container(
                height: 300,
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
              actions: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                    child: new Text(getLocalizations(context).close),
                    onPressed: _isButtonDisabled
                        ? null
                        : () {
                            onClose();
                          },
                  ),
                ),
              ],
            ),
          );
        });
      });
}
