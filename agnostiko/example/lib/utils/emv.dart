import 'dart:async';
import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';
import 'package:agnostiko_example/models/alt_emv_app.dart';

import 'parameters.dart';

List<AltEmvApp> altApps = [
  AltEmvApp(
    //Visa
    aid: Uint8List.fromList([0xA0, 0x00, 0x00, 0x00, 0x03, 0x10, 0x10]),
    kernelId: Uint8List.fromList([0x03]),
    terminalTransactionQualifiers: Uint8List.fromList([0x32, 0x00, 0x40, 0x80]),
  ),
  AltEmvApp(
    //Visa
    aid: Uint8List.fromList([0xA0, 0x00, 0x00, 0x00, 0x03, 0x20, 0x10]),
    kernelId: Uint8List.fromList([0x03]),
    terminalTransactionQualifiers: Uint8List.fromList([0x32, 0x00, 0x40, 0x80]),
  ),
  AltEmvApp(
    //Visa
    aid: Uint8List.fromList([0xA0, 0x00, 0x00, 0x00, 0x98, 0x08, 0x40]),
    kernelId: Uint8List.fromList([0x03]),
    terminalTransactionQualifiers: Uint8List.fromList([0x32, 0x00, 0x40, 0x80]),
  ),
];

Future<void> emvPreTransaction({bool? isTestMode, bool? isTestPINMode}) async {
  final emv = EmvModule.instance;

  final terminalParameters = await loadTerminalParameters();
  if (isTestPINMode ?? false) {
    // Cambiamos los terminal capabilities para que solo acepten PIN Online como CVM
    terminalParameters.terminalCapabilities =
        Uint8List.fromList([0xE0, 0x40, 0xC8]);
  }
  await emv.initKernel(terminalParameters);
  print("EMV initialized!");

  final appList = await loadEmvAppList();
  for (final app in appList) {
    try {
      // Esta parte se encarga de cambiar temporalmente los tags de la EMVapp que se esta usando
      // cambia solo en caso de estar en ulTestMode
      // no afecta el uso normal de la aplicacion
      if (isTestMode ?? false) {
        //se busca que haya una EMVApp a sobreescribir en la lista de AltApps
        AltEmvApp matchingApp = altApps.firstWhere(
          (altApp) => altApp.aid == app.aid && altApp.kernelId == app.kernelId,
          orElse: () => AltEmvApp(),
        );
        if (matchingApp.aid != null) {
          // se modifica el terminalFloorLimit
          if (matchingApp.terminalFloorLimit != null) {
            app.terminalFloorLimit = matchingApp.terminalFloorLimit;
          }
          if (matchingApp.contactlessFloorLimit != null) {
            // se modifica el contactless floor limit
            app.contactlessFloorLimit = matchingApp.contactlessFloorLimit;
          }
          if (matchingApp.terminalTransactionQualifiers != null) {
            // se modifica el TTQ
            app.terminalTransactionQualifiers =
                matchingApp.terminalTransactionQualifiers;
          }
        }
      }
      await emv.addApp(app);
    } catch (e) {
      print("Error: '${app.aid.toHexStr()}'");
    }
  }

  var capkList = await loadCAPKList();
  for (final capk in capkList) {
    try {
      await emv.addCAPK(capk);
    } on CAPKChecksumException {
      print("CAPK Checksum Error: '${capk.rid.toHexStr()} - " +
          "${capk.index.toHexStr()}'");
    } catch (e) {
      print(
        "Error: '${capk.rid.toHexStr()} - " + "${capk.index.toHexStr()}'",
      );
    }
  }
}

Future<Map<int, Uint8List?>> emvGetGenerateCommandTags() async {
  final emv = EmvModule.instance;

  // guardamos el resultado de estos tags luego del 1st GAC
  final cid = await emv.getTagValue(0x9f27);
  final tsi = await emv.getTagValue(0x9b);
  final tvr = await emv.getTagValue(0x95);
  return {
    0x9f27: cid,
    0x9b: tsi,
    0x95: tvr,
  };
}

Future<String> emvGetClearPAN() async {
  final emv = EmvModule.instance;

  // Buscamos el PAN en estos tags, alguno de los 2 debería estar presente
  final tag5a = (await emv.getTagValue(0x5a))?.toHexStr().toUpperCase();
  final tag57 = (await emv.getTagValue(0x57))?.toHexStr().toUpperCase();

  // El tag 5A si la longitud del PAN es impar puede terminar en 'F', por eso
  // eliminamos ese carácter al final
  if (tag5a != null) {
    if (tag5a.endsWith('F')) {
      return tag5a.substring(0, tag5a.length - 1);
    } else {
      return tag5a;
    }
  }
  // El tag 57 contiene datos más allá del PAN, el cual culmina antes del
  // separador 'D', por eso se hace el recorte
  if (tag57 != null) {
    if (tag57.contains('D')) {
      return tag57.substring(0, tag57.indexOf('D'));
    } else {
      throw StateError("wrong tag 57 content");
    }
  }

  // si llegamos aquí abajo, ambos tags estaban nulos, lo cual no debería pasar
  throw StateError("missing PAN");
}

Future<Uint8List> emvGenerateField55() async {
  final emv = EmvModule.instance;

  /////// ISO8583 Field 55 ////////
  print("**Tags Field 55**");

  final tagsList = [
    0x5f2a,
    0x82,
    0x84,
    0x95,
    0x9a,
    0x9c,
    0x9f02,
    0x9f03,
    0x9f09,
    0x9f10,
    0x9f1a,
    0x9f1e,
    0x9f26,
    0x9f27,
    0x9f33,
    0x9f34,
    0x9f35,
    0x9f36,
    0x9f37,
    0x9f41,
    0x9f53,
    0x9f6e
  ];

  final pack = await emv.getTLV(tagsList);
  print("Field 55: '${pack.toHexStr()}'");

  final ttq = await emv.getTagValue(0x9f66);
  print("TTQ: ${ttq?.toHexStr()}");
  final floorLimit = await emv.getTagValue(0x9f1b);
  print("Floor Limit: ${floorLimit?.toHexStr()}");
  final df8123 = await emv.getTagValue(0xdf23);
  print("CLSS Floor Limit: ${df8123?.toHexStr()}");
  final df8126 = await emv.getTagValue(0xdf24);
  print("CLSS Transaction Limit: ${df8126?.toHexStr()}");
  final df26 = await emv.getTagValue(0xdf26);
  print("CLSS CVM Limit: ${df26?.toHexStr()}");
  final additionalTerminalCapabilities = await emv.getTagValue(0x9f40);
  print("Add Terminal Cap: ${additionalTerminalCapabilities?.toHexStr()}");
  final entryMode = await emv.getTagValue(0x9f39);
  print("Entry Mode: ${entryMode?.toHexStr()}");

  return pack;
}

class InfoTags {
  final String? cardNo;
  final Uint8List? transactionType;
  final Uint8List? amount;
  final Uint8List? amountOther;
  final Uint8List? aid;
  final Uint8List? aip;
  final Uint8List? terminalCapabilities;
  final Uint8List? cvmResults;
  final Uint8List? cvmList;
  final Uint8List? atc;

  InfoTags(
    this.cardNo,
    this.transactionType,
    this.amount,
    this.amountOther,
    this.aid,
    this.aip,
    this.terminalCapabilities,
    this.cvmResults,
    this.cvmList,
    this.atc,
  );
}

Future<InfoTags> loadInfoTags() async {
  final emv = EmvModule.instance;
  final tag9F53 = await emv.getTagValue(0x9f53);
  print("*********** TAG 0x9F53: ${tag9F53?.toHexStr()}");
  final tag9F34 = await emv.getTagValue(0x9f34);
  print("*********** TAG 0x9F34: ${tag9F34?.toHexStr()}");
  final tag9F6C = await emv.getTagValue(0x9f6c);
  print("*********** TAG 0x9F6C: ${tag9F6C?.toHexStr()}");
  return InfoTags(
    await emv.getMaskPAN(),
    await emv.getTagValue(0x9C),
    await emv.getTagValue(0x9f02),
    await emv.getTagValue(0x9f03),
    await emv.getTagValue(0x9F06),
    await emv.getTagValue(0x82),
    await emv.getTagValue(0x9f33),
    await emv.getTagValue(0x9f34),
    await emv.getTagValue(0x8e),
    await emv.getTagValue(0x9f36),
  );
}
