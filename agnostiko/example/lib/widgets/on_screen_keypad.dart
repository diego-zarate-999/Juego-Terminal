import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../widgets/accept_input_button.dart';
import '../../utils/locale.dart';

class OnScreenKeypad extends StatelessWidget {
  final void Function() onAccept;
  final void Function(int digitValue) onDigitTap;
  final void Function() onBackspaceTap;
  final void Function() onClearTap;

  const OnScreenKeypad({
    Key? key,
    required this.onAccept,
    required this.onDigitTap,
    required this.onBackspaceTap,
    required this.onClearTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AcceptInputButton(
          label: getLocalizations(context).accept,
          onPressed: onAccept,
        ),
        NumericKeyboard(
          onDigitTap: onDigitTap,
          rightButtonIcon: Icon(Icons.backspace),
          onRightButtonTap: onBackspaceTap,
          leftButtonIcon: Icon(Icons.clear),
          onLeftButtonTap: onClearTap,
        ),
      ],
    );
  }
}
