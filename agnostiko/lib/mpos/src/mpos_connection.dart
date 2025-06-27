import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';

import 'package:agnostiko/agnostiko.dart';

/// Respuesta a mensaje de MPOS de acuerdo al codec de Flutter
class MPOSMessageResponse {
  final Uint8List id;
  final Uint8List data;

  MPOSMessageResponse(this.id, this.data);
}

/// Mensaje para el MPOS que debe estar de acuerdo al codec de Flutter
class MPOSMessage {
  final Uint8List id;
  final String channel;
  final Uint8List? data;

  MPOSMessage(this.id, this.channel, this.data);
}

/// Conexión a dispositivo MPOS para intercambio de datos de PlatformChannel
class MPOSConnection {
  /// Stream por donde llegan las respuestas de los mensajes enviados al MPOS
  Stream<MPOSMessageResponse>? messageResponseStream;

  final Map<String, MessageHandler> _messageHandlers = {};

  final _byteControl = BehaviorSubject<int>();
  final BluetoothConnection _btConnection;
  late StreamQueue<int> _byteQueue;

  String? _name;

  /// Etiqueta de nombre para display
  String? get name => _name;

  MPOSConnection._(this._btConnection, this._name) {
    _byteQueue = StreamQueue(_byteControl.stream);
  }

  /// Crea una conexión bluetooth con el dispositivo [device] especificado
  static Future<MPOSConnection> toBluetoothDevice(
    BluetoothDevice device,
  ) async {
    final connection = await BluetoothConnection.toAddress(device.address);

    final mpos = MPOSConnection._(connection, device.name);

    final responseControl = BehaviorSubject<MPOSMessageResponse>();
    mpos.messageResponseStream = responseControl.stream;
    mpos._runMessageLoop(responseControl);

    return mpos;
  }

  /// Indica si la conexión se encuentra activa
  bool get isConnected => _btConnection.isConnected;

  /// Cierra la conexión
  void close() {
    _btConnection.close();
  }

  /// Envía un mensaje al MPOS conectado
  void send(MPOSMessage message) {
    var bytes = List<int>.empty(growable: true);

    // el primer byte en 0x00 indica que esto es un mensaje y no una respuesta
    bytes += [0x00];
    bytes += message.id;

    if (message.channel.length > 255) {
      throw StateError("channel name too long");
    }
    bytes += [message.channel.length];
    bytes += AsciiCodec().encode(message.channel);

    final data = message.data;
    if (data != null) {
      final msgBytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // 4 nibbles = 2 bytes = 16 bits -> max message len: 65,535
      final msgLen = msgBytes.length.toRadixString(16).padLeft(4, "0");

      bytes += msgLen.toHexBytes();
      bytes += msgBytes;
    } else {
      bytes += [0]; // longitud 0 si no hay mensaje
    }

    final byteData = Uint8List.fromList(bytes);
    _btConnection.output.add(byteData);
  }

  void _runMessageLoop(
    BehaviorSubject<MPOSMessageResponse> responseControl,
  ) async {
    final sub = _btConnection.input?.listen((data) {
      for (final i in data) {
        _byteControl.add(i);
      }
    }, onDone: () {
      _byteControl.close();
    });

    while (isConnected) {
      try {
        final isResponseData = await _readBytes(1);
        final isResponse = isResponseData[0] == 0x01;

        if (isResponse) {
          await _processMessageResponse(responseControl);
        } else {
          await _processMessage();
        }
      } catch (e, stackTrace) {
        print(stackTrace);
      }
    }

    _btConnection.close();
    responseControl.close();
    sub?.cancel();
  }

  Future<void> _processMessageResponse(
    BehaviorSubject<MPOSMessageResponse> responseControl,
  ) async {
    final responseId = await _readBytes(2);
    final responseLenBytes = await _readBytes(2);
    final responseLen = int.parse(responseLenBytes.toHexStr(), radix: 16);
    final responseData = await _readBytes(responseLen);

    responseControl.add(MPOSMessageResponse(responseId, responseData));
  }

  /// Este método procesa mensajes recibidos desde un canal abierto
  /// TODO - actualmente no se puede dar respuesta a estos mensajes
  Future<void> _processMessage() async {
    // TODO - la respuesta debe llevar el ID
    final messageId = await _readBytes(2);

    final channelNameLenData = await _readBytes(1);
    final channelNameLen = channelNameLenData[0];
    final channelNameData = await _readBytes(channelNameLen);
    final channelName = AsciiCodec().decode(channelNameData);

    final msgDataLenBytes = await _readBytes(2);
    final msgDataLen = int.parse(msgDataLenBytes.toHexStr(), radix: 16);
    final msgData = await _readBytes(msgDataLen);

    final handler = _messageHandlers[channelName];
    if (handler != null) {
      // TODO - que se pueda responder si el canal lo soporta
      final response = await handler(ByteData.sublistView(msgData));
    }
  }

  Future<Uint8List> _readBytes(int bytesCount) async {
    return Uint8List.fromList(await _byteQueue.take(bytesCount));
  }

  /// Setea un [handler] para mensajes recibidos en el [channel] especificado
  void setMessageHandler(String channel, MessageHandler? handler) {
    if (handler != null) {
      _messageHandlers[channel] = handler;
    } else {
      _messageHandlers.remove(channel);
    }
  }
}
