import 'dart:io';
import 'dart:convert';

import 'package:agnostiko/agnostiko.dart';

const _countersFilename = "counters.json";

class _CountersModel {
  int stan;
  int rrn;
  int transactionSequenceCounter;

  _CountersModel(this.stan, this.rrn, this.transactionSequenceCounter);

  factory _CountersModel.fromJson(Map<String, dynamic> jsonData) {
    return _CountersModel(
      jsonData['stan'],
      jsonData['rrn'],
      jsonData['transactionSequenceCounter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stan': stan,
      'rrn': rrn,
      'transactionSequenceCounter': transactionSequenceCounter,
    };
  }
}

Future<_CountersModel> _loadCountersData() async {
  try {
    final externalPath = (await getApplicationDocumentsDirectory()).path;
    final file = File('$externalPath/$_countersFilename');

    String jsonStr = await file.readAsString();
    print("***********Counters data: $jsonStr");
    return _CountersModel.fromJson(jsonDecode(jsonStr));
  } catch (e) {
    // Si falla la carga del archivo utilizamos valores iniciales
    return _CountersModel(1, 1, 1);
  }
}

/// Retorna el valor actual del contador de STAN y lo incrementa.
///
/// STAN es el acrónimo de 'System Trace Audit Number'. Este valor por lo
/// general se envía en el campo 11 de mensajes ISO8583 y se utiliza para
/// identificar los mensajes.
Future<int> getSTANCounterAndIncrement() async {
  final counters = await _loadCountersData();
  final stan = counters.stan; // guardamos el STAN actual para retornarlo

  // incrementamos el STAN y lo guardamos
  counters.stan += 1;
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_countersFilename');

  await file.writeAsString(jsonEncode(counters));
  return stan;
}

/// Retorna el valor actual del contador de RRN y lo incrementa.
///
/// RRN es el acrónimo de 'Retrieval Reference Number'. Este valor por lo
/// general se envía en el campo 37 de mensajes ISO8583 y se utiliza para
/// identificar transacciones.
Future<int> getRRNCounterAndIncrement() async {
  final counters = await _loadCountersData();
  final rrn = counters.rrn; // guardamos el RRN actual para retornarlo

  // incrementamos el RRN y lo guardamos
  counters.rrn += 1;
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_countersFilename');

  await file.writeAsString(jsonEncode(counters));
  return rrn;
}

/// Retorna el valor actual del contador de Transaction Sequence Counter y lo
/// incrementa.
///
/// Este contador se utiliza para la transacción EMV.
Future<int> getSequenceCounterAndIncrement() async {
  final counters = await _loadCountersData();

  // guardamos el sequenceCounter actual para retornarlo
  final sequenceCounter = counters.transactionSequenceCounter;

  // incrementamos el Transaction Sequence Counter y lo guardamos
  counters.transactionSequenceCounter += 1;

  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_countersFilename');

  await file.writeAsString(jsonEncode(counters));
  return sequenceCounter;
}
