import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../utils/utils.dart';
import 'mpos_connection.dart';
import 'mpos_controller.dart';

BinaryMessenger _mposBinaryMessenger = _MPOSBinaryMessenger._();
BinaryMessenger? _defaultBinaryMessenger =
    ServicesBinding.instance.defaultBinaryMessenger;

class HybridMethodChannel extends MethodChannel {
  const HybridMethodChannel(String name)
      : super(
          name,
          const StandardMethodCodec(),
          const _HybridBinaryMessenger._(),
        );
}

class HybridEventChannel extends EventChannel {
  const HybridEventChannel(String name)
      : super(
          name,
          const StandardMethodCodec(),
          const _HybridBinaryMessenger._(),
        );

  @override
  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel =
        MethodChannel(name, codec, binaryMessenger);
    late StreamController<dynamic> controller;
    controller = StreamController<dynamic>.broadcast(onListen: () async {
      binaryMessenger.setMessageHandler(name, (ByteData? reply) async {
        if (reply == null) {
          controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply));
          } on PlatformException catch (e) {
            controller.addError(e);
          }
        }
        return null;
      });
      try {
        await methodChannel.invokeMethod<void>('listen', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription(
            'while activating platform stream on channel $name',
          ),
        ));
      }
    }, onCancel: () async {
      binaryMessenger.setMessageHandler(name, null);
      try {
        await methodChannel.invokeMethod<void>('cancel', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription(
            'while de-activating platform stream on channel $name',
          ),
        ));
      }
    });
    return controller.stream;
  }
}

class _HybridBinaryMessenger extends BinaryMessenger {
  const _HybridBinaryMessenger._();

  @override
  Future<void> handlePlatformMessage(String channel, ByteData? data,
      ui.PlatformMessageResponseCallback? callback) async {
    return _defaultBinaryMessenger?.handlePlatformMessage(
      channel,
      data,
      callback,
    );
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) async {
    final activeMPOS = MPOSController.instance.getActiveConnection();
    if (activeMPOS != null && activeMPOS.isConnected == true) {
      return _mposBinaryMessenger.send(channel, message);
    } else {
      return _defaultBinaryMessenger?.send(channel, message);
    }
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    final activeMPOS = MPOSController.instance.getActiveConnection();
    if (activeMPOS != null && activeMPOS.isConnected == true) {
      _mposBinaryMessenger.setMessageHandler(channel, handler);
    } else {
      _defaultBinaryMessenger?.setMessageHandler(channel, handler);
    }
  }
}

int _platformMessageId = 0;

class _MPOSBinaryMessenger extends BinaryMessenger {
  const _MPOSBinaryMessenger._();

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? message,
    ui.PlatformMessageResponseCallback? callback,
  ) async {}

  @override
  Future<ByteData?> send(String channel, ByteData? message) async {
    try {
      if (_platformMessageId < 0xFFFF) {
        _platformMessageId++;
      } else {
        _platformMessageId = 1;
      }

      final msgIdStr = _platformMessageId.toRadixString(16).padLeft(4, "0");
      final msgId = msgIdStr.toHexBytes();

      final msgData = message?.buffer.asUint8List(
        message.offsetInBytes,
        message.lengthInBytes,
      );

      final mposMessage = MPOSMessage(msgId, channel, msgData);
      final activeMPOS = MPOSController.instance.getActiveConnection();
      activeMPOS?.send(mposMessage);

      final response = await activeMPOS?.messageResponseStream?.firstWhere(
        (response) => response.id.toHexStr() == msgIdStr,
      );
      final responseData = response?.data;

      return responseData != null ? ByteData.sublistView(responseData) : null;
    } catch (exception, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'agnostiko',
        context:
            ErrorDescription('during a platform message response callback'),
      ));
    }
    return null;
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    final activeMPOS = MPOSController.instance.getActiveConnection();
    activeMPOS?.setMessageHandler(channel, handler);
  }
}
