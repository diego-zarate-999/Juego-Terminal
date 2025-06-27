import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

const serialEventsChannel = EventChannel('agnostiko/SerialPortEvents');
const serialMethodsChannel = MethodChannel('agnostiko/SerialPortMethods');

StreamSubscription<dynamic>? _serialReaderSubscription;
BehaviorSubject<SerialDataEvent>? _streamController;

class SerialDataEvent {
  final Uint8List data;
  const SerialDataEvent(this.data);

  factory SerialDataEvent.fromJson(Map<String, dynamic>jsonData){
    return SerialDataEvent(
      jsonData['data']
    );
  }
}
@experimental
Stream<SerialDataEvent> openSerial() {
  if (_serialReaderSubscription != null) {
    throw StateError("El puerto ya esta abierto");
  }

  final streamController = BehaviorSubject<SerialDataEvent>();

  _serialReaderSubscription =
      serialEventsChannel.receiveBroadcastStream().listen(
    (data) {
      final receivedData = Map<String, dynamic>.from(data as Map);
      final response = SerialDataEvent.fromJson(receivedData);

      streamController.add(response);
    },
    onError: (dynamic error, StackTrace stackTrace) {
      streamController.addError(error, stackTrace);
      streamController.close();
      _serialReaderSubscription = null;
    },
    onDone: () {
      streamController.close();
      _serialReaderSubscription = null;
    },
    cancelOnError: true,
  );

  _streamController = streamController;
  return streamController.stream;
}
@experimental
Future<void> writeSerial(Uint8List data) async {
  return await serialMethodsChannel.invokeMethod("writeSerial", data);
}
@experimental
Future<void> closeSerial() async {
  await _streamController?.close();
  await _serialReaderSubscription?.cancel();
  _serialReaderSubscription = null;
  return await serialMethodsChannel.invokeMethod("closeSerial");
}
