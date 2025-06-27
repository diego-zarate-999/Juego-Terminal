import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agnostiko/agnostiko.dart';

import '../../dialogs/circular_progress_dialog.dart';
import '../../dialogs/card_indicator_dialog.dart';
import '../../dialogs/log_dialog_with_timer.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

enum MifareCommand { GetVersion, SelectApp, Authorization }

class SettingsMifareView extends StatefulWidget {
  static String route = "/settings/mifare";

  @override
  _SettingsMifareViewState createState() => _SettingsMifareViewState();
}

class _SettingsMifareViewState extends State<SettingsMifareView> {
  bool _isMe60 = false;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      final deviceName = await getModel();
      setState(() {
        if (deviceName == "ME60") {
          _isMe60 = true;
        }
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) {
          if (digit == 1) {
            _testSendCommandRF(MifareCommand.GetVersion);
          } else if (digit == 2) {
            _testSendCommandRF(MifareCommand.SelectApp);
          }
        },
        onEscape: () {
          Navigator.pop(context, (route) => true);
        },
        onBackspace: () {
          Navigator.pop(context, (route) => true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).mifare),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60
                    ? "1. ${getLocalizations(context).getVersionCmd}"
                    : getLocalizations(context).getVersionCmd),
                onTap: () {
                  _testSendCommandRF(MifareCommand.GetVersion);
                },
              ),
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60
                    ? "2. ${getLocalizations(context).selectAppCmd}"
                    : getLocalizations(context).selectAppCmd),
                onTap: () {
                  _testSendCommandRF(MifareCommand.SelectApp);
                },
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }

  _showSnackBarAndPop(String snackBarMsg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(snackBarMsg),
    ));
    Navigator.pop(context);
  }

  // Muestra la respuesta obtenida ante el envío de un comando a las tarjetas
  // MIFARE.
  //
  // La respuesta de un comando nativo envuelto en ISO/IEC 7816-4 consta de la
  // siguiente estructura:
  // - RespData: valor opcional si el comando regresa data en su respuesta.
  // - SW1: corresponde al status word 1 seteado en 0x91.
  // - SW2: corresponde al status word 2 equivalente al código de respuesta
  // nativo.
  _showCommandResultLog(String title, List<String> cmdResult) {
    showLogDialogWithTimer(context, children: [
      for (var i = 0; i < cmdResult.length; i++) ...[
        Text(""),
        Text("${getLocalizations(context).resultPart} ${i + 1}:"),
        SelectableText("'${cmdResult[i].toUpperCase()}'"),
      ]
    ], onClose: () {
      Navigator.pop(context);
    }, title: title);
  }

  // Método que ejecuta el envío de comando GetVersion a tarjetas MIFARE en su
  // formato nativo envuelto en ISO/IEC 7816-4. Este comando consta de tres
  // partes.
  _getVersionCommand() async {
    List<int> cmd = List.empty(growable: true);
    // Equivalente nativo: [0x60];
    cmd = [0x90, 0x60, 0x00, 0x00, 0x00];
    final cmdResultPart1 = await sendCommandRF(Uint8List.fromList(cmd));

    // Equivalente nativo: [0xAF];
    cmd = [0x90, 0xAF, 0x00, 0x00, 0x00];
    final cmdResultPart2 = await sendCommandRF(Uint8List.fromList(cmd));

    // Equivalente nativo: [0xAF];
    cmd = [0x90, 0xAF, 0x00, 0x00, 0x00];
    final cmdResultPart3 = await sendCommandRF(Uint8List.fromList(cmd));

    final title = getLocalizations(context).getVersionCmd;
    final cmdResult = [
      cmdResultPart1.toHexStr(),
      cmdResultPart2.toHexStr(),
      cmdResultPart3.toHexStr()
    ];

    await waitUntilRFCardRemoved();
    Navigator.pop(context);
    Navigator.pop(context);
    _showCommandResultLog(title, cmdResult);
  }

  // Método que ejecuta el envío de comando Select Application a tarjetas MIFARE
  // en su formato nativo envuelto en ISO/IEC 7816-4. Si la aplicación
  // seleccionada es la 0x00 00 00, se está trabajando en el nivel PICC con la
  // app maestra.
  _selectAppCommand() async {
    List<int> cmd = List.empty(growable: true);
    // Equivalente nativo: [0x5A, 0x00, 0x00, 0x00];
    cmd = [0x90, 0x5A, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00];
    final cmdResultPart1 = await sendCommandRF(Uint8List.fromList(cmd));

    final title = getLocalizations(context).selectAppPiccCmd;
    final cmdResult = [cmdResultPart1.toHexStr()];

    await waitUntilRFCardRemoved();
    Navigator.pop(context);
    Navigator.pop(context);
    _showCommandResultLog(title, cmdResult);
  }

  // Función que permite llamar al método del respectivo comando que se desea
  // enviar a la tarjeta MIFARE.
  //
  // Se esta utilizando el formato nativo envuelto en ISO/IEC 7816-4, con la
  // siguiente estructura para cada byte o grupo de bytes:
  //- CLA: byte de clase seteado en 0X00.
  //- INS: byte de instrucción, igual al comando nativo.
  //- P1: primer parámetro seteado en 0x00.
  //- P2: segundo parámetro seteado en 0x00.
  //- Lc: tamaño de la data a envolver incluyendo encabezado y data.
  //- CmdData: es un parámetro opcional dependiendo de si el comando requiere el
  // envío de data a parte de la instrucción.
  //- Le: comando opcional asociado al tamaño de la data de respuesta esperada
  // (si Le=0x00, toda la data disponible es regresada).
  _excuteCommand(MifareCommand mifareCommand) async {
    switch (mifareCommand) {
      case MifareCommand.GetVersion:
        await _getVersionCommand();
        break;
      case MifareCommand.SelectApp:
        await _selectAppCommand();
        break;
      case MifareCommand.Authorization:
        // TODO: Handle this case.
        break;
    }
  }

  _testSendCommandRF(MifareCommand mifareCommand) async {
    final cardTypes = [CardType.RF];
    showCircularProgressDialog(
      context,
      getLocalizations(context).waitingForCard,
      onWillPop: () async {
        await closeCardReader();
        return true;
      },
    );

    final cardReaderStream = openCardReader(
      cardTypes: cardTypes,
      timeout: 10,
    );

    try {
      await for (final event in cardReaderStream) {
        if (!mounted) return;
        if (event.cardType == CardType.RF) {
          showCardIndicatorDialog(context, false);
          await _excuteCommand(mifareCommand);
        }
      }
    } on TimeoutException {
      if (!mounted) return;
      _showSnackBarAndPop(getLocalizations(context).cardDetectionTimeout);
      await closeCardReader();
    } catch (e) {
      if (!mounted) return;
      print("Error: $e");
      _showSnackBarAndPop(getLocalizations(context).cardDetectionError);
      await closeCardReader();
    }
    print("****************CARD READER CLOSED*****************");
  }
}
