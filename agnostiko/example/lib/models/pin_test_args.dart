import 'package:agnostiko/agnostiko.dart';
import 'dart:typed_data';

class PinTestArgs {
  /// Tipo de tarjeta a probar
  CardType cardType;

  /// Info de llave para encriptar el PIN Online
  SymmetricKey key;

  /// Data en claro de la llave de PIN Online para validación
  Uint8List keyClearData;

  PinTestArgs({
    required this.cardType,
    required this.key,
    required this.keyClearData,
  });
}
