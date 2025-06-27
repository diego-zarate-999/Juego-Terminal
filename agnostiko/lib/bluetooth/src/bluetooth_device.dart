/// Datos de dispositivo bluetooth emparejado y posiblemente conectado
class BluetoothDevice {
  /// Etiqueta de nombre del dispositivo
  final String? name;

  /// Dirección del dispositivo (MAC o ID, depende de la plataforma)
  final String address;

  /// Indica si el dispositivo está conectado actualmente a través de bluetooth
  final bool isConnected;

  const BluetoothDevice({
    this.name,
    required this.address,
    this.isConnected = false,
  });

  factory BluetoothDevice.fromJson(Map<String, dynamic> data) {
    return BluetoothDevice(
      name: data["name"],
      address: data["address"],
      isConnected: data["isConnected"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "isConnected": isConnected,
    };
  }

  @override
  String toString() =>
      "BluetoothDevice{name: $name, address: $address, isConnected: $isConnected}";
}
