import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/locale.dart';

showMdbTestDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return mdbView();
    },
  );
}

class mdbView extends StatefulWidget {
  const mdbView({super.key});

  @override
  State<mdbView> createState() => _mdbViewState();
}

class _mdbViewState extends State<mdbView> {
  String mdbStatus = "";
  String amount = "";
  String price = "";
  String index = "";
  bool mdbEnabled = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsOverflowButtonSpacing: 1,
      actionsPadding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      title: Center(child: Text("Mdb session")),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      content: SizedBox(
        width: 200.0,
        height: 225.0,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Text("Session state:"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(mdbStatus),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text("Item Price: $price"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text("Item index: $index"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text("amount: $amount"),
              ),
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
          child: const Text("Init mdb"),
          onPressed: mdbEnabled
              ? null
              : () {
                  _startMdbSession();
                  mdbStatus = "on";
                  setState(() {});
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
          child: const Text("Close Mdb"),
          onPressed: mdbEnabled
              ? () {
                  // para realmente cerrar la sesion se tiene que picar stop desde
                  // el simulador ya que solo dar close y luego open
                  // encima sesiones en el sim hasta causar un segmentation fault
                  _closeMdbSession();
                  mdbStatus = "off";
                  setState(() {});
                  Navigator.pop(context);
                }
              : null,
        ),
      ],
    );
  }

  _closeMdbSession() async {
    mdbEnabled = false;
    await closeMDB();
  }

  _startMdbSession() async {
    mdbEnabled = true;
    final cardTypes = [CardType.RF];
    MdbConfig config = MdbConfig(
      featureLevel: 0x01,
      countryCode: Uint8List.fromList([0x18, 0x40]),
      scaleFactor: 0x01,
      decimalPlaces: 0x02,
      maxResponseTime: 0x1e,
      refundSupport: false,
      multivendSupport: true,
      displaySupport: true,
      vendCashSupport: true,
    );
    final mdbEventStream = openMDB(config: config);
    late Stream<CardDetectedEvent> cardReaderStream;
    await for (final event in mdbEventStream) {
      if (event is MdbReaderCancelEvent) {
        mdbStatus = "Reader cancel";
        closeCardReader();
      } else if (event is MdbReaderDisableEvent) {
        mdbStatus = "Reader disable";
        closeCardReader();
      } else if (event is MdbReaderEnableEvent) {
        mdbStatus = "Reader enable";
        try {
          //Aqui se inicia el reader
          cardReaderStream = openCardReader(cardTypes: cardTypes);
          mdbStatus = "Select Product";
          completeReaderEnable(MdbResultCode.SUCCESS);
          //se puede llamar tambien disable pero no sirve de mucho
          //completeVendRequest(ResultCode.DISABLE);
        } catch (e) {
          print(e);
          completeReaderEnable(MdbResultCode.ERROR);
        }
      } else if (event is MdbResetEvent) {
        mdbStatus = "Reset";
      } else if (event is MdbRevalueLimitEvent) {
        mdbStatus = "Revalue limit";
      } else if (event is MdbRevalueRequestEvent) {
        mdbStatus = "Revalue Request";
      } else if (event is MdbSessionCompleteEvent) {
        mdbStatus = "Session complete";
        closeCardReader();
      } else if (event is MdbSetupConfigDataEvent) {
        mdbStatus = "Setup Config";
      } else if (event is MdbSetupPriceLimitEvent) {
        mdbStatus = "Setup price limit";
      } else if (event is MdbVendCancelEvent) {
        mdbStatus = "Vend Cancel";
      } else if (event is MdbVendFailureEvent) {
        mdbStatus = "Vend failure";
      } else if (event is MdbVendRequestEvent) {
        setState(() {
          mdbStatus = "Acerca tarjeta rf";
          amount = event.amount;
          index = event.itemIndex.toString();
          price = event.itemPrice;
        });
        try {
          await for (final event in cardReaderStream) {
            if (!mounted) return;
            if (event.cardType == CardType.RF) {
              //aqui va toda la logica del pago
              //si falla tambien se puede enviar cancelled y denied
              //dependiendo del resultado del pago
              //por cuestiones de solo ser demo no se cobra aun
              //completeVendRequest(ResultCode.CANCELLED);
              //completeVendRequest(ResultCode.DENIED);
              completeVendRequest(MdbResultCode.SUCCESS);
            }
          }
        } on TimeoutException {
          completeVendRequest(MdbResultCode.TIMEOUT);
        } catch (e) {
          print(e);
          completeVendRequest(MdbResultCode.ERROR);
        }
      } else if (event is MdbVendSuccessEvent) {
        mdbStatus = "Vend success";
        amount = "";
        index = "";
        price = "";
      }
      setState(() {});
    }
  }
}
