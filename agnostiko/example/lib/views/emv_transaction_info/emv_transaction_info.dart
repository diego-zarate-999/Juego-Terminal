import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../config/app_config.dart';
import '../../dialogs/param_bitmap_dialog.dart';
import '../../models/transaction_args.dart';
import '../../utils/emv.dart';
import '../../utils/locale.dart';
import '../../utils/keypad.dart';
import '../../utils/parameters.dart';

class EmvTransactionInfoView extends StatefulWidget {
  static String route = "/emvTransactionInfo";

  @override
  _EmvTransactionInfoViewState createState() => _EmvTransactionInfoViewState();
}

class _EmvTransactionInfoViewState extends State<EmvTransactionInfoView> {
  bool flagPrint = true;
  TransactionArgs? transactionArgs;
  InfoTags? infoTags;
  Map<int, Uint8List?>? firstGenerateTags;
  Map<int, Uint8List?>? secondGenerateTags;

  EmvTransactionResult? transactionResult;

  @override
  Widget build(BuildContext context) {
    String approvedStr = getLocalizations(context).approved.toUpperCase();
    String declinedStr = getLocalizations(context).declined.toUpperCase();
    String failedStr = getLocalizations(context).failed.toUpperCase();
    String offlineStr = getLocalizations(context).offline.toUpperCase();
    String onlineStr = getLocalizations(context).online.toUpperCase();

    String transactionResultStr = failedStr;
    String transactionOnlineStr = offlineStr;

    if (transactionArgs == null) {
      transactionArgs =
          ModalRoute.of(context)?.settings.arguments as TransactionArgs;

      // se supone que al llegar a esta pantalla es porque la transacción finalizó
      // por lo tanto podemos extraer toda la data que haga falta del listener
      firstGenerateTags = transactionArgs?.firstGenerateTags;
      secondGenerateTags = transactionArgs?.secondGenerateTags;
      infoTags = transactionArgs?.infoTags;

      final transactionInfo = transactionArgs?.transactionInfo;
      final transactionResult = transactionInfo?.result;
      this.transactionResult = transactionResult;
      switch (transactionResult) {
        case EmvTransactionResult.Approved:
          transactionResultStr = approvedStr;
          break;
        case EmvTransactionResult.Denied:
          transactionResultStr = declinedStr;
          break;
        default:
          break;
      }

      transactionOnlineStr =
          transactionInfo?.onlineRequested == true ? onlineStr : offlineStr;

      if (flagPrint) {
        printTicket();
        flagPrint = false;
      }
    }

    final firstGenerateTiles = _generateCommandTiles(
      '1st GENERATE AC',
      firstGenerateTags,
    );
    final secondGenerateTiles = _generateCommandTiles(
      '2nd GENERATE AC',
      secondGenerateTags,
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, (route) => route.isFirst == true);
        return true;
      },
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: rawKeypadHandler(context, onEscape: () {
          Navigator.popUntil(context, (route) => route.isFirst == true);
        }),
        child: Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text(getLocalizations(context).emvTransactionInfo),
          ),
          body: ListView(
            children: [
              Text(''),
              Text(
                "${getLocalizations(context).transaction} " +
                    "$transactionResultStr - $transactionOnlineStr",
                style: TextStyle(
                  color: this.transactionResult == EmvTransactionResult.Approved
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              Text(''),
              Divider(),
              ListTile(
                enableFeedback: true,
                title:
                    Text('${getLocalizations(context).transactionType} (9C)'),
                subtitle: Text(
                  infoTags?.transactionType?.toHexStr().toUpperCase() ?? '-',
                ),
                onTap: () {},
              ),
              ListTile(
                enableFeedback: true,
                title: Text('${getLocalizations(context).amount} (9F02)'),
                subtitle: Text(_amountString),
                onTap: () {},
              ),
              ListTile(
                enableFeedback: true,
                title:
                    Text('${getLocalizations(context).cashbackAmount} (9F03)'),
                subtitle: Text(_amountOtherString),
                onTap: () {},
              ),
              if (_kernelTypeStr != null)
                ListTile(
                  enableFeedback: true,
                  title: Text('Kernel Type'),
                  subtitle: Text(_kernelTypeStr ?? ''),
                  onTap: () {},
                ),
              ListTile(
                enableFeedback: true,
                title: Text('PAN'),
                subtitle: Text(infoTags?.cardNo?.toUpperCase() ?? '-'),
                onTap: () {},
              ),
              ListTile(
                enableFeedback: true,
                title: Text('AID (9F06)'),
                subtitle: Text(infoTags?.aid?.toHexStr().toUpperCase() ?? '-'),
                onTap: () {},
              ),
              ListTile(
                enableFeedback: true,
                title: Text('AIP (82)'),
                subtitle: Text(infoTags?.aip?.toHexStr().toUpperCase() ?? '-'),
                onTap: _onTapAip,
              ),
              Divider(),
              ...firstGenerateTiles,
              ...secondGenerateTiles,
              ListTile(
                enableFeedback: true,
                title: Text(getLocalizations(context).appliedCVM),
                subtitle: Text(_getCvmTypeStr(infoTags?.cvmResults)),
                onTap: () {},
              ),
              ListTile(
                enableFeedback: true,
                title: Text('Terminal Capabilities (9F33)'),
                subtitle: Text(
                  infoTags?.terminalCapabilities?.toHexStr().toUpperCase() ??
                      '-',
                ),
                onTap: _onTapTerminalCapabilities,
              ),
              ListTile(
                enableFeedback: true,
                title: Text('CVM List (8E)'),
                subtitle: Text(
                  infoTags?.cvmList?.toHexStr().toUpperCase() ?? '-',
                ),
                onTap: () {},
              ),
              ListTile(
                enableFeedback: true,
                title: Text('ATC (9F36)'),
                subtitle: Text(infoTags?.atc?.toHexStr().toUpperCase() ?? '-'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? getMonth(String monthNum) {
    switch (monthNum) {
      case "01":
        return "ENE";
      case "02":
        return "FEB";
      case "03":
        return "MAR";
      case "04":
        return "ABR";
      case "05":
        return "MAY";
      case "06":
        return "JUN";
      case "07":
        return "JUL";
      case "08":
        return "AGO";
      case "09":
        return "SEP";
      case "10":
        return "OCT";
      case "11":
        return "NOV";
      case "12":
        return "DIC";
    }
    return null;
  }

  void printTicket() async {
    final emv = EmvModule.instance;

    List<PrinterObject> listOfTextLine = [];
    final terminalParameters = await loadTerminalParameters();

    final assetsLogo = AssetImage("assets/img/logo_necs.png");

    ui.Image logo = await assetsLogo.toUiImage();

    final byteDataLogo =
        await logo.toByteData(format: ui.ImageByteFormat.rawRgba);
    final rgbaLogo =
        byteDataLogo?.buffer.asUint8List() ?? Uint8List.fromList([]);

    final maxWidth = await getPaperWidth();

    //final img = await bytesToUiImage(rgbaLogo, logo.width, logo.height);
    final imgLogo =
        PrinterImage(rgbaLogo, logo.width, logo.height, offsetX: maxWidth / 4);

    //final logo = await assetsLogo.toPrinterImage(offsetX: maxWidth / 4);

    final specialFont = "DancingScript";
    final regularFont = "Roboto";

    listOfTextLine.add(imgLogo);

    listOfTextLine.add(PrinterText("Solo pagos\nCDMX".toUpperCase(),
        format: TextFormat(fontSize: 16, fontFamily: specialFont),
        alignment: TextAlignment.Center));

    final afiliacion = terminalParameters.acquirerId;
    final terminalId = terminalParameters.terminalId;

    final line3Part1 = afiliacion.toHexStr();
    final line3 = line3Part1 + "-" + terminalId;
    listOfTextLine.add(PrinterText(line3.toUpperCase(),
        format: TextFormat(fontSize: 16, fontFamily: specialFont),
        alignment: TextAlignment.Center));
    listOfTextLine.add(PrinterText.emptyLine(16));

    final fechaTag = await emv.getTagValue(0x9a);
    final horaTag = await emv.getTagValue(0x9f21);
    String fecha = "";
    String hora = "";
    if (fechaTag != null) {
      final dd = fechaTag[2].toRadixString(16).padLeft(2, "0");
      final mmNum = fechaTag[1].toRadixString(16).padLeft(2, "0");
      final mm = getMonth(mmNum);
      final yy = fechaTag[0].toRadixString(16).padLeft(2, "0");
      fecha = "Fecha $dd$mm$yy";
    }
    if (horaTag != null) {
      final hh = horaTag[0].toRadixString(16).padLeft(2, "0");
      final mm = horaTag[1].toRadixString(16).padLeft(2, "0");
      hora = "Hora $hh:$mm";
    }
    listOfTextLine.add(PrinterSplitText(
      fecha.toUpperCase(),
      hora.toUpperCase(),
      format: TextFormat(fontSize: 16, fontFamily: regularFont),
    ));

    listOfTextLine.add(PrinterText.emptyLine(32));

    final cardTag = transactionArgs?.pan;
    if (cardTag != null) {
      final cardlength = cardTag.length;
      String cardResult =
          cardTag.replaceRange(0, cardlength - 4, '*' * (cardlength - 4));
      listOfTextLine.add(PrinterText(cardResult.toUpperCase(),
          format: TextFormat(fontSize: 32, bold: true, fontFamily: regularFont),
          alignment: TextAlignment.Center));
    }
    listOfTextLine.add(PrinterText.emptyLine(32));
    listOfTextLine.add(
      PrinterText("BBVA Bancomer Credito".toUpperCase(),
          format: TextFormat(fontSize: 16, fontFamily: regularFont),
          alignment: TextAlignment.Center),
    );

    listOfTextLine.add(PrinterText.emptyLine(16));

    listOfTextLine.add(
      PrinterText("Venta".toUpperCase(),
          format: TextFormat(fontSize: 16, fontFamily: regularFont),
          alignment: TextAlignment.Center),
    );
    listOfTextLine.add(PrinterSplitText(
        "Total M.N.".toUpperCase(), _amountString,
        format: TextFormat(fontSize: 16, fontFamily: regularFont)));

    final contactlessBool = transactionArgs?.transactionInfo?.isContactless;
    switch (contactlessBool) {
      case false:
        listOfTextLine.add(
          PrinterText("I@1".toUpperCase(),
              format: TextFormat(fontSize: 16, fontFamily: regularFont)),
        );
        break;
      case true:
        listOfTextLine.add(
          PrinterText("C@1".toUpperCase(),
              format: TextFormat(fontSize: 16, fontFamily: regularFont)),
        );
        break;
    }

    listOfTextLine.add(PrinterText.emptyLine(16));
    listOfTextLine.add(PrinterText("Aprobación: 123456".toUpperCase(),
        format: TextFormat(fontSize: 16, fontFamily: regularFont)));
    listOfTextLine.add(PrinterText("ARQC: E47BF856EDEB5B31".toUpperCase(),
        format: TextFormat(fontSize: 16, fontFamily: regularFont)));

    String? aid;
    final auxAid1 = await emv.getTagValue(0x9f06);
    final auxAid2 = await emv.getTagValue(0x84);
    if (auxAid1 != null) {
      aid = auxAid1.toHexStr();
    } else if (auxAid2 != null) {
      aid = auxAid2.toHexStr();
    }
    if (aid != null) {
      listOfTextLine.add(PrinterText("AID:".toUpperCase() + aid.toUpperCase(),
          format: TextFormat(fontSize: 16, fontFamily: regularFont)));
    }

    listOfTextLine.add(PrinterText.emptyLine(16));

    final nombreTarjetahabiente = await emv.getTagValue(0x5f20);

    switch (contactlessBool) {
      case false:
        if (_getCvmTypeStr(infoTags?.cvmResults) == "FIRMA") {
          listOfTextLine.add(PrinterText(
              "FIRMA___________________".toUpperCase(),
              format: TextFormat(fontSize: 16, fontFamily: regularFont),
              alignment: TextAlignment.Center));

          if (nombreTarjetahabiente != null) {
            listOfTextLine.add(PrinterText(
                AsciiCodec().decode(nombreTarjetahabiente).toUpperCase(),
                format: TextFormat(fontSize: 16, fontFamily: regularFont),
                alignment: TextAlignment.Center));
          }
        } else if (_getCvmTypeStr(infoTags?.cvmResults) ==
            'PIN OFFLINE EN CLARO') {
          listOfTextLine.add(PrinterText(
              "AUTORIZADO MEDIANTE FIRMA ELECTRÓNICA".toUpperCase(),
              format: TextFormat(fontSize: 12, fontFamily: regularFont),
              alignment: TextAlignment.Center));
          if (nombreTarjetahabiente != null) {
            listOfTextLine.add(PrinterText(
                AsciiCodec().decode(nombreTarjetahabiente).toUpperCase(),
                format: TextFormat(fontSize: 12, fontFamily: regularFont),
                alignment: TextAlignment.Center));
          }
        } else {
          if (nombreTarjetahabiente != null) {
            listOfTextLine.add(PrinterText(
                AsciiCodec().decode(nombreTarjetahabiente).toUpperCase(),
                format: TextFormat(fontSize: 12, fontFamily: regularFont),
                alignment: TextAlignment.Center));
          }
        }
        break;
      case true:
        listOfTextLine.add(PrinterText(
            "AUTORIZADO SIN AUTENTICACIÓN DEL TARJETAHABIENTE".toUpperCase(),
            format: TextFormat(fontSize: 12, fontFamily: regularFont),
            alignment: TextAlignment.Center));
        if (nombreTarjetahabiente != null) {
          listOfTextLine.add(PrinterText(
              AsciiCodec().decode(nombreTarjetahabiente).toUpperCase(),
              format: TextFormat(fontSize: 12, fontFamily: regularFont),
              alignment: TextAlignment.Center));
        }
        break;
    }

    listOfTextLine.add(PrinterText.emptyLine(24));

    listOfTextLine.add(PrinterText(
        "PAGADERE NEGOCIABLE UNICAMENTE CON INSTITUCIONES DE CRÉDITO",
        format: TextFormat(fontSize: 12, fontFamily: regularFont),
        alignment: TextAlignment.Center));

    listOfTextLine.add(PrinterText.emptyLine(12));

    listOfTextLine.add(PrinterText(
        "POR ESTE PAGARE ME OBLIGO INCONDICIONALMENTE A PAGAR A LA ORDEN DE " +
            "BANCO ACREDITANTE EL IMPORTE DE ESTE TÍTULO.",
        format: TextFormat(fontSize: 12, fontFamily: regularFont),
        alignment: TextAlignment.Center));
    listOfTextLine.add(PrinterText(
        "ESTE PAGARE PROCEDE DEL CONTRATO DE APERTURA DE CREDITO QUE EL BANCO" +
            "ACREDITANTE Y EL TARJETAHABIENTE TIENEN CELEBRADO",
        format: TextFormat(fontSize: 12, fontFamily: regularFont),
        alignment: TextAlignment.Center));

    listOfTextLine.add(PrinterText.emptyLine(16));

    final platformInfo = await getPlatformInfo();

    if (platformInfo.hasPrinter) {
      final status = await getPrinterStatus();
      if (status == PrinterStatus.Ok) {
        final printerScript =
            PrinterScript(listOfTextLine, gray: GrayIntensity.Medium);
        printScript(printerScript, bottomFeed: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("${getLocalizations(context).printerError}: ${status.name}"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).printerNotSupported),
      ));
    }
  }

  String get _amountString {
    return _amountBytesToString(infoTags?.amount);
  }

  String get _amountOtherString {
    return _amountBytesToString(infoTags?.amountOther);
  }

  String _amountBytesToString(Uint8List? amountBytes) {
    if (amountBytes != null) {
      final amountInt = int.parse(amountBytes.toHexStr());
      final currencyFormat = AppConfig.getCurrencyFormat(context);
      return currencyFormat.format(amountInt / 100);
    }
    return '-';
  }

  String? get _kernelTypeStr {
    final kernelType = transactionArgs?.transactionInfo?.kernelType;
    switch (kernelType) {
      case ContactlessKernelType.PayPass:
        return "MasterCard PayPass";
      case ContactlessKernelType.PayWave:
        return "VISA PayWave";
      default:
        return null;
    }
  }

  List<Widget> _generateCommandTiles(
    String title,
    Map<int, Uint8List?>? tags,
  ) {
    return tags != null
        ? [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('CID (9F27)'),
              subtitle: Text(_getCidStr(tags[0x9f27])),
              onTap: () {},
            ),
            ListTile(
              enableFeedback: true,
              title: Text('TSI (9B)'),
              subtitle: Text(
                tags[0x9b]?.toHexStr().toUpperCase() ?? '-',
              ),
              onTap: () {
                _showTsiBitmap(tags[0x9b]);
              },
            ),
            ListTile(
              enableFeedback: true,
              title: Text('TVR (95)'),
              subtitle: Text(
                tags[0x95]?.toHexStr().toUpperCase() ?? '-',
              ),
              onTap: () {
                _showTvrBitmap(tags[0x95]);
              },
            ),
            Divider(),
          ]
        : List<Widget>.empty();
  }

  void _onTapAip() {
    final aip = infoTags?.aip;
    if (aip == null) return;

    final aipBitmap = getAipBitmap();
    aipBitmap.loadFromBytes(aip);
    showParamBitmapDialog(context, bitmap: aipBitmap, readOnly: true);
  }

  void _onTapTerminalCapabilities() {
    final capabilities = infoTags?.terminalCapabilities;
    if (capabilities == null) return;

    final capabilitiesBitmap = getTerminalCapabilitiesBitmap();
    capabilitiesBitmap.loadFromBytes(capabilities);
    showParamBitmapDialog(context, bitmap: capabilitiesBitmap, readOnly: true);
  }

  String _getCidStr(Uint8List? cid) {
    if (cid == null) return '-';

    final cidStr = cid.toHexStr();
    if (cidStr == "80") {
      return '80 - ARQC';
    } else if (cidStr == "40") {
      return '40 - TC';
    } else if (cidStr == "00") {
      return '00 - AAC';
    }

    return cidStr;
  }

  void _showTvrBitmap(Uint8List? tvr) {
    if (tvr == null) return;

    final tvrBitmap = getTvrBitmap();
    tvrBitmap.loadFromBytes(tvr);
    showParamBitmapDialog(context, bitmap: tvrBitmap, readOnly: true);
  }

  void _showTsiBitmap(Uint8List? tsi) {
    if (tsi == null) return;

    final tsiBitmap = getTsiBitmap();
    tsiBitmap.loadFromBytes(tsi);
    showParamBitmapDialog(context, bitmap: tsiBitmap, readOnly: true);
  }

  String _getCvmTypeStr(Uint8List? cvmResults) {
    if (cvmResults == null || cvmResults.length < 1) return '-';

    final cvmTypeByte = cvmResults[0] & 0x1f;
    switch (cvmTypeByte) {
      case 0x01:
        return getLocalizations(context).plaintextPINOffline;
      case 0x04:
        return getLocalizations(context).encipheredPINOffline;
      case 0x02:
        return getLocalizations(context).encipheredPINOnline;
      case 0x03:
        return getLocalizations(context).plaintextPINOfflineAndSignature;
      case 0x05:
        return getLocalizations(context).encipheredPINOfflineAndSignature;
      case 0x1E:
        return getLocalizations(context).signature;
      case 0x1F:
        return getLocalizations(context).noCVM;
    }

    return getLocalizations(context).unknown;
  }
}
