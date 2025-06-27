import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';
import '../utils/keypad.dart';

Future<List<CardType>?> showCardReaderDialog(BuildContext context) {
  return showDialog<List<CardType>?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      List<CardType> _cardTypes = [CardType.IC, CardType.Magnetic, CardType.RF];

      return StatefulBuilder(builder: (context, setState) {
        void _updateCardTypes(bool enabled, CardType type) {
          setState(() {
            if (enabled == true) {
              if (!_cardTypes.contains(type)) {
                _cardTypes = _cardTypes + [type];
              }
            } else {
              _cardTypes = _cardTypes.where((it) => it != type).toList();
            }
          });
        }

        return RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: rawKeypadHandler(context, onDigit: (digit) {
            if (digit == 1) {
              bool value = _cardTypes.contains(CardType.Magnetic);
              _updateCardTypes(
                !value,
                CardType.Magnetic,
              );
            } else if (digit == 2) {
              bool value = _cardTypes.contains(CardType.IC);
              _updateCardTypes(
                !value,
                CardType.IC,
              );
            } else if (digit == 3) {
              bool value = _cardTypes.contains(CardType.RF);
              _updateCardTypes(
                !value,
                CardType.RF,
              );
            }
          }, onEscape: () {
            Navigator.pop(context);
          }, onBackspace: () {
            Navigator.pop(context);
          }, onEnter: () {
            Navigator.pop(context, _cardTypes);
          }),
          child: AlertDialog(
            actionsOverflowButtonSpacing: 1,
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Center(child: Text(getLocalizations(context).cardReader)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            content: Container(
              width: 200.0,
              height: 400.0,
              child: ListView(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: [
                    CheckboxListTile(
                      title: Text('1. Magnetic'),
                      value: _cardTypes.contains(CardType.Magnetic),
                      onChanged: (enabled) => _updateCardTypes(
                        enabled ?? false,
                        CardType.Magnetic,
                      ),
                    ),
                    CheckboxListTile(
                      title: Text('2. IC'),
                      value: _cardTypes.contains(CardType.IC),
                      onChanged: (enabled) => _updateCardTypes(
                        enabled ?? false,
                        CardType.IC,
                      ),
                    ),
                    CheckboxListTile(
                      title: Text('3. RF'),
                      value: _cardTypes.contains(CardType.RF),
                      onChanged: (enabled) => _updateCardTypes(
                        enabled ?? false,
                        CardType.RF,
                      ),
                    ),
                  ],
                ).toList(),
              ),
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
                  Navigator.pop(context, _cardTypes);
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
          ),
        );
      });
    },
  );
}
