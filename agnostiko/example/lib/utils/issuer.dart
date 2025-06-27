import "package:agnostiko_example/models/transaction_args.dart";
import 'package:dart_des/dart_des.dart';

import "package:agnostiko/agnostiko.dart";
import "dart:typed_data";

Uint8List getCVN10ARPC(Uint8List udk, Uint8List arqc) {
  final sessionKey = udk;
  final paddedARC = "3030000000000000".toHexBytes();
  final y = arqc.xor(paddedARC);

  DES3 desECB = DES3(key: sessionKey, mode: DESMode.ECB);
  return Uint8List.fromList(desECB.encrypt(y).take(8).toList());
}

Uint8List derivateSessionKeyA131(Uint8List udk, Uint8List atc) {
  Uint8List f1 = Uint8List.fromList(
    atc + "F00000000000".toHexBytes(),
  );
  Uint8List f2 = Uint8List.fromList(
    atc + "0F0000000000".toHexBytes(),
  );

  DES3 desECB = DES3(key: udk, mode: DESMode.ECB);
  final sessionKeyLeft =
      Uint8List.fromList(desECB.encrypt(f1).take(8).toList());
  final sessionKeyRight =
      Uint8List.fromList(desECB.encrypt(f2).take(8).toList());

  return Uint8List.fromList(sessionKeyLeft + sessionKeyRight);
}

Uint8List getCVN18ARPC(Uint8List udk, Uint8List atc, Uint8List arqc) {
  final sessionKey = derivateSessionKeyA131(udk, atc);
  final csu = "00800000".toHexBytes();
  final propietaryData = Uint8List(0);

  final arqcPlusCSU = Uint8List.fromList(arqc + csu);
  final y = Uint8List.fromList(arqcPlusCSU + propietaryData);
  final macY = applyMAC(sessionKey, y);
  final arpc =
      Uint8List.fromList(macY.take(4).toList()); // solo los primeros 4 bytes

  final arpcPlusCSU = Uint8List.fromList(arpc + csu);
  return Uint8List.fromList(arpcPlusCSU + propietaryData);
}

Uint8List derivateMACSessionKey(Uint8List masterKey, Uint8List arqc) {
  final f1 = Uint8List(8);
  final f2 = Uint8List(8);
  f1[2] = 0xF0;
  f2[2] = 0x0F;

  DES3 desECB = DES3(key: masterKey, mode: DESMode.ECB);
  final sessionKeyLeft = Uint8List.fromList(desECB.encrypt(f1));
  final sessionKeyRight = Uint8List.fromList(desECB.encrypt(f2));
  return Uint8List.fromList(sessionKeyLeft + sessionKeyRight);
}

Uint8List applyMAC(Uint8List sessionKey, Uint8List data) {
  final msg = Uint8List.fromList(data + [0x80]).padBlockRight(8, 0x00);
  final iv = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
  Uint8List klBytes = Uint8List.fromList(sessionKey.take(8).toList());
  Uint8List krBytes = Uint8List.fromList(sessionKey.sublist(8).toList());
  DES desCBCL = DES(key: klBytes, mode: DESMode.CBC, iv: iv);
  DES desCBCR = DES(key: krBytes, mode: DESMode.CBC, iv: iv);
  final result = Uint8List.fromList(desCBCL.encrypt(msg));
  Uint8List hb = Uint8List.fromList(result.sublist(8).toList());
  final result2 = Uint8List.fromList(desCBCR.decrypt(hb));
  final result3 = Uint8List.fromList(desCBCL.encrypt(result2));
  return Uint8List.fromList(result3.take(8).toList());
}

Uint8List getMChipARPC(Uint8List masterKey, Uint8List arqc, Uint8List arc,
    Uint8List atc, Uint8List unpredictableNumber) {
  final sessionKey =
      derivateSessionKeyMChip(masterKey, atc, unpredictableNumber);
  final paddedARC = padBytesBlockRight(arc, 8, 0x00);
  final y = arqc.xor(paddedARC);

  DES3 desECB = DES3(key: sessionKey, mode: DESMode.ECB);
  return Uint8List.fromList(desECB.encrypt(y).take(8).toList());
}

Uint8List derivateSessionKeyMChip(
  Uint8List masterKey,
  Uint8List atc,
  Uint8List unpredictableNumber,
) {
  Uint8List f1 = Uint8List.fromList(
    atc + "F000".toHexBytes() + unpredictableNumber,
  );
  Uint8List f2 = Uint8List.fromList(
    atc + "0F00".toHexBytes() + unpredictableNumber,
  );

  DES3 desECB = DES3(key: masterKey, mode: DESMode.ECB);
  final sessionKeyLeft =
      Uint8List.fromList(desECB.encrypt(f1).take(8).toList());
  final sessionKeyRight =
      Uint8List.fromList(desECB.encrypt(f2).take(8).toList());

  return Uint8List.fromList(sessionKeyLeft + sessionKeyRight);
}

Future<EmvOnlineResponse> processUlTest(TransactionArgs transactionArgs) async {
  print("Ul test mode");
  if (transactionArgs.ulTestType == "Aprove") {
    print("UL test mode: aprove");
    return EmvOnlineResponse(
      authorisationResponseCode: "00",
    );
  } else if (transactionArgs.ulTestType == "Decline") {
    print("UL test mode: aprove");
    return EmvOnlineResponse(
      authorisationResponseCode: "05",
    );
  } else {
    late var arpc;
    late var iad;

    switch (transactionArgs.ulTestType) {
      case "CVN10":
        print("UL test mode: CVN10");
        final udk = "D5DFA2732080C1F74CFE83206EB502F4".toHexBytes();
        final arqc = await EmvModule.instance.getTagValue(0x9f26);
        arpc = getCVN10ARPC(udk, arqc!);
        iad = Uint8List.fromList(arpc + "3030".toHexBytes());
        break;
      case "CVN18":
        print("UL test mode: CVN18");
        final udk =
            "CB3425916E37AB5DF2C897C1BF0DD358".toHexBytes(); //Cambiar despues
        final arqc = await EmvModule.instance.getTagValue(0x9f26);
        final atc = await EmvModule.instance.getTagValue(0x9f36);
        arpc = getCVN18ARPC(udk, atc!, arqc!);
        iad = Uint8List.fromList(
            arpc + "1010".toHexBytes()); //verificar si lleva 1010
        break;
      default:
        print("UL test mode: default (MChip)");
        final arqc = await EmvModule.instance.getTagValue(0x9f26);
        final atc = await EmvModule.instance.getTagValue(0x9f36);
        final masterKey = "9E15204313F7318ACB79B90BD986AD29".toHexBytes();
        final arc = "3030".toHexBytes();
        final unpredictableNumber =
            await EmvModule.instance.getTagValue(0x9f27);
        arpc = getMChipARPC(masterKey, arqc!, arc, atc!, unpredictableNumber!);
        iad = Uint8List.fromList(arpc + "0010".toHexBytes());
        break;
    }
    //print("IAD: ${iad.toHexStr()}");

    return EmvOnlineResponse(
      authorisationResponseCode: "00",
      issuerAuthenticationData: iad,
    );
  }
}
