import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:prueba_ag/pharos/card_data.dart';
import 'package:prueba_ag/pharos/tags.dart';
import 'package:prueba_ag/pharos/key_init_request.dart';
import 'package:intl/intl.dart';

import 'package:agnostiko/agnostiko.dart';

import 'card_data_manual.dart';
import 'card_sale_request.dart';
import 'manual_sale_request.dart';
import 'void_request.dart';
import '../config/app_keys.dart';
import '../models/transaction_args.dart';
import '../utils/counters.dart';

/// Genera mensaje de venta o reembolso para switch Pharos
Future<Map<String, dynamic>> pharosGenerateSaleMsg(
  TransactionArgs transactionArgs,
) async {
  final emvModule = EmvModule.instance;
  final now = DateTime.now();
  final dateStr = DateFormat("yyyy-MM-dd hh:mm:ss")
      .format(now)
      .replaceAll("-", "")
      .replaceAll(" ", "")
      .replaceAll(":", "");

  int? amountInCents = transactionArgs.amountInCents;
  if (amountInCents == null) {
    throw StateError("El monto no puede ser un valor nulo");
  }
  final amount = (amountInCents / 100).toDouble().toStringAsFixed(2);

  final tags = await _getTagsPharos();
  String readingMethod = _getReadingMethod(transactionArgs);

  String expYear = await _getExpDate(false, transactionArgs);
  String expMonth = await _getExpDate(true, transactionArgs);
  final tag5F20 = await emvModule.getTagValue(0x5F20);
  String? cardHolderName;

  bool isSale =
      (transactionArgs.emvTransactionType != EmvTransactionType.Refund);

  if (tag5F20 != null) {
    cardHolderName = AsciiCodec().decode(tag5F20);
  }
  final currency = "484";
  final orderNumber = "#723456";
  final terminalCode = "1774";
  final merchantCode = "1230";
  if (transactionArgs.entryMode == EntryMode.Contact ||
      transactionArgs.entryMode == EntryMode.Contactless ||
      transactionArgs.entryMode == EntryMode.Magstripe) {
    final stan = await getSTANCounterAndIncrement();
    transactionArgs.stan = stan;

    String track2;
    String ksn;
    try {
      final resultado =
          await _getEncryptedTrack2Pharos(transactionArgs.entryMode);
      track2 = resultado.data.toHexStr();
      ksn = resultado.ksn.toHexStr();
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      track2 = transactionArgs.clearTrack2 ?? "";
      ksn = "";
    }

    final card = CardData(
      readingMethod: readingMethod,
      track2: track2,
      expMonth: expMonth,
      expYear: expYear,
      cardholderName: cardHolderName,
      tags: tags,
    );
    return PharosCardSaleRequest(
      stan: stan.toString(),
      date: dateStr,
      card: card,
      amount: amount,
      currency: currency,
      orderNumber: orderNumber,
      terminalCode: terminalCode,
      merchantCode: merchantCode,
      isSale: isSale,
      ksn: ksn,
    ).toJson();
  } else {
    final pan = transactionArgs.pan;
    if (pan == null) {
      throw StateError("PAN value missing");
    }
    final cvv = transactionArgs.cvv;
    if (cvv == null) {
      throw StateError("CVV value missing");
    }

    String expYear = await _getExpDate(false, transactionArgs);
    String expMonth = await _getExpDate(true, transactionArgs);
    final card = CardDataManual(
      readingMethod: readingMethod,
      cardNumber: pan,
      secCode: cvv,
      expMonth: expMonth,
      expYear: expYear,
      cardholderName: cardHolderName,
    );
    return PharosManualSaleRequest(
      date: dateStr,
      card: card,
      amount: amount,
      currency: currency,
      orderNumber: orderNumber,
      terminalCode: terminalCode,
      merchantCode: merchantCode,
      isSale: isSale,
    ).toJson();
  }
}

/// Genera mensaje de reverso para switch Pharos
Future<Map<String, dynamic>> pharosGenerateVoidMsg(
  String stan,
) async {
  final terminalCode = "1774";
  final merchantCode = "1230";
  return PharosVoidRequest(stan, terminalCode, merchantCode).toJson();
}

Future<DUKPTResult> _getEncryptedTrack2Pharos(EntryMode entryMode) async {
  final iv = "0000000000000000".toHexBytes();

  DUKPTResult? resultado;
  if (entryMode == EntryMode.Contact || entryMode == EntryMode.Contactless) {
    resultado = await EmvModule.instance.getDUKPTEncryptedTagValue(
      0x57, // Tag 57 - Track 2 Equivalent Data
      AppKeys.des.transaction.index,
      CipherMode.CBC,
      iv,
    );
  } else if (entryMode == EntryMode.Magstripe) {
    final tracksData = await getDUKPTEncryptedTracksData(
      AppKeys.des.transaction.index,
      CipherMode.CBC,
      iv,
    );
    resultado = tracksData?.track2;
  }
  await cryptoIncrementKSN(AppKeys.des.transaction);

  if (resultado == null) {
    throw StateError("null encryption result");
  }
  return resultado;
}

String _getReadingMethod(TransactionArgs transactionArgs) {
  String readingMethod;
  switch (transactionArgs.entryMode) {
    case EntryMode.Manual:
      readingMethod = "key_entry";
      break;
    case EntryMode.Contact:
      readingMethod = "chip";
      break;
    case EntryMode.Magstripe:
      readingMethod = "swipe";
      break;
    case EntryMode.Contactless:
      readingMethod = "contactless";
      break;
  }
  return readingMethod;
}

Future<Tags> _getTagsPharos() async {
  final emvModule = EmvModule.instance;
  final tag9A = await emvModule.getTagValue(0x9A);
  final tagC0 = await emvModule.getTagValue(0xC0);
  final tag9F26 = await emvModule.getTagValue(0xC0);
  final tag9B = await emvModule.getTagValue(0x9B);
  final tag4F = await emvModule.getTagValue(0x9B);
  final tag9F27 = await emvModule.getTagValue(0x9F27);

  final tags = Tags(
      tag9A: tag9A,
      tagC0: tagC0,
      tag9F26: tag9F26,
      tag9B: tag9B,
      tag4F: tag4F,
      tag9F27: tag9F27);

  return tags;
}

Future<String> _getExpDate(
    bool isMonth, TransactionArgs transactionArgs) async {
  final emvModule = EmvModule.instance;
  final expDate = await emvModule.getTagValue(0x5F24);
  String expYear;
  String expMonth;
  String? track2Str = transactionArgs.clearTrack2?.toUpperCase();
  String? expDateManual = transactionArgs.expDate?.toUpperCase();
  if (expDate != null && expDate.length >= 2) {
    expYear = expDate.toHexStr().substring(0, 2);
    expMonth = expDate.toHexStr().substring(2, 4);
  } else if (track2Str != null &&
      track2Str.isNotEmpty &&
      (track2Str.contains('D') || track2Str.contains('='))) {
    int characterIndex;
    if (track2Str.contains('D')) {
      characterIndex = track2Str.lastIndexOf('D');
    } else {
      characterIndex = track2Str.lastIndexOf('=');
    }

    final expDateFromTrack2 =
        track2Str.substring((characterIndex + 1), (characterIndex + 5));
    expYear = expDateFromTrack2.substring(0, 2);
    expMonth = expDateFromTrack2.substring(2, 4);
  } else if (expDateManual != null && expDateManual.length >= 4) {
    expYear = expDateManual.substring(0, 2);
    expMonth = expDateManual.substring(2, 4);
  } else {
    expYear = "";
    expMonth = "";
  }

  if (isMonth) {
    return expMonth;
  } else {
    return expYear;
  }
}

/// Genera un mensaje para inicialización de llave DUKPT de Pharos
Future<Map<String, dynamic>> pharosGenerateKeyInitialization({
  required Uint8List cipheredTK,
  required Uint8List kcv,
}) async {
  final cipheredTKStr = cipheredTK.toHexStr().toUpperCase();
  final crcValue = calculateCRC32(AsciiCodec().encode(cipheredTKStr));
  return PharosKeyInitRequest(
          terminalCode: "1774",
          merchantCode: "1230",
          encryptedRandomKey: cipheredTK.toHexStr(),
          randomKeyCheckValue: kcv.toHexStr(),
          randomKeyCRC: crcValue.toHexStr())
      .toJson();
}
