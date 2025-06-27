import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/cupertino.dart';

/// Clase notificadora de cambios en conexión MPOS
class _ConnectionChangeNotifier extends ChangeNotifier {
  void notifyChange() {
    notifyListeners();
  }
}

/// Control para comunicación de la librería con múltiples dispositivos MPOS
///
/// Se debe utilizar la instancia [instance] de esta clase para crear y
/// controlar las conexiones con los dispositivos MPOS que se deseen operar con
/// el SDK Agnostiko.
class MPOSController {
  final _channel = HybridMethodChannel("agnostiko/MPOS");

  MPOSController._();

  /// Instancia única (**singleton**) de este módulo
  static final MPOSController instance = MPOSController._();

  /// Objeto interno para envío de notificaciones a 'listeners' que deseen
  /// saber cuando ocurre un cambio en las conexiones de este controlador
  final _connectionChangeNotifier = _ConnectionChangeNotifier();

  final _connections = Map<String, MPOSConnection>();
  String? _activeConnectionAddress;

  /// Indica si este controlador tiene una conexión activa con un MPOS
  bool get hasActiveConnection => this.getActiveConnection() != null;

  /// Registra listener para cambios en las conexiones de MPOS
  ///
  /// Permite a la interfaz reaccionar a cambios en el estatus de las conexiones
  /// MPOS de este controlador
  ///
  /// El [callback] se dispara cuando se registra una nueva conexión, cuando hay
  /// un cambio en la conexión activa (usando [setActiveConnectionByAddress]) o
  /// cuando alguna conexión existente es desconectada
  void addConnectionChangeListener(VoidCallback callback) {
    _connectionChangeNotifier.addListener(callback);
  }

  /// Elimina un callback previamente registrado para cambios de conexión MPOS
  void removeConnectionChangeListener(VoidCallback callback) {
    _connectionChangeNotifier.removeListener(callback);
  }

  /// Abre una conexión bluetooth con el dispositivo [device] especificado
  ///
  /// Esta conexión se elimina automáticamente del controlador si se desconecta
  /// de alguna manera
  ///
  /// Se debe checar con [checkAddressConnection] si la conexión ya existe
  /// porque de ser así, este llamado falla con [StateError]
  Future<void> openBluetoothConnection(BluetoothDevice device) async {
    if (_connections.containsKey(device.address)) {
      throw StateError("already connected to address: ${device.address}");
    }
    final newConnection = await MPOSConnection.toBluetoothDevice(device);
    _connections[device.address] = newConnection;
    _connectionChangeNotifier.notifyChange();

    // cuando el canal se cierre esta conexión ya no es válida y la borramos
    newConnection.messageResponseStream?.listen((data) {}, onDone: () {
      _connections.remove(device.address);
      _connectionChangeNotifier.notifyChange();
    });
  }

  /// Setea la conexión activa para el canal de MPOS mediante su [address]
  void setActiveConnectionByAddress(String address) {
    _activeConnectionAddress = address;
    _connectionChangeNotifier.notifyChange();
  }

  /// Retorna la conexión activa para el canal de MPOS
  ///
  /// NOTA: Esta conexión activa puede ser nula, o puede no ser nula pero no
  /// estar conectada realmente, así que se recomienda checar el estado de
  /// conexión del objeto antes de usarlo
  MPOSConnection? getActiveConnection() {
    return _connections[_activeConnectionAddress];
  }

  /// Verifica si [address] tiene una conexión registrada en este controlador
  bool checkAddressConnection(String address) {
    return _connections.containsKey(address);
  }

  /// Sincroniza la fecha y hora de este dispositivo con el MPOS activo
  ///
  /// La hora sincronizada no es UTC sino que está ajustada a la zona horaria
  /// correcta que tenga configurada este dispositivo, de forma que la hora que
  /// se visualice en el MPOS sea exactamente la misma que en el móvil
  ///
  /// Falla si no hay una conexión de MPOS activa en este controlador
  Future<void> syncDateTime() async {
    var now = DateTime.now();
    now = now.add(now.timeZoneOffset);
    final secondsSinceEpoch = now.millisecondsSinceEpoch ~/ 1000;
    await _channel.invokeMethod("setMPOSDateTime", secondsSinceEpoch);
  }

  /// Muestra un mensaje básico de texto en el display del MPOS
  ///
  /// Este método no hace nada si no hay una conexión activa en este controlador
  /// de forma que se puede llamar sin error cuando no hay MPOS conectado
  Future<void> showMessage(String message) async {
    if (hasActiveConnection) {
      await _channel.invokeMethod("showMessage", message);
    }
  }

  /// Regresa el display del MPOS a su pantalla de inicio
  ///
  /// Este método no hace nada si no hay una conexión activa en este controlador
  /// de forma que se puede llamar sin error cuando no hay MPOS conectado
  Future<void> showHomeScreen() async {
    if (hasActiveConnection) {
      await _channel.invokeMethod("showHomeScreen");
    }
  }

  /// Cierra una conexión bluetooth asociada a la dirección especificada
  /// [address]
  void closeBluetoothConnection(String address) {
    _connections[address]?.close();
  }
}
