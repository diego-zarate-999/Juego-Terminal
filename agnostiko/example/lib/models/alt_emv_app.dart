import 'dart:typed_data';

class AltEmvApp {
  Uint8List? aid;
  Uint8List? kernelId;
  Uint8List? terminalTransactionQualifiers;
  Uint8List? terminalFloorLimit;
  Uint8List? contactlessFloorLimit;

  AltEmvApp({
    this.aid,
    this.kernelId,
    this.terminalTransactionQualifiers,
    this.terminalFloorLimit,
    this.contactlessFloorLimit,
  });
}
