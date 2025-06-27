import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';

/// Abre un dialog para la edición de un bitmap de configuración EMV.
Future<EmvConfigBitmap?> showParamBitmapDialog(
  BuildContext context, {
  required EmvConfigBitmap bitmap,
  bool? readOnly,
}) {
  return showDialog<EmvConfigBitmap?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final _bitmap = bitmap;
      final bool _readOnly = readOnly ?? false;

      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          actionsOverflowButtonSpacing: 1,
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          contentPadding: EdgeInsets.only(left: 25, right: 25),
          title: Center(child: Text(_bitmap.name)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: Container(
            width: 200.0,
            height: 400.0,
            child: _createBitmapWidget(context, _bitmap, setState, _readOnly),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              child: Text(getLocalizations(context).accept),
              onPressed: () {
                Navigator.pop(context, _bitmap);
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              child: Text(getLocalizations(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    },
  );
}

ListView _createBitmapWidget(
  BuildContext context,
  EmvConfigBitmap _bitmap,
  void Function(void Function()) setState,
  bool readOnly,
) {
  List<Widget> tiles = List<Widget>.empty(growable: true);

  // Una lista de 'tiles' con los bits para cada byte
  for (int i = 1; i <= _bitmap.bytes.length; i++) {
    tiles.addAll(_createByteWidget(context, i, _bitmap, setState, readOnly));
  }

  return ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: [...tiles],
    ).toList(),
  );
}

List<Widget> _createByteWidget(
  BuildContext context,
  int byteNum,
  EmvConfigBitmap _bitmap,
  void Function(void Function()) setState,
  bool readOnly,
) {
  final byte = _bitmap.byte(byteNum);
  return [
    ListTile(
      title: Text(
        byte?.name ?? '',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Byte " + byteNum.toString()),
    ),
    CheckboxListTile(
      title: Text(byte?.bit8.name ?? ''),
      subtitle: Text("bit8"),
      value: byte?.bit8.value,
      onChanged: byte?.bit8.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit8.value = value ?? false;
              });
            },
    ),
    CheckboxListTile(
      title: Text(byte?.bit7.name ?? ''),
      subtitle: Text("bit7"),
      value: byte?.bit7.value,
      onChanged: byte?.bit7.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit7.value = value ?? false;
              });
            },
    ),
    CheckboxListTile(
      title: Text(byte?.bit6.name ?? ''),
      subtitle: Text("bit6"),
      value: byte?.bit6.value,
      onChanged: byte?.bit6.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit6.value = value ?? false;
              });
            },
    ),
    CheckboxListTile(
      title: Text(byte?.bit5.name ?? ''),
      subtitle: Text("bit5"),
      value: byte?.bit5.value,
      onChanged: byte?.bit5.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit5.value = value ?? false;
              });
            },
    ),
    CheckboxListTile(
      title: Text(byte?.bit4.name ?? ''),
      subtitle: Text("bit4"),
      value: byte?.bit4.value,
      onChanged: byte?.bit4.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit4.value = value ?? false;
              });
            },
    ),
    CheckboxListTile(
      title: Text(byte?.bit3.name ?? ''),
      subtitle: Text("bit3"),
      value: byte?.bit3.value,
      onChanged: byte?.bit3.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit3.value = value ?? false;
              });
            },
    ),
    CheckboxListTile(
      title: Text(byte?.bit2.name ?? ''),
      subtitle: Text("bit2"),
      value: byte?.bit2.value,
      onChanged: byte?.bit2.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit2.value = value ?? false;
              });
            },
    ),
    CheckboxListTile(
      title: Text(byte?.bit1.name ?? ''),
      subtitle: Text("bit1"),
      value: byte?.bit1.value,
      onChanged: byte?.bit1.rfu == true || readOnly
          ? null
          : (value) {
              setState(() {
                _bitmap.byte(byteNum)?.bit1.value = value ?? false;
              });
            },
    ),
  ];
}
