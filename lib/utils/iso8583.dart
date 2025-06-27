import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:agnostiko/agnostiko.dart';

import '../config/app_keys.dart';
import '../models/transaction_args.dart';
import 'emv.dart';
import 'counters.dart';

final isoSaleDefinitions = {
  2: FieldDefinition.variable(IsoFieldFormat.N, 19),
  3: FieldDefinition.fixed(IsoFieldFormat.N, 6),
  4: FieldDefinition.fixed(IsoFieldFormat.N, 12),
  11: FieldDefinition.fixed(IsoFieldFormat.N, 6),
  12: FieldDefinition.fixed(IsoFieldFormat.N, 6),
  13: FieldDefinition.fixed(IsoFieldFormat.N, 4),
  14: FieldDefinition.fixed(IsoFieldFormat.N, 4),
  22: FieldDefinition.fixed(IsoFieldFormat.N, 3),
  23: FieldDefinition.fixed(IsoFieldFormat.N, 3),
  35: FieldDefinition.variable(IsoFieldFormat.NS, 37),
  37: FieldDefinition.fixed(IsoFieldFormat.ANS, 12),
  39: FieldDefinition.fixed(IsoFieldFormat.AN, 2),
  41: FieldDefinition.fixed(IsoFieldFormat.ANS, 8),
  48: FieldDefinition.variable(IsoFieldFormat.ANS, 27,
      fieldLenFormat: IsoFieldLen.LLLVAR),
  55: FieldDefinition.variable(IsoFieldFormat.B, 999),
  57: FieldDefinition.variable(
    IsoFieldFormat.ANS,
    15,
    fieldLenFormat: IsoFieldLen.LLLVAR,
  ),
  60: FieldDefinition.variable(
    IsoFieldFormat.ANS,
    2,
    fieldLenFormat: IsoFieldLen.LLLVAR,
  ),
  63: FieldDefinition.variable(
    IsoFieldFormat.ANS,
    999,
    fieldLenFormat: IsoFieldLen.LLLVAR,
  ),
};

/// Genera un mensaje ISO 0200 para Venta con tarjeta o digitada
Future<IsoMessage> isoGenerateSaleMsg(
  TransactionArgs transactionArgs,
) async {
  final emvModule = EmvModule.instance;
  final isoMsg = IsoMessage.withFields(isoSaleDefinitions);
  isoMsg.mti = Mti.fromString("0200");

  final capx = CapX(AppKeys.des.transaction.index);
  bool hasEncryption = false;
  try {
    hasEncryption = await capx.checkKeyExists();
  } catch (e) {
    print("Error: $e");
  }

  if (!hasEncryption && transactionArgs.entryMode == EntryMode.Manual) {
    isoMsg.setField(2, transactionArgs.pan ?? '');
  }

  isoMsg.setField(3, "000000"); // Proc Code: Compra
  isoMsg.setField(4, transactionArgs.amountInCents.toString());

  // Contador de mensajes 'System Trace Audit Number (STAN)'
  final stan = await getSTANCounterAndIncrement();
  transactionArgs.stan = stan;
  isoMsg.setField(11, stan.toString());

  final now = DateTime.now();
  final timeStr = DateFormat('hhmmss').format(now);
  isoMsg.setField(12, timeStr);

  final dateStr = DateFormat('MMdd').format(now);
  isoMsg.setField(13, dateStr);

  if (transactionArgs.entryMode == EntryMode.Manual) {
    isoMsg.setField(14, transactionArgs.expDate ?? '');
  }

  if (transactionArgs.entryMode == EntryMode.Manual) {
    // '011' = Entrada Manual y Puede aceptar NIP
    isoMsg.setField(22, "011");
  } else if (transactionArgs.entryMode == EntryMode.Magstripe) {
    if (transactionArgs.isFallback) {
      // '801' = Fallback y Puede aceptar NIP
      isoMsg.setField(22, "801");
    } else {
      // '901' = Banda magnética leída y Puede aceptar NIP
      isoMsg.setField(22, "901");
    }
  } else if (transactionArgs.entryMode == EntryMode.Contact) {
    // 1-2: Chip leído, CVV confiable 3: Puede aceptar NIP
    isoMsg.setField(22, "051");
  } else if (transactionArgs.entryMode == EntryMode.Contactless) {
    // TODO - Revisar como diferenciar proceso Contactless modo CHIP de modo
    // BANDA ya que '07' es Chip y '91' es Banda
    // 072: Contactless Chip y No puede aceptar NIP (ya que CTLSS usa PIN
    // online, lo cual aún no soportamos)
    isoMsg.setField(22, "072");
  }

  if (transactionArgs.entryMode == EntryMode.Contact ||
      transactionArgs.entryMode == EntryMode.Contactless) {
    final panSequenceNumber = await emvModule.getTagValue(0x5f34);
    isoMsg.setField(23, panSequenceNumber?.toHexStr() ?? '001');
  }

  if (!hasEncryption && transactionArgs.entryMode == EntryMode.Magstripe) {
    final track2 = Track2.fromString(transactionArgs.clearTrack2 ?? '');
    isoMsg.setField(35, track2.toString());
  }

  // ID de transacción 'Retrieval Reference Number (RRN)'
  final rrn = await getRRNCounterAndIncrement();
  final rrnStr = rrn.toString().padLeft(8, '0');
  isoMsg.setField(37, "    $rrnStr");

  //final terminalParams = await loadTerminalParameters();
  //isoMsg.setField(41, terminalParams.terminalId); // Card Acceptor Terminal ID
  final terminalId = "12345678";
  isoMsg.setField(41, terminalId); // Card Acceptor Terminal ID

  // TODO - Averiguar que va en este campo exactamente
  isoMsg.setField(48, "001234567                  "); // Retailer Data

  if (transactionArgs.entryMode == EntryMode.Contact ||
      transactionArgs.entryMode == EntryMode.Contactless) {
    final field55 = await emvGenerateField55();
    isoMsg.setBinaryField(55, field55);
  }

  final cvv = transactionArgs.cvv;
  if (!hasEncryption && cvv != null) {
    isoMsg.setField(57, "9033$cvv        "); // CV2 data
  }

  // 08 = Lector de banda magnética, entrada manual y lector de chip
  // compatible EMV
  isoMsg.setField(60, "08"); // POS Terminal Entry Capability

  String? serialNumber = await getSerialNumber();

  if (hasEncryption) {
    if (serialNumber == null) {
      throw StateError("El serial no puede ser nulo");
    }
    await _isoSetField63(isoMsg, transactionArgs, capx, serialNumber);
  }

  return isoMsg;
}

Future<void> _isoSetField63(
  IsoMessage isoMsg,
  TransactionArgs transactionArgs,
  CapX capx,
  String serialNumber,
) async {
  DUKPTResult track2CVVResult;
  DUKPTResult track1Result;
  int clearTrack1Len;
  int clearTrack2Len;
  bool track1Flag;
  String lastPANDigits;

  final track1Str = transactionArgs.clearTrack1?.toUpperCase() ?? "";

  if (transactionArgs.entryMode == EntryMode.Contact ||
      transactionArgs.entryMode == EntryMode.Contactless) {
    // Para transacciones con chip obtenemos el tag 57 con paddeo automático.
    final encryptedTrack2Cvv = await capx.getEncryptedTag57();
    if (encryptedTrack2Cvv == null) {
      throw StateError("track 2 data missing");
    }
    track2CVVResult = encryptedTrack2Cvv;

    // el resultado nos permite obtener la longitud real antes de cifrar
    // la longitud en bytes * 2 es la longitud en posiciones hexadecimales
    clearTrack2Len = track2CVVResult.actualDataLen * 2;

    // Si el track 2 del tag 57 tiene longitud > 16 bytes está todo OK ya que
    // se paddea automático a 48 posiciones
    // Sin embargo, si el track 2 en bytes tiene longitud <= 16 nos faltaría
    // un bloque de paddeo
    // Esto ocupa el track 2 leído del chip sin CVV
    // NOTA: esto funciona porque el modo de encriptado es ECB. Si fuera CBC
    // no se pudiera encriptar un bloque de paddeo independiente
    if (track2CVVResult.data.length <= 16) {
      final padding = Uint8List.fromList(List<int>.filled(8, 0xFF));
      final cryptoPadding = await capx.encrypt(padding);
      track2CVVResult.data =
          Uint8List.fromList(track2CVVResult.data + cryptoPadding.data);
    }

    // el resto de posiciones lo llenamos con 'F' para el Track 1 faltante
    final porcionTrack1 = "".padRight(160, "F").toHexBytes();
    track1Result = await capx.encrypt(porcionTrack1);
    clearTrack1Len = 0;
    track1Flag = false; // no hay track1

    final maskPAN = await EmvModule.instance.getMaskPAN();
    if (maskPAN == null) {
      throw StateError("PAN data missing");
    }
    lastPANDigits = maskPAN.substring(maskPAN.length - 4, maskPAN.length);
  } else if (transactionArgs.entryMode == EntryMode.Magstripe) {
    final tracksData = await capx.getEncryptedMagneticTracks();
    if (tracksData == null) {
      throw StateError("tracks data missing");
    }
    final encryptedTrack2Cvv = tracksData.track2;
    if (encryptedTrack2Cvv == null) {
      throw StateError("track 2 missing");
    }
    track2CVVResult = encryptedTrack2Cvv;

    // el resultado nos permite obtener la longitud real antes de cifrar
    // la longitud en bytes * 2 es la longitud en posiciones hexadecimales
    clearTrack2Len = track2CVVResult.actualDataLen * 2;

    // Si el track 2 > 16 bytes está todo OK ya que se paddea automático a 48
    // posiciones
    // Sin embargo, si el track 2 en bytes tiene longitud <= 16 nos faltaría
    // un bloque de paddeo
    // Esto ocupa el track 2 sin CVV
    // NOTA: esto funciona porque el modo de encriptado es ECB. Si fuera CBC
    // no se pudiera encriptar un bloque de paddeo independiente
    if (track2CVVResult.data.length <= 16) {
      final padding = Uint8List.fromList(List<int>.filled(8, 0xFF));
      final cryptoPadding = await capx.encrypt(padding);
      track2CVVResult.data =
          Uint8List.fromList(track2CVVResult.data + cryptoPadding.data);
    }

    final track1Data = tracksData.track1;
    if (track1Data != null) {
      track1Result = track1Data;
      clearTrack1Len = track1Result.actualDataLen;
      track1Flag = true; // track1 detectado correctamente
    } else {
      // relleno con 'F' si falta el track 1
      final porcionTrack1 = "".padRight(160, "F").toHexBytes();
      track1Result = await capx.encrypt(porcionTrack1);
      clearTrack1Len = 0;
      track1Flag = false; // no hay track1
    }

    final maskPAN = tracksData.maskPAN;
    if (maskPAN == null) {
      throw StateError("PAN data missing");
    }
    lastPANDigits = maskPAN.substring(maskPAN.length - 4, maskPAN.length);
  } else {
    final track2Str = transactionArgs.clearTrack2?.toUpperCase() ?? "";
    clearTrack2Len = track2Str.length;

    final porcionTrack2 = track2Str.replaceFirst("=", "D").padRight(38, "F");
    final cvvStr = transactionArgs.cvv?.toUpperCase() ?? "";
    final porcionCvv = cvvStr.padRight(10, "F");
    final track2CVVBlock = (porcionTrack2 + porcionCvv).toHexBytes();
    track2CVVResult = await capx.encrypt(track2CVVBlock);

    final track1Ascii = AsciiCodec().encode(track1Str).toHexStr().toUpperCase();
    final porcionTrack1 = track1Ascii.padRight(160, "F");
    final track1Block = porcionTrack1.toHexBytes();
    track1Result = await capx.encrypt(track1Block);
    clearTrack1Len = 0;
    track1Flag = false; // no hay track1

    final separatorIndex = track2Str.indexOf("=");
    lastPANDigits = track2Str.substring(separatorIndex - 4, separatorIndex);
  }
  await capx.incrementKSN();

  // TODO - contador de cifrados 'reales'
  // el contador 'real' en este caso lo extraemos del KSN, en la práctica
  // debería venir de otra parte ya que no tienen porque ser iguales
  final counter =
      int.parse(track2CVVResult.ksn.toHexStr().substring(4), radix: 16) &
          0x1FFFFF;

  // De momento no estamos solicitando el CVV dado que no hay un método seguro
  // para hacerlo en MPOS. Para POS se puede trabajar sin problema a partir de
  // los datos en claro
  final cvvFlag = "A";
  final cvvLen = 0;

  final tokenEZ = isoTokenEZ(
    ksn: track2CVVResult.ksn,
    cipherCounter: counter,
    // TODO - contador de transacciones fallidas consecutivas
    failedCipherCounter: 0,
    entryMode: transactionArgs.entryMode,
    isFallback: transactionArgs.isFallback,
    cipheredData: track2CVVResult.data,
    clearTrack2Len: clearTrack2Len,
    track1Flag: track1Flag,
    lastPANDigits: lastPANDigits,
    cvvFlag: cvvFlag,
    cvvLen: cvvLen,
  );

  final tokenEY = isoTokenEY(
    track1Length: clearTrack1Len,
    cipheredData: track1Result.data,
  );

  final tokenES = isoTokenES(
    isCiphered: true,
    requiresNewKey: false,
    serialNumber: serialNumber,
  );

  // finalmente, seteamos el campo 63
  isoMsg.setField(63, tokenEZ + tokenEY + tokenES);
}

/// Genera un mensaje ISO para inicialización de llave DUKPT (a lo Capítulo X)
Future<IsoMessage> isoGenerateKeyInitialization({
  required Uint8List cipheredTK,
  required Uint8List kcv,
}) async {
  final isoMsg = IsoMessage.withFields(isoSaleDefinitions);
  isoMsg.mti = Mti.fromString("0200");

  isoMsg.setField(3, "000000"); // Proc Code: Compra
  isoMsg.setField(4, "000000000000");

  // Contador de mensajes 'System Trace Audit Number (STAN)'
  final stan = await getSTANCounterAndIncrement();

  isoMsg.setField(11, stan.toString());

  final now = DateTime.now();
  final timeStr = DateFormat('hhmmss').format(now);
  isoMsg.setField(12, timeStr);

  final dateStr = DateFormat('MMdd').format(now);
  isoMsg.setField(13, dateStr);

  isoMsg.setField(22, "010"); // Como si fuera 'Manual'

  // ID de transacción 'Retrieval Reference Number (RRN)'
  final rrn = await getRRNCounterAndIncrement();
  final rrnStr = rrn.toString().padLeft(8, '0');
  isoMsg.setField(37, "    $rrnStr");

  //final terminalParams = await loadTerminalParameters();
  //isoMsg.setField(41, terminalParams.terminalId); // Card Acceptor Terminal ID
  final terminalId = "12345678";
  isoMsg.setField(41, terminalId); // Card Acceptor Terminal ID

  // TODO - Averiguar que va en este campo exactamente
  isoMsg.setField(48, "001234567                  "); // Retailer Data

  // 08 = Lector de banda magnética, entrada manual y lector de chip
  // compatible EMV
  isoMsg.setField(60, "08"); // POS Terminal Entry Capability

  String? serialNumber = await getSerialNumber();
  if (serialNumber == null) {
    throw StateError("El serial no puede ser nulo");
  }
  final tokenES = isoTokenES(
    isCiphered: true,
    requiresNewKey: true,
    serialNumber: serialNumber,
  );
  final tokenEW = isoTokenEW(cipheredTK: cipheredTK, kcv: kcv);
  isoMsg.setField(63, tokenEW + tokenES);
  return isoMsg;
}

String isoTokenES({
  required bool isCiphered,
  required bool requiresNewKey,
  required String serialNumber,
}) {
  assert(serialNumber.length <= 20);
  String paddedSN = serialNumber.padRight(20, ' ');

  return "! ES00060 " + // Header
          "LUP-202111          " + // Versión de Software
          paddedSN + // Serial del PIN PAD
          (isCiphered ? "5" : "0") + // "5" está cifrando datos
          "00000000" + // BINES Locales por la Caja
          "00000000" + // BINES Locales en PIN PAD
          "00" + // Versión BINES En PIN PAD
          (requiresNewKey ? "1" : "0") // "1" se requiere una nueva llave
      ;
}

/// Arma el Token EW para inicialización de llaves.
///
/// OJO: El CRC32 se calcula automáticamente, solo se debe proveer [cipheredTK]
/// con la data de la llave de transporte cifrada bajo RSA y su respectivo KCV.
String isoTokenEW({
  required Uint8List cipheredTK,
  required Uint8List kcv,
}) {
  assert(cipheredTK.length == 256);
  assert(kcv.length == 3);

  final cipheredTKStr = cipheredTK.toHexStr().toUpperCase();
  final crcValue = calculateCRC32(AsciiCodec().encode(cipheredTKStr));
  return "! EW00538 " + // Header
          cipheredTKStr + // llave TK cifrada con la llave pública RSA
          kcv.toHexStr().toUpperCase() + // Key Check Value de la llave TK
          "BCMER001  " + // Versión Llave Pública RSA
          "01" + // Algoritmo de Padding: PKCS 1.5
          crcValue.toHexStr().toUpperCase() // CRC32 de llave TK cifrada
      ;
}

String isoTokenEZ({
  required Uint8List ksn,
  required int cipherCounter,
  required int failedCipherCounter,
  required EntryMode entryMode,
  required bool isFallback,
  required Uint8List cipheredData,
  required int clearTrack2Len,
  required bool track1Flag,
  required String lastPANDigits,
  required String cvvFlag,
  required int cvvLen,
}) {
  assert(ksn.length == 10);
  assert(cipheredData.length == 24);

  String entryModeStr;
  switch (entryMode) {
    case EntryMode.Manual:
      entryModeStr = "01";
      break;
    case EntryMode.Magstripe:
      entryModeStr = isFallback ? "80" : "90";
      break;
    case EntryMode.Contact:
      entryModeStr = "05";
      break;
    case EntryMode.Contactless:
      entryModeStr = "07";
      break;
  }

  final crcValue = calculateCRC32(AsciiCodec().encode(cipheredData.toHexStr()));
  return "! EZ00098 " + // Header
          ksn.toHexStr().toUpperCase() + // KSN actual de llave de encriptado
          cipherCounter.toString().padLeft(7, "0") + //contador real de cifrados
          // Identifica cuántas transacciones le han declinado consecutivamente
          failedCipherCounter.toString().padLeft(2, "0") +
          "1" + // Bandera de Track 2
          entryModeStr + // Modo de Lectura de la Tarjeta
          // Longitud de track 2 en claro
          clearTrack2Len.toString().padLeft(2, "0") +
          cvvFlag + // Bandera de Track 2
          // Longitud de cvv2 en claro
          cvvLen.toString().padLeft(2, "0") +
          (track1Flag ? "1" : "0") + // Bandera de Track 2
          cipheredData.toHexStr().toUpperCase() + // Datos Sensitivos Cifrados
          lastPANDigits + // 4 Últimos Dígitos del PAN
          crcValue.toHexStr().toUpperCase() // CRC32 sobre Datos Sensitivos
      ;
}

String isoTokenEY({
  required int track1Length,
  required Uint8List cipheredData,
}) {
  assert(cipheredData.length == 80);

  final crcValue = calculateCRC32(AsciiCodec().encode(cipheredData.toHexStr()));
  return "! EY00172 " + // Header
          track1Length.toString().padLeft(4, "0") + // Longitud del Track 1
          cipheredData.toHexStr().toUpperCase() + // Datos de track1 Cifrados
          crcValue.toHexStr().toUpperCase() // CRC32 sobre track 1 cifrado
      ;
}
