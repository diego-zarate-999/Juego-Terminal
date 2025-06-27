import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agnostiko/agnostiko.dart';

import 'package:agnostiko_example/dialogs/list_selection_dialog.dart';
import 'package:agnostiko_example/dialogs/map_selection_dialog.dart';
import 'package:agnostiko_example/models/transaction_args.dart';
import 'package:agnostiko_example/utils/emv.dart';
import 'package:agnostiko_example/utils/emv_test.dart';
import 'package:agnostiko_example/utils/locale.dart';
import 'package:agnostiko_example/views/emv_test/emv_card_input.dart';

import 'package:path/path.dart' as p;

Future<void> testEmv(BuildContext context) async {
  final platformInfo = await getPlatformInfo();
  final deviceType = await getDeviceType();
  if (deviceType != DeviceType.PINPAD) {
    await emvPreTransaction();
  }

  final String? testSetName = await showListSelectionDialog(
    context,
    [
      "Willians",
      "Yura",
    ],
  );
  final Map<String, String> testOptions;
  if (testSetName == "Willians") {
    testOptions = {
      "Visa con PIN": "4761731000000043",
      "Mastercard con PIN": "5413330089604111",
    };
  } else if (testSetName == "Yura") {
    testOptions = {
      "Visa con PIN": "4761731000000043",
      "Mastercard": "5413330089604111",
      "Amex": "374245001751006",
      "Discover con PIN": "6510000000000216"
    };
  } else {
    return;
  }

  final String? testPAN = await showMapSelectionDialog(context, testOptions);
  if (testPAN == null) return;
  final String? testInterface = await showListSelectionDialog(
    context,
    [
      "ICC",
      "RF",
    ],
  );
  if (testInterface == null) return;
  final List<CardType> cardType;
  final EntryMode entryMode;
  switch (testInterface) {
    case "ICC":
      cardType = [CardType.IC];
      entryMode = EntryMode.Contact;
      break;
    case "RF":
      cardType = [CardType.RF];
      entryMode = EntryMode.Contactless;
      break;
    default:
      cardType = [];
      entryMode = EntryMode.Manual;
      break;
  }
  final String? transactionTypeSelection = await showListSelectionDialog(
    context,
    [
      "Sale",
      "Refund",
    ],
  );
  if (transactionTypeSelection == null) return;
  final int transactionType;
  switch (transactionTypeSelection) {
    case "Sale":
      transactionType = EmvTransactionType.Goods;
      break;
    case "Refund":
      transactionType = EmvTransactionType.Refund;
      break;
    default:
      transactionType = EmvTransactionType.Goods;
      break;
  }

  Navigator.pushNamed(
    context,
    EMVTestCardInput.route,
    arguments: TransactionArgs(
      platformInfo: platformInfo,
      entryMode: entryMode,
      showNumericKeyboard: true,
      supportedCardTypes: cardType,
      emvTransactionType: transactionType,
      amountInCents: 8000,
      testMode: true,
      testSetName: testSetName,
      testPAN: testPAN,
    ),
  );
}

Future<bool?> testEMVPan(BuildContext context, String pan, TransactionArgs? transactionArgs) async {
  try {
    /// En esta sección se genera un archivo temporal que se usa como referencia
    /// para la comparación de las transacciones y se mueve para poder ser usado
    /// en la comparación
    
    //String fileName = await _generateDynamicRefFileName(transactionArgs);
    //final path = '/mnt/sdcard/Download/$fileName'; //Newland
    ////final path = '/tmp/$fileName'; //Pax
    //await _moveFile("emv_log", path);

    final testSetName = transactionArgs?.testSetName ?? "";
    final transactionType =
        transactionArgs?.emvTransactionType == EmvTransactionType.Refund ? "refund" : "sale";
    final entryMode = transactionArgs?.entryMode == EntryMode.Contactless ? "rf" : "icc";

    List<Iterable<int>>? ranges = getEMVTestSetRanges(testSetName, pan, entryMode, transactionType);
    if (ranges == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).notImplemented)));
      Navigator.pop(context);
      return null;
    }
    final assetsPath = 'assets/emv_logs_reference/$testSetName/${pan}_${entryMode}_$transactionType';
    final comparationResult = await _compareFiles("emv_log", assetsPath, ranges: ranges);

    return comparationResult;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    print("Error: $e");
    return null;
  }
}
Future<bool> _compareFiles(String fileName, String referenceFilePath,
    {List<Iterable<int>>? ranges}) async {
  Directory directory = await getApplicationDocumentsDirectory();
  // Crear un objeto File con la ruta de origen
  String parent = p.dirname(directory.path);
  String filePath = '$parent/files/$fileName';

  final file = File(filePath);
  final referenceFile = await rootBundle.load(referenceFilePath);

  Uint8List fileBytesContent = await file.readAsBytes();
  Uint8List referenceFileBytesContent = referenceFile.buffer.asUint8List();

  List<int>? ignoreIndex;
  if (ranges != null) {
    ignoreIndex = generateIndexesToIgnore(ranges);
  }
  final result = fileBytesContent.compareWithIgnore(referenceFileBytesContent,
      ignoreIndex: ignoreIndex);

  return result;
}

/// En esta función se genera el nombre del archivo dinámico que se usará de
/// referencia.
Future<String> _generateDynamicRefFileName(TransactionArgs? transactionArgs) async {
  final transactionType = transactionArgs?.emvTransactionType == EmvTransactionType.Refund ? "refund" : "sale";
  final entryMode = transactionArgs?.entryMode == EntryMode.Contactless ? "rf" : "icc";

  String? panNullable = transactionArgs?.pan;
  String pan = "XXXXXXXXXXXXXXXX";

  if (panNullable != null) {
    pan = panNullable;
  } else {
    final tag57 = await EmvModule.instance.getTagValue(0x57);
    if (tag57 != null) {
      final endPanIndex = tag57.toHexStr().toUpperCase().indexOf('D') != -1
          ? tag57.toHexStr().toUpperCase().indexOf('D')
          : tag57.toHexStr().toUpperCase().indexOf('=');
      pan = tag57.toHexStr().substring(0, endPanIndex);
    }
  }
  String fileName = "${pan}_${entryMode}_$transactionType";
  return fileName;
}

/// En esta función se mueve el archivo de emv_log a la carpeta de descargas o 
/// temporal según la marca que se esté usando
Future<void> _moveFile(String fileOlddName, String destinationPath) async {
  // Obtener la ruta del directorio de documentos de la aplicación
  Directory directory = await getApplicationDocumentsDirectory();
  // Crear un objeto File con la ruta de origen
  String parent = p.dirname(directory.path);
  String sourcePath = '$parent/files/$fileOlddName';
  // /mnt/sdcard/Download/ ---> newland
  // /tmp/ ---> pax
  File sourceFile = File(sourcePath);

  // Verificar si el archivo existe
  if (await sourceFile.exists()) {
    File destinationFile = File(destinationPath);
    //Crear un  IOSink para escribir en el archivo de dewstino
    IOSink sink = destinationFile.openWrite();
    // Copiar el contenido como bytes
    await sink.addStream(sourceFile.openRead());
    await sink.close();
    //await sourceFile.delete();ç
    print('Archivo movido exitosamente');
  } else {
    // Imprimir un mensaje de error
    print('Archivo no encontrado');
  }
}

  