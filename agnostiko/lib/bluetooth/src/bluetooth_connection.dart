import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'bluetooth.dart';

/// Conexión bluetooth con un dispositivo remoto
class BluetoothConnection {
  static int _connectionIdCounter = 0;

  int _id;

  final EventChannel _readChannel;
  late StreamSubscription<Uint8List> _readStreamSubscription;
  late StreamController<Uint8List> _readStreamController;

  /// Stream de para recibir datos en este canal
  Stream<Uint8List>? input;

  /// Stream de datos de salida en este canal
  late _BluetoothStreamSink<Uint8List> output;

  /// Indica si el stream se mantiene conectado
  bool get isConnected => output.isConnected;

  BluetoothConnection._(int id)
      : this._id = id,
        this._readChannel = EventChannel('agnostiko/BluetoothEvents/$id') {
    _readStreamController = StreamController<Uint8List>();

    _readStreamSubscription =
        _readChannel.receiveBroadcastStream().cast<Uint8List>().listen(
              _readStreamController.add,
              onError: _readStreamController.addError,
              onDone: this.close,
            );

    input = _readStreamController.stream;
    output = _BluetoothStreamSink<Uint8List>(id);
  }

  /// Crea una conexión con la dirección [address] especificada
  static Future<BluetoothConnection> toAddress(String address) async {
    final id = ++_connectionIdCounter;
    await bluetoothChannel.invokeMethod('connect', {
      "id": id,
      "address": address,
    });
    return BluetoothConnection._(id);
  }

  /// Cierra correctamente los recursos de la conexión
  void dispose() {
    finish();
  }

  /// Cierra la conexión inmediatamente
  Future<void> close() {
    return Future.wait([
      output.close(),
      _readStreamSubscription.cancel(),
      (!_readStreamController.isClosed)
          ? _readStreamController.close()
          : Future.value(/* Empty future */)
    ], eagerError: true);
  }

  /// Termina la conexión (de manera pausada)
  Future<void> finish() async {
    await output.allSent;
    close();
  }
}

/// Clase utilitaria para la salida de datos en la conexión
class _BluetoothStreamSink<Uint8List> extends StreamSink<Uint8List> {
  final int _id;

  /// Indica si el stream está conectado
  bool isConnected = true;

  Future<void> _chainedFutures = Future.value();

  late Future<dynamic> _doneFuture;

  /// Excepción retornada en la llamada 'done' del canal
  dynamic exception;

  _BluetoothStreamSink(this._id) {
    // `_doneFuture` must be initialized here because `close` must return the same future.
    // If it would be in `done` get body, it would result in creating new futures every call.
    _doneFuture = Future(() async {
      // @TODO ? is there any better way to do it? xD this below is weird af
      while (this.isConnected) {
        await Future.delayed(Duration(milliseconds: 111));
      }
      if (this.exception != null) {
        throw this.exception;
      }
    });
  }

  /// Agrega bytes al canal de salida bluetooth.
  ///
  /// La data por lo general se envía inmediatamente. Pero si se quiere esperar
  /// con seguridad a que se haya enviado, se puede usar [allSent].
  ///
  /// Falla con [StateError] si no está conectado.
  @override
  void add(Uint8List data) {
    if (!isConnected) {
      throw StateError("Not connected!");
    }

    _chainedFutures = _chainedFutures.then((_) async {
      if (!isConnected) {
        throw StateError("Not connected!");
      }

      await bluetoothChannel.invokeMethod('write', {'id': _id, 'data': data});
    }).catchError((e) {
      this.exception = e;
      close();
    });
  }

  /// No soportado - este sink de salida no puede retornar errores
  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    throw UnsupportedError(
        "BluetoothConnection output (response) sink cannot receive errors!");
  }

  @override
  Future addStream(Stream<Uint8List> stream) => Future(() async {
        // @TODO ??? `addStream`, "alternating simultaneous addition" problem (read below)
        // If `onDone` were called some time after last `add` to the stream (what is okay),
        // this `addStream` function might wait not for the last "own" addition to this sink,
        // but might wait for last addition at the moment of the `onDone`.
        // This can happen if user of the library would use another `add` related function
        // while `addStream` still in-going. We could do something about it, but this seems
        // not to be so necessary since `StreamSink` specifies that `addStream` should be
        // blocking for other forms of `add`ition on the sink.
        var completer = Completer();
        stream.listen(this.add).onDone(completer.complete);
        await completer.future;
        await _chainedFutures; // Wait last* `add` of the stream to be fulfilled
      });

  @override
  Future close() {
    isConnected = false;
    return this.done;
  }

  @override
  Future get done => _doneFuture;

  /// Retorna un [Future] que se completa cuando el sink ha enviado toda la data
  /// de salida
  Future get allSent => Future(() async {
        // Simple `await` can't get job done here, because the `_chainedFutures` member
        // in one access time provides last Future, then `await`ing for it allows the library
        // user to add more futures on top of the waited-out Future.
        Future lastFuture;
        do {
          lastFuture = this._chainedFutures;
          await lastFuture;
        } while (lastFuture != this._chainedFutures);

        if (this.exception != null) {
          throw this.exception;
        }

        this._chainedFutures =
            Future.value(); // Just in case if Dart VM is retarded
      });
}
