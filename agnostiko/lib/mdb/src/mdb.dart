import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'mdb_event.dart';

enum MdbResultCode { SUCCESS, TIMEOUT, ERROR, CANCELLED, DENIED, DISABLE }

const mdbEventsChannel = EventChannel('agnostiko/MdbEvents');
const mdbMethodChannel = MethodChannel('agnostiko/MdbMethods');

StreamSubscription<dynamic>? _mdbEventsSubscription;
BehaviorSubject<IMdbEvent>? _streamController;

Stream<IMdbEvent> openMDB({required MdbConfig config}) {
  final streamController = BehaviorSubject<IMdbEvent>();

  if (_mdbEventsSubscription != null) {
    throw StateError("Ya hay una transacción Mdb en proceso. "
        "Debe cancelarla antes de iniciar otra.");
  }
  Map<String, dynamic> configMap = config.toJson();
  _mdbEventsSubscription =
      mdbEventsChannel.receiveBroadcastStream(configMap).listen(
    (data) {
      final jsonObj = Map<String, dynamic>.from(data as Map);
      final event = IMdbEvent.fromJson(jsonObj);
      streamController.add(event);
    },
    onError: (Object error, StackTrace stackTrace) {
      streamController.addError(error, stackTrace);
      streamController.close();
      _mdbEventsSubscription = null;
    },
    onDone: () {
      streamController.close();
      _mdbEventsSubscription = null;
    },
    cancelOnError: true,
  );

  _streamController = streamController;
  return streamController.stream;
}

Future<void> closeMDB() async {
  await mdbMethodChannel.invokeMethod("closeMdb");
  await _streamController?.close();
  await _mdbEventsSubscription?.cancel();
  _mdbEventsSubscription = null;
}

Future<void> completeReaderEnable(MdbResultCode responseCode) async {
  await mdbMethodChannel.invokeMethod(
      "completeReaderEnable", responseCode.index);
}

Future<void> completeVendRequest(MdbResultCode responseCode) async {
  await mdbMethodChannel.invokeMethod("completeVendRequest", responseCode.index);
}

class MdbConfig {
  int featureLevel;
  Uint8List countryCode;
  int scaleFactor;
  int decimalPlaces;
  int maxResponseTime;
  bool refundSupport;
  bool multivendSupport;
  bool displaySupport;
  bool vendCashSupport;

  MdbConfig({
    required this.featureLevel,
    required this.countryCode,
    required this.scaleFactor,
    required this.decimalPlaces,
    required this.maxResponseTime,
    required this.refundSupport,
    required this.multivendSupport,
    required this.displaySupport,
    required this.vendCashSupport,
  });

  Map<String, dynamic> toJson() {
    return {
      'featureLevel': featureLevel,
      'countryCode': countryCode,
      'scaleFactor': scaleFactor,
      'decimalPlaces': decimalPlaces,
      'maxResponseTime': maxResponseTime,
      'refundSupport': refundSupport,
      'multivendSupport': multivendSupport,
      'displaySupport': displaySupport,
      'vendCashSupport': vendCashSupport,
    };
  }
}
