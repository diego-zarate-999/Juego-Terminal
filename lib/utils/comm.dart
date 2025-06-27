import 'dart:convert';
import 'dart:io';

import 'package:prueba_ag/pharos/key_init_response.dart';
import 'package:flutter/foundation.dart';

import 'package:agnostiko/agnostiko.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../pharos/sale_response.dart';
import '../pharos/void_response.dart';
import 'iso8583.dart';

const pharosUsername = "NECS01Oeyx";
const pharosPassword = "xNjUg5nKwHYgCHgtJrKxdzSZ";

Future<Uint8List> getToken(String serialNumber) async {
  final response = await http.get(
    Uri.parse(
      'https://server-agnostiko-web-gnbxyenkeq-ue.a.run.app/token/${serialNumber.toUpperCase()}',
    ),
  );
  return response.bodyBytes;
}

/// Registra los Logs de APDU del flujo EMV en el storage disponible para el
/// proyecto.
///
/// [fileBytes] es el contenido del archivo binario a ser registrado en formato
/// Uint8List.
///
/// Retorna un entero con el Status Code recibido de la solicitud.
Future<int> registerAPDULogs(Uint8List fileBytes) async {
  final headers = {
    'Key': ''
  };

  final response = await http.post(
    Uri.parse(
      'https://server-agnostiko-web-develop-gnbxyenkeq-ue.a.run.app/api/logs/agnostiko',
    ),
    headers: headers,
    body: fileBytes,
  );
  return response.statusCode;
}

Future<PharosSaleResponse> processSalePharos(
    Map<String, dynamic> pharosMsg) async {
  const usernameAndPassword = "$pharosUsername:$pharosPassword";
  final bytes = utf8.encode(usernameAndPassword);
  final encoded = base64.encode(bytes);
  final authorizationStr = "Basic $encoded";

  var header = {"Authorization": authorizationStr};
  final response = await http
      .post(
          Uri.parse(
            'http://api-sandbox.pharospayments.com/gateway/charge',
          ),
          headers: header,
          body: jsonEncode(pharosMsg))
      .timeout(const Duration(seconds: 30));
  final pharosResponseJson = jsonDecode(response.body.toString());
  final saleResponse = PharosSaleResponse.fromJson(pharosResponseJson);
  print("Pharos Sale response : ${response.body.toString()}");
  return saleResponse;
}

Future<PharosVoidResponse> processVoidPharos(
    Map<String, dynamic> pharosVoidMsg) async {
  const usernameAndPassword = "$pharosUsername:$pharosPassword";
  final bytes = utf8.encode(usernameAndPassword);
  final encoded = base64.encode(bytes);
  final authorizationStr = "Basic $encoded";

  var header = {"Authorization": authorizationStr};
  final response = await http.post(
      Uri.parse(
        'http://api-sandbox.pharospayments.com/gateway/charge',
      ),
      headers: header,
      body: jsonEncode(pharosVoidMsg));
  final pharosResponseJson = jsonDecode(response.body.toString());
  final voidResponse = PharosVoidResponse.fromJson(pharosResponseJson);
  print("Pharos Void response : ${response.body.toString()}");
  return voidResponse;
}

Future<IsoMessage> processSale(IsoMessage isoMsg) async {
  final isoBytes = isoMsg.pack();
  final response = await http.get(
    Uri.parse(
      'https://server-agnostiko-web-gnbxyenkeq-ue.a.run.app/sale/${isoBytes.toHexStr().toUpperCase()}',
    ),
  );
  return IsoMessage.unpack(
    response.body.toHexBytes(),
    fieldDefinitions: isoSaleDefinitions,
  );
}

Future<PharosKeyInitResponse> processKeyInitPharos(
    Map<String, dynamic> pharosMsgKeyInit) async {
  const usernameAndPassword = "$pharosUsername:$pharosPassword";
  final bytes = utf8.encode(usernameAndPassword);
  final encoded = base64.encode(bytes);
  final authorizationStr = "Basic $encoded";
  var header = {"Authorization": authorizationStr};
  final response = await http.post(
      Uri.parse(
        'http://api-sandbox.pharospayments.com/gateway/charge',
      ),
      headers: header,
      body: jsonEncode(pharosMsgKeyInit));
  final pharosResponseJson = jsonDecode(response.body.toString());
  final keyInitResponse = PharosKeyInitResponse.fromJson(pharosResponseJson);
  print("Pharos Key init response: ${response.body.toString()}");
  return keyInitResponse;
}

Future<IsoMessage> processKeyInit(IsoMessage isoMsg) async {
  final isoBytes = isoMsg.pack();
  final response = await http.get(
    Uri.parse(
      'https://server-agnostiko-web-gnbxyenkeq-ue.a.run.app/keyinit/${isoBytes.toHexStr().toUpperCase()}',
    ),
  );
  return IsoMessage.unpack(
    response.body.toHexBytes(),
    fieldDefinitions: isoSaleDefinitions,
  );
}

Future<void> downloadFile(String url, String filePath) async {
  final httpClient = HttpClient();
  httpClient.badCertificateCallback = (cert, host, port) => true;

  final request = await httpClient.getUrl(Uri.parse(url));
  final response = await request.close();
  if (response.statusCode == 200) {
    final bytes = await consolidateHttpClientResponseBytes(response);
    final file = File(filePath);
    if (Platform.isLinux) {
      final directory = Directory(file.parent.path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
    await file.writeAsBytes(bytes);
  }
}

void openWebSocketConnection(
  String ipAddress,
  void Function(String, PlatformInfo) onData,
) async {
  final sn = await getSerialNumber();
  final platformInfo = await getPlatformInfo();
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://$ipAddress:4000'),
  );
  print("WebSocket open...");
  channel.sink.add(sn);
  channel.stream.listen(
    (message) {
      onData(message, platformInfo);
    },
    onError: (e) {
      print("ERROR EN CHANNEL: $e");
    },
    onDone: () {
      print("CHANNEL DONE");
    },
    cancelOnError: true,
  );
}

void listenToUdpMulticast(void Function(String, PlatformInfo) onData) async {
  InternetAddress multicastAddress = InternetAddress("239.10.10.100");
  int multicastPort = 4545;
  RawDatagramSocket.bind(InternetAddress.anyIPv4, multicastPort)
      .then((RawDatagramSocket socket) {
    print('Datagram socket ready to receive');
    print('${socket.address.address}:${socket.port}');

    socket.joinMulticast(multicastAddress);
    print('Multicast group joined');

    socket.listen((RawSocketEvent e) {
      Datagram? d = socket.receive();
      if (d == null) return;

      String message = String.fromCharCodes(d.data).trim();
      print('Datagram from ${d.address.address}:${d.port}: $message');
      if (message == 'agnostiko') {
        socket.close();
        openWebSocketConnection(d.address.address, onData);
      }
    });
  });
}
