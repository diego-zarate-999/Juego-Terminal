import 'package:flutter/material.dart';

class HomeViewButton extends StatelessWidget {
  final bool enabled;
  final Color borderColor;
  final Color backgroundColor;
  final IconData iconData;
  final String labelString;
  final void Function() onPressed;

  const HomeViewButton(
      {Key? key,
      this.enabled = true,
      required this.borderColor,
      required this.iconData,
      required this.backgroundColor,
      required this.labelString,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queryData = MediaQuery.of(context);

    //queryData.orientation;
    //Orientation.landscape;
    final double buttonWidth = queryData.size.width > 320 ? 300 : 250;

    double iconSize = 68;
    double fontSize = 18;
    if (queryData.size.height <= 320.0) {
      iconSize = 52;
      fontSize = 24;
    }

    return SizedBox(
      width: buttonWidth,

      child: Material(
          color: backgroundColor,
          child: InkWell(
            onTap: enabled ? this.onPressed : null,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, size: iconSize, color:  Colors.white), // <-- Icon
              Text(labelString, style: TextStyle(color: Colors.white, fontSize: fontSize), textAlign: TextAlign.center,), // <-- Text
            ],
          ),
        ),
      ),

    );
  }
}
