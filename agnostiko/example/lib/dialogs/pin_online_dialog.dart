import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';
import '../utils/keypad.dart';

Future<bool?> showPinOnlineDialog(BuildContext context, String message,
    {String? messageChanged}) {
  ValueNotifier<String> _dialogText = ValueNotifier<String>(message);
  ValueNotifier<bool> _showYesButton = ValueNotifier<bool>(true);
  ValueNotifier<bool> _showNoButton = ValueNotifier<bool>(true);
  ValueNotifier<String> _buttonText = ValueNotifier<String>("");
  bool? _result;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: rawKeypadHandler(
          context,
          onEscape: () {
            Navigator.pop(context, false);
          },
          onEnter: (() {
            Navigator.pop(context, true);
          }),
        ),
        child: WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            actionsOverflowButtonSpacing: 1,
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Center(child: Text(getLocalizations(context).info)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            content: ValueListenableBuilder(
              valueListenable: _dialogText,
              builder: (context, String value, _) {
                return Text(value);
              },
            ),
            actions: <Widget>[
              ValueListenableBuilder(
                valueListenable: _showYesButton,
                builder: (context, value, child) {
                  return Visibility(
                    visible: value,
                    child: ElevatedButton(
                      onPressed: () {
                        _dialogText.value = messageChanged != null
                            ? "$messageChanged : ${getLocalizations(context).approved}"
                            : "PIN Online: ${getLocalizations(context).approved}";
                        _buttonText.value = getLocalizations(context).close;
                        _showYesButton.value = false;
                        _showNoButton.value = false;
                        _result = true;
                      },
                      child: Text(getLocalizations(context).yes),
                    ),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _showNoButton,
                builder: (context, value, child) {
                  return Visibility(
                    visible: value,
                    child: ElevatedButton(
                      onPressed: () {
                        _dialogText.value = messageChanged != null
                            ? "$messageChanged : ${getLocalizations(context).failed}"
                            : "PIN Online: ${getLocalizations(context).failed}";
                        _buttonText.value = getLocalizations(context).close;
                        _showYesButton.value = false;
                        _showNoButton.value = false;
                        _result = false;
                      },
                      child: Text(getLocalizations(context).no),
                    ),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _buttonText,
                builder: (context, String text, _) {
                  return text.isNotEmpty
                      ? ElevatedButton(
                          child: Text(text),
                          onPressed: () {
                            Navigator.pop(context, _result);
                          },
                        )
                      : Container();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
