import 'dart:typed_data';

/// Representa un bit de configuración del estándar EMV.
///
/// Dicho bit, formaría parte de los bytes de un valor de configuración de
/// kernel como por ejemplo: 'Terminal Capabilities'.
class EmvConfigBit {
  /// Nombre del bit de configuración en la especificación EMV.
  final String name;

  /// Indica si el bit es RFU (Reservado para Uso Futuro).
  final bool rfu;

  /// El estatus del bit, true = 1 y false = 0.
  bool value;

  EmvConfigBit._({required this.value, required this.name, required this.rfu});

  /// Crea un bit de configuración seteado en [value] (true = 1 y false = 0).
  factory EmvConfigBit.withValue(String name, bool value) {
    return EmvConfigBit._(value: value, name: name, rfu: false);
  }

  /// Crea un bit de configuración seteado en 1 (value = true).
  factory EmvConfigBit.on(String name) {
    return EmvConfigBit.withValue(name, true);
  }

  /// Crea un bit de configuración seteado en 0 (value = false).
  factory EmvConfigBit.off(String name) {
    return EmvConfigBit.withValue(name, false);
  }

  /// Crea un bit de configuración seteado como RFU (Reservado para Uso Futuro).
  factory EmvConfigBit.rfu() {
    return EmvConfigBit._(value: false, name: "RFU", rfu: true);
  }

  /// Retorna 1 o 0 dependiendo del estatus del bit.
  int toInt() {
    return value == true ? 1 : 0;
  }

  /// Retorna '1' o '0' dependiendo del estatus del bit.
  String toBinaryStr() {
    return value == true ? '1' : '0';
  }

  /// Setea el bit a partir de [str]. '1' es **true** y otro valor es **false**.
  void loadValueFromStr(String str) {
    value = str == '1' ? true : false;
  }
}

/// Representa un byte de configuración del estándar EMV.
///
/// Dicho byte, formaría parte de un valor de configuración de kernel como por
/// ejemplo: 'Terminal Capabilities'.
class EmvConfigByte {
  /// Nombre del byte de configuración en la especificación EMV.
  final String name;

  final EmvConfigBit bit8;
  final EmvConfigBit bit7;
  final EmvConfigBit bit6;
  final EmvConfigBit bit5;
  final EmvConfigBit bit4;
  final EmvConfigBit bit3;
  final EmvConfigBit bit2;
  final EmvConfigBit bit1;

  EmvConfigByte({
    required this.name,
    required this.bit8,
    required this.bit7,
    required this.bit6,
    required this.bit5,
    required this.bit4,
    required this.bit3,
    required this.bit2,
    required this.bit1,
  });

  int toInt() {
    int val = 0;

    if (bit8.value == true) {
      val += 128;
    }
    if (bit7.value == true) {
      val += 64;
    }
    if (bit6.value == true) {
      val += 32;
    }
    if (bit5.value == true) {
      val += 16;
    }
    if (bit4.value == true) {
      val += 8;
    }
    if (bit3.value == true) {
      val += 4;
    }
    if (bit2.value == true) {
      val += 2;
    }
    if (bit1.value == true) {
      val += 1;
    }

    return val;
  }

  String toBinaryStr() {
    return bit8.toBinaryStr() +
        bit7.toBinaryStr() +
        bit6.toBinaryStr() +
        bit5.toBinaryStr() +
        bit4.toBinaryStr() +
        bit3.toBinaryStr() +
        bit2.toBinaryStr() +
        bit1.toBinaryStr();
  }

  String toHexStr() {
    return toInt().toRadixString(16).padLeft(2, '0');
  }

  /// Carga el estatus de los bits a partir de una cadena binaria de 8 bits.
  void loadFromBinaryStr(String binaryStr) {
    if (binaryStr.length < 8) return;

    final split = binaryStr.split('');
    bit8.loadValueFromStr(split[0]);
    bit7.loadValueFromStr(split[1]);
    bit6.loadValueFromStr(split[2]);
    bit5.loadValueFromStr(split[3]);
    bit4.loadValueFromStr(split[4]);
    bit3.loadValueFromStr(split[5]);
    bit2.loadValueFromStr(split[6]);
    bit1.loadValueFromStr(split[7]);
  }
}

/// Bitmap de configuración del estándar EMV.
///
/// Esta definición sirve para manejar datos configurables mediante bits como
/// por ejemplo: 'Terminal Capabilities'.
class EmvConfigBitmap {
  /// Nombre del bitmap de configuración en la especificación EMV.
  final String name;
  final List<EmvConfigByte> _bytes;

  EmvConfigBitmap(this.name, this._bytes);

  List<EmvConfigByte> get bytes {
    return _bytes;
  }

  /// Obtiene el byte mediante su número incremental del 1 en adelante.
  ///
  /// Esto se utiliza para obtener el byte de acuerdo a su número en el estándar
  /// (donde se númeran del 1 en adelante) en vez de por su índice basado en 0
  /// del array interno.
  EmvConfigByte? byte(int byteNum) {
    if (byteNum < 1) return null;

    return _bytes[byteNum - 1];
  }

  Uint8List toBytes() {
    final list = bytes.map((byte) => byte.toInt()).toList();

    return Uint8List.fromList(list);
  }

  /// Carga el valor de los bits definidos en este bitmap a partir de bytes.
  ///
  /// El número de [bytes] debe ser igual a los definidos en este bitmap.
  void loadFromBytes(Uint8List bytes) {
    if (bytes.length != _bytes.length) {
      throw StateError("Para cargar el bitmap: $name la lista de bytes debe " +
          "tener la longitud adecuada: ${_bytes.length}.");
    }

    int i = 0;
    while (i < _bytes.length) {
      // creamos la cadena binaria
      final binStr = bytes[i].toRadixString(2).padLeft(8, '0');
      // y la utilizamos para cargar los valores en el byte correspondiente
      _bytes[i].loadFromBinaryStr(binStr);

      i++;
    }
  }
}

/// Retorna un bitmap configurado para 'Terminal Capabilities'.
EmvConfigBitmap getTerminalCapabilitiesBitmap() {
  return EmvConfigBitmap(
    "Terminal Capabilities",
    [
      EmvConfigByte(
        name: "Card Data Input Capability",
        bit8: EmvConfigBit.off("Manual Key Entry"),
        bit7: EmvConfigBit.off("Magnetic Stripe"),
        bit6: EmvConfigBit.off("IC with Contacts"),
        bit5: EmvConfigBit.rfu(),
        bit4: EmvConfigBit.rfu(),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
      EmvConfigByte(
        name: "CVM Capability",
        bit8: EmvConfigBit.off("Plaintext PIN for ICC verification"),
        bit7: EmvConfigBit.off("Enciphered PIN for online verification"),
        bit6: EmvConfigBit.off("Signature (paper)"),
        bit5: EmvConfigBit.off("Enciphered PIN for offline verification"),
        bit4: EmvConfigBit.off("No CVM Required"),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
      EmvConfigByte(
        name: "Security Capability",
        bit8: EmvConfigBit.off("SDA"),
        bit7: EmvConfigBit.off("DDA"),
        bit6: EmvConfigBit.off("Card Capture"),
        bit5: EmvConfigBit.rfu(),
        bit4: EmvConfigBit.off("CDA"),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
    ],
  );
}

/// Retorna un bitmap configurado para 'Additional Terminal Capabilities'.
EmvConfigBitmap getAdditionalTerminalCapabilitiesBitmap() {
  return EmvConfigBitmap(
    "Additional Terminal Capabilities",
    [
      EmvConfigByte(
        name: "Transaction Type Capability",
        bit8: EmvConfigBit.off("Cash"),
        bit7: EmvConfigBit.off("Goods"),
        bit6: EmvConfigBit.off("Services"),
        bit5: EmvConfigBit.off("Cashback"),
        bit4: EmvConfigBit.off("Inquiry"),
        bit3: EmvConfigBit.off("Transfer"),
        bit2: EmvConfigBit.off("Payment"),
        bit1: EmvConfigBit.off("Administrative"),
      ),
      EmvConfigByte(
        name: "Transaction Type Capability",
        bit8: EmvConfigBit.off("Cash Deposit"),
        bit7: EmvConfigBit.rfu(),
        bit6: EmvConfigBit.rfu(),
        bit5: EmvConfigBit.rfu(),
        bit4: EmvConfigBit.rfu(),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
      EmvConfigByte(
        name: "Terminal Data Input Capability",
        bit8: EmvConfigBit.off("Numeric Keys"),
        bit7: EmvConfigBit.off("Alphabetic and special characters keys"),
        bit6: EmvConfigBit.off("Command keys"),
        bit5: EmvConfigBit.off("Function keys"),
        bit4: EmvConfigBit.rfu(),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
      EmvConfigByte(
        name: "Terminal Data Output Capability",
        bit8: EmvConfigBit.off("Print, attendant"),
        bit7: EmvConfigBit.off("Print, cardholder"),
        bit6: EmvConfigBit.off("Display, attendant"),
        bit5: EmvConfigBit.off("Display, cardholder"),
        bit4: EmvConfigBit.rfu(),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.off("Code table 10"),
        bit1: EmvConfigBit.off("Code table 9"),
      ),
      EmvConfigByte(
        name: "Terminal Data Output Capability",
        bit8: EmvConfigBit.off("Code table 8"),
        bit7: EmvConfigBit.off("Code table 7"),
        bit6: EmvConfigBit.off("Code table 6"),
        bit5: EmvConfigBit.off("Code table 5"),
        bit4: EmvConfigBit.off("Code table 4"),
        bit3: EmvConfigBit.off("Code table 3"),
        bit2: EmvConfigBit.off("Code table 2"),
        bit1: EmvConfigBit.off("Code table 1"),
      ),
    ],
  );
}

/// Retorna un bitmap configurado para 'Terminal Action Code - Denial'.
EmvConfigBitmap getTacDenialBitmap() {
  return _getTacBitmap("Denial");
}

/// Retorna un bitmap configurado para 'Terminal Action Code - Online'.
EmvConfigBitmap getTacOnlineBitmap() {
  return _getTacBitmap("Online");
}

/// Retorna un bitmap configurado para 'Terminal Action Code - Default'.
EmvConfigBitmap getTacDefaultBitmap() {
  return _getTacBitmap("Default");
}

final _tvrBits = [
  EmvConfigByte(
    name: "Byte 1",
    bit8: EmvConfigBit.off("Offline data authentication was not performed"),
    bit7: EmvConfigBit.off("SDA failed"),
    bit6: EmvConfigBit.off("ICC data missing"),
    bit5: EmvConfigBit.off("Card appears on terminal exception file"),
    bit4: EmvConfigBit.off("DDA failed"),
    bit3: EmvConfigBit.off("CDA failed"),
    bit2: EmvConfigBit.rfu(),
    bit1: EmvConfigBit.rfu(),
  ),
  EmvConfigByte(
    name: "Byte 2",
    bit8: EmvConfigBit.off(
      "ICC and terminal have different application versions",
    ),
    bit7: EmvConfigBit.off("Expired Application"),
    bit6: EmvConfigBit.off("Application not yet effective"),
    bit5: EmvConfigBit.off(
      "Requested service not allowed for card product",
    ),
    bit4: EmvConfigBit.off("New card"),
    bit3: EmvConfigBit.rfu(),
    bit2: EmvConfigBit.rfu(),
    bit1: EmvConfigBit.rfu(),
  ),
  EmvConfigByte(
    name: "Byte 3",
    bit8: EmvConfigBit.off("Cardholder verification was not successful"),
    bit7: EmvConfigBit.off("Unrecognized CVM"),
    bit6: EmvConfigBit.off("PIN Try Limit exceeded"),
    bit5: EmvConfigBit.off(
      "PIN entry required and PIN pad not present or not working",
    ),
    bit4: EmvConfigBit.off(
      "PIN entry required, PIN pad present, but PIN was not entered",
    ),
    bit3: EmvConfigBit.off("Online PIN entered"),
    bit2: EmvConfigBit.rfu(),
    bit1: EmvConfigBit.rfu(),
  ),
  EmvConfigByte(
    name: "Byte 4",
    bit8: EmvConfigBit.off("Transaction exceeds floor limit"),
    bit7: EmvConfigBit.off("Lower consecutive offline limit exceeded"),
    bit6: EmvConfigBit.off("Upper consecutive offline limit exceeded"),
    bit5: EmvConfigBit.off(
      "Transaction selected randomly for online processing",
    ),
    bit4: EmvConfigBit.off("Merchant forced transaction online"),
    bit3: EmvConfigBit.rfu(),
    bit2: EmvConfigBit.rfu(),
    bit1: EmvConfigBit.rfu(),
  ),
  EmvConfigByte(
    name: "Byte 5",
    bit8: EmvConfigBit.off("Default TDOL used"),
    bit7: EmvConfigBit.off("Issuer authentication failed"),
    bit6: EmvConfigBit.off(
      "Script processing failed before final GENERATE AC",
    ),
    bit5: EmvConfigBit.off(
      "Script processing failed after final GENERATE AC",
    ),
    bit4: EmvConfigBit.rfu(),
    bit3: EmvConfigBit.rfu(),
    bit2: EmvConfigBit.rfu(),
    bit1: EmvConfigBit.rfu(),
  ),
];

EmvConfigBitmap _getTacBitmap(String tacName) {
  return EmvConfigBitmap("Terminal Action Code - $tacName", _tvrBits);
}

/// Retorna un bitmap configurado para 'Terminal Verification Results'.
EmvConfigBitmap getTvrBitmap() {
  return EmvConfigBitmap("Terminal Verification Results", _tvrBits);
}

/// Retorna un bitmap configurado para 'Application Interchange Profile'.
EmvConfigBitmap getAipBitmap() {
  return EmvConfigBitmap(
    "Application Interchange Profile",
    [
      EmvConfigByte(
        name: "AIP Byte 1",
        bit8: EmvConfigBit.rfu(),
        bit7: EmvConfigBit.off("SDA supported"),
        bit6: EmvConfigBit.off("DDA supported"),
        bit5: EmvConfigBit.off("Cardholder verification is supported"),
        bit4: EmvConfigBit.off("Terminal risk management is to be performed"),
        bit3: EmvConfigBit.off("Issuer authentication is supported"),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.off("CDA supported"),
      ),
      EmvConfigByte(
        name: "AIP Byte 2",
        bit8: EmvConfigBit.rfu(),
        bit7: EmvConfigBit.rfu(),
        bit6: EmvConfigBit.rfu(),
        bit5: EmvConfigBit.rfu(),
        bit4: EmvConfigBit.rfu(),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
    ],
  );
}

/// Retorna un bitmap configurado para 'Transaction Status Information'.
EmvConfigBitmap getTsiBitmap() {
  return EmvConfigBitmap(
    "Transaction Status Information",
    [
      EmvConfigByte(
        name: "TSI Byte 1",
        bit8: EmvConfigBit.off("Offline data authentication was performed"),
        bit7: EmvConfigBit.off("Cardholder verification was performed"),
        bit6: EmvConfigBit.off("Card risk management was performed"),
        bit5: EmvConfigBit.off("Issuer authentication was performed"),
        bit4: EmvConfigBit.off("Terminal risk management was performed"),
        bit3: EmvConfigBit.off("Script processing was performed"),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
      EmvConfigByte(
        name: "TSI Byte 2",
        bit8: EmvConfigBit.rfu(),
        bit7: EmvConfigBit.rfu(),
        bit6: EmvConfigBit.rfu(),
        bit5: EmvConfigBit.rfu(),
        bit4: EmvConfigBit.rfu(),
        bit3: EmvConfigBit.rfu(),
        bit2: EmvConfigBit.rfu(),
        bit1: EmvConfigBit.rfu(),
      ),
    ],
  );
}
