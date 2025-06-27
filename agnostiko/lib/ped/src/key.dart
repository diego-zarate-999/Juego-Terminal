import "dart:typed_data";

enum KeyType {
  DES,
  AES,
}
enum AsymKeyType{
  RSA,
  ECC,
}

/// Llave para encripción
abstract class IKey {
  /// Identificador númerico de la llave en el módulo seguro
  final int index;

  /// Valor en bytes de la llave
  final Uint8List? data;

  IKey({ required this.index, this.data});

  Map<String, dynamic> toJson();
}

/// Llave para algoritmos de encripción simétrica
class SymmetricKey extends IKey {
  static const className = "SymmetricKey";

  /// Tipo de llave
  final KeyType type;


  /// KCV (Key Check Value)
  ///
  /// Permite verificar la integridad de la llave a la hora de cargarla
  final Uint8List? kcv;

  SymmetricKey({
    required super.index,
    super.data,
    required this.type,
    this.kcv,
  }) {
    final length = data?.length ?? 0;
    if ((length % 8) != 0) {
      throw StateError("key length must be a multiple of 8");
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "className": className,
      "type": type.index,
      "index": index,
      "data": data,
      "kcv": kcv,
    };
  }
}

/// Llave para esquema de derivación DUKPT
class DUKPTKey extends SymmetricKey {
  static const className = "DUKPTKey";

  /// KSN (Key Serial Number). Identificador para contador de llaves derivadas
  final Uint8List? ksn;

  /// Longitud en bytes de la llave a derivar (aplica solo para AES DUKPT)
  final int? derivateKeyLen;

  DUKPTKey({
    required super.type,
    required super.index,
    super.data,
    this.ksn,
    this.derivateKeyLen,
    super.kcv,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "className": className,
      "type": type.index,
      "index": index,
      "data": data,
      "ksn": ksn,
      "derivateKeyLen": derivateKeyLen,
      "kcv": kcv,
    };
  }
}

/// Llave para algoritmos de encripción simétrica
class AsymmetricKey extends IKey {
  static const className = "AsymmetricKey";

  final AsymKeyType type;

  AsymmetricKey({
    super.data,
    required super.index,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      "className": className,
      "type": type.index,
      "index": index,
      "data": data,
    };
  }
}