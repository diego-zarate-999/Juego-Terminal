import 'dart:typed_data';

enum MifareCmdMode{Full, Mac, Plain}

enum ResponseCodes {
  OperationOk(0X00),
  AditionalFrame(0XAF),
  CommandAborted(0XCA),
  LengthError(0X7E),
  PermissionDenied(0X9D),
  ApplicationNotFound(0XA0),
  MemoryError(0XEE);

  final int value;
  const ResponseCodes(this.value);

}

abstract class MifareCommand<T>{
  final MifareCmdMode mode;
  final bool isIsoCmd;
  final Uint8List _commandHeader;

  MifareCommand(this._commandHeader, this.isIsoCmd,
      {this.mode = MifareCmdMode.Plain});

  Future<Uint8List> build({Uint8List? data}) async {
    if(!isIsoCmd){
      switch (mode) {
        case MifareCmdMode.Plain:
          return _buildPlainCommand(data: data);
        default: throw Exception("Modo de comando Mifare no implementado");
      }
    }else{
      switch (mode) {
        case MifareCmdMode.Plain:
          return _buildPlainIsoCommand(data: data);
        default: throw Exception("Modo de comando Mifare no implementado");
      }
    }

  }

  Future<Uint8List> requestAF() async {
    Uint8List cmd = Uint8List(0);
    if(isIsoCmd){
      cmd =  Uint8List.fromList([0x90, ResponseCodes.AditionalFrame.value, 0x00, 0x00, 0x00]);
    }else{
      cmd =  Uint8List.fromList([ResponseCodes.AditionalFrame.value]);
    }
    return cmd;

  }

  Uint8List _buildPlainCommand({Uint8List? data}) {
    List<int> cmd = List.empty(growable: true);
    cmd.addAll(_commandHeader);
    if(data!= null){
      cmd.addAll(data);
    }
    return Uint8List.fromList(cmd);
  }

  // TODO Revisar si haría falta un padeo y un toHexBytes despues del toRadixString
  Uint8List _buildPlainIsoCommand({Uint8List? data}) {
    List<int> cmd = List.empty(growable: true);
    cmd.addAll(Uint8List.fromList([0x90]));
    cmd.addAll(_commandHeader);
    cmd.addAll([0x00, 0x00]);
    if(data!= null){
      cmd.addAll([data.length]);
      cmd.addAll(data);
    }
    cmd.addAll(Uint8List.fromList([0x00]));
    return Uint8List.fromList(cmd);
  }


  Future<T?> performCommand();
}
