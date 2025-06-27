import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';

showICCommandDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      IcSlot selectedIC = IcSlot.IC1;
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          actionsOverflowButtonSpacing: 1,
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          contentPadding: EdgeInsets.only(left: 25, right: 25),
          title: Center(child: Text(getLocalizations(context).icSlotSelect)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: Container(
            width: 200.0,
            height: 400.0,
            child: Column(
              children: [
                RadioListTile(
                  title: Text(getLocalizations(context).icFinancial),
                  value: IcSlot.IC1,
                  groupValue: selectedIC,
                  onChanged: (value) {
                    setState(() {
                      selectedIC = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('SAM 1'),
                  value: IcSlot.SAM1,
                  groupValue: selectedIC,
                  onChanged: (value) {
                    setState(() {
                      selectedIC = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('SAM 2'),
                  value: IcSlot.SAM2,
                  groupValue: selectedIC,
                  onChanged: (value) {
                    setState(() {
                      selectedIC = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('SAM 3'),
                  value: IcSlot.SAM3,
                  groupValue: selectedIC,
                  onChanged: (value) {
                    setState(() {
                      selectedIC = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('SAM 4'),
                  value: IcSlot.SAM4,
                  groupValue: selectedIC,
                  onChanged: (value) {
                    setState(() {
                      selectedIC = value!;
                    });
                  },
                ),
              ],
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
                _getICResponse(selectedIC, context);
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

_getICResponse(IcSlot selectedIC, context) async {
  final cardTypes = <CardType>[
    CardType.IC,
    CardType.SAM,
  ];
  final cardStream = openCardReader(
    cardTypes: cardTypes,
    timeout: 0,
  );
  List<int> cmd = List.empty(growable: true);
  cmd = [
    0x00, // CLA (Class)
    0x84, // INS (Instruction)
    0x00, // P1 (Parameter 1)
    0x00, // P2 (Parameter 2)
    0x04 // Le (Expected Response Length)
  ];
  try {
    await for (final event in cardStream) {
      if (event.cardType == CardType.SAM || event.cardType == CardType.IC) {
        await initIC(selectedIC);
        var resp = await sendCommandIC(Uint8List.fromList(cmd), selectedIC);
        var resp2 = await sendCommandIC(Uint8List.fromList(cmd), selectedIC);
        var fullResp = "cmd 1: ${resp.toHexStr()}\ncmd 2: ${resp2.toHexStr()}";
        _showResult(fullResp, context);
      }
    }
  } catch (error) {
    closeCardReader();
    _showResult(error.toString(), context);
  }
  closeCardReader();
}

_showResult(String resp, context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        actionsOverflowButtonSpacing: 1,
        actionsPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        contentPadding: EdgeInsets.only(left: 25, right: 25),
        title: Center(child: Text(getLocalizations(context).testIcCommandResp)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        content: Container(width: 200.0, height: 200.0, child: Text(resp)),
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
