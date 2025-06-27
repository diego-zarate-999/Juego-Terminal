import 'package:flutter/material.dart';

typedef DigitTapCallback = void Function(int digit);

class NumericKeyboard extends StatefulWidget {
  final Color textColor;
  final Icon? rightButtonIcon;
  final Function()? onRightButtonTap;
  final Icon? leftButtonIcon;
  final Function()? onLeftButtonTap;
  final DigitTapCallback onDigitTap;
  final MainAxisAlignment mainAxisAlignment;
  final bool shuffleDigits;

  NumericKeyboard({
    Key? key,
    required this.onDigitTap,
    this.textColor = Colors.black,
    this.leftButtonIcon,
    this.onLeftButtonTap,
    this.rightButtonIcon,
    this.onRightButtonTap,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.shuffleDigits = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NumericKeyboardState(digitsList: _createDigitsList());
  }

  List<int> _createDigitsList() {
    List<int> digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    if (this.shuffleDigits) digits.shuffle();
    return digits;
  }
}

class _NumericKeyboardState extends State<NumericKeyboard> {
  final List<int> digitsList;

  _NumericKeyboardState({required this.digitsList});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: [
              _calcButton(digitsList[1]),
              _calcButton(digitsList[2]),
              _calcButton(digitsList[3]),
            ],
          ),
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: [
              _calcButton(digitsList[4]),
              _calcButton(digitsList[5]),
              _calcButton(digitsList[6]),
            ],
          ),
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: [
              _calcButton(digitsList[7]),
              _calcButton(digitsList[8]),
              _calcButton(digitsList[9]),
            ],
          ),
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(45),
                onTap: widget.onLeftButtonTap,
                child: Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: widget.leftButtonIcon,
                ),
              ),
              _calcButton(digitsList[0]),
              InkWell(
                borderRadius: BorderRadius.circular(45),
                onTap: widget.onRightButtonTap,
                child: Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: widget.rightButtonIcon,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcButton(int digit) {
    return InkWell(
        borderRadius: BorderRadius.circular(45),
        onTap: () {
          widget.onDigitTap(digit);
        },
        child: Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          child: Text(
            digit.toString(),
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: widget.textColor),
          ),
        ));
  }
}
