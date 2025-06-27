import 'dart:typed_data';


import 'package:agnostiko/agnostiko.dart';

import '../../cards/src/card_reader.dart';
import 'mifare.dart';

class MifareSelectAppResult{
  final int statusCode;

  MifareSelectAppResult(this.statusCode);

  Uint8List getUint8List(){
    return Uint8List.fromList([statusCode]);
  }
}

MifareSelectAppResult getResultSelectApp(bool isIsoCmd, Uint8List cmdResult){
  if(isIsoCmd){
    return MifareSelectAppResult(cmdResult[1]);

  }else{
    return MifareSelectAppResult(cmdResult[0]);
  }

}

class MifareSelectAppCmd extends MifareCommand {
  final bool isIsoCmd;
  final Uint8List _aid;

  MifareSelectAppCmd(this.isIsoCmd, this._aid): super(Uint8List.fromList([0x5A]), isIsoCmd, mode: MifareCmdMode.Plain);//_sKey

  @override
  Future<MifareSelectAppResult?> performCommand() async {
    Uint8List cmd = Uint8List(0);
    List<int> data = List.empty(growable: true);

    if(_aid.length != 3){
      throw Exception("El aid debe tener una longitud igual a 3");
    }

    data.addAll(_aid);
    cmd = await build(data: Uint8List.fromList(data));

    final cmdResult = await sendCommandRF(cmd);
    final result =  getResultSelectApp(isIsoCmd, cmdResult);

    return result;
  }
}
