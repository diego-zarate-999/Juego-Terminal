import 'package:agnostiko/agnostiko.dart';
import 'dart:typed_data';
import '../utils/emv.dart';

enum EntryMode {
  Manual,
  Magstripe,
  Contact,
  Contactless,
}

class TransactionArgs {
  final PlatformInfo platformInfo;

  bool showNumericKeyboard = true;
  List<CardType> supportedCardTypes;
  EntryMode entryMode;
  bool isFallback = false;
  int emvTransactionType;

  int? amountInCents;
  String? pan;
  String? expDate;
  String? cvv;
  String? clearTrack1;
  String? clearTrack2;
  int? stan;

  Stream<dynamic>? emvStream;

  int? remainingPinTries;

  /// Aquí seteamos los tags relevantes tras el comando 1st GENERATE AC
  Map<int, Uint8List?>? firstGenerateTags;

  /// Aquí seteamos los tags relevantes tras el comando 2nd GENERATE AC
  Map<int, Uint8List?>? secondGenerateTags;

  InfoTags? infoTags;

  EmvTransactionInfo? transactionInfo;

  ///////////////// PARÁMETROS PARA MODO DE PRUEBA /////////////////

  /// Modo de prueba EMV
  bool? testMode;

  /// Nombre de set de pruebas
  String? testSetName;

  /// PAN de tarjeta EMV a probar
  String? testPAN;

  /// Tipo de test de UL
  String? ulTestType;

  /// Bool para saber si testear cosas de UL
  bool? ulTestMode;

  ///////////////// PARÁMETROS PARA MODO DE PRUEBA DE PIN /////////////////

  /// Modo de prueba de PIN
  bool? testPinMode;

  bool? isDUKPTPin;
  Uint8List? actualPinBlock;
  Uint8List? actualKsn;
  int? dukptInputCounter;

  TransactionArgs({
    required this.platformInfo,
    required this.entryMode,
    required this.showNumericKeyboard,
    required this.supportedCardTypes,
    required this.emvTransactionType,
    this.amountInCents,
    this.pan,
    this.expDate,
    this.cvv,
    this.stan,
    this.testMode,
    this.testSetName,
    this.testPAN,
    this.ulTestType,
    this.ulTestMode,
    this.testPinMode,
    this.isDUKPTPin,
    this.actualPinBlock,
    this.actualKsn,
    this.dukptInputCounter
  });
}
