import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';

import '../../cards/src/card_reader.dart';
import 'mifare.dart';

class MifareGetVersionResult{
  final MifareGetVersionResultPart1? result1;
  final MifareGetVersionResultPart2? result2;
  final MifareGetVersionResultPart3? result3;

  MifareGetVersionResult(this.result1, this.result2, this.result3);
}

class MifareGetVersionResultPart1{
  final Uint8List vendorID;
  final Uint8List hwType;
  final Uint8List hwSubType;
  final Uint8List hwMajorVersion;
  final Uint8List hwMinorVersion;
  final Uint8List hwStorageSize;
  final Uint8List hwProtocol;

  MifareGetVersionResultPart1(
      this.vendorID,
      this.hwType,
      this.hwSubType,
      this.hwMajorVersion,
      this.hwMinorVersion,
      this.hwStorageSize,
      this.hwProtocol);

  Uint8List getUint8List(){
    List<int> result = List.empty(growable: true);
    result.addAll(vendorID);
    result.addAll(hwType);
    result.addAll(hwSubType);
    result.addAll(hwMajorVersion);
    result.addAll(hwMinorVersion);
    result.addAll(hwStorageSize);
    result.addAll(hwProtocol);
    return Uint8List.fromList(result);
  }
}


class MifareGetVersionResultPart2{
  final Uint8List vendorID;
  final Uint8List swType;
  final Uint8List swSubType;
  final Uint8List swMajorVersion;
  final Uint8List swMinorVersion;
  final Uint8List swStorageSize;
  final Uint8List swProtocol;

  MifareGetVersionResultPart2(
      this.vendorID,
      this.swType,
      this.swSubType,
      this.swMajorVersion,
      this.swMinorVersion,
      this.swStorageSize,
      this.swProtocol);

  Uint8List getUint8List(){
    List<int> result = List.empty(growable: true);
    result.addAll(vendorID);
    result.addAll(swType);
    result.addAll(swSubType);
    result.addAll(swMajorVersion);
    result.addAll(swMinorVersion);
    result.addAll(swStorageSize);
    result.addAll(swProtocol);
    return Uint8List.fromList(result);
  }
}

class MifareGetVersionResultPart3{
  final Uint8List uid;
  final Uint8List batchNo;
  final Uint8List cwProd;
  final Uint8List yearProd;

  MifareGetVersionResultPart3(
      this.uid,
      this.batchNo,
      this.cwProd,
      this.yearProd);

  Uint8List getUint8List(){
    List<int> result = List.empty(growable: true);
    result.addAll(uid);
    result.addAll(batchNo);
    result.addAll(cwProd);
    result.addAll(yearProd);
    return Uint8List.fromList(result);
  }
}

MifareGetVersionResultPart1 getVersionResult1(bool isIsoCmd, Uint8List cmdResultPart){
  if(isIsoCmd){
    int offset = 1;
    final vendorId = cmdResultPart.elementAt(offset-1);
    offset++;
    final type = cmdResultPart.elementAt(offset-1);
    offset++;
    final subType = cmdResultPart.elementAt(offset-1);
    offset++;
    final majorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final minorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final storageSize = cmdResultPart.elementAt(offset-1);
    offset++;
    final protocol = cmdResultPart.elementAt(offset-1);

    final result1 = MifareGetVersionResultPart1(
        Uint8List.fromList([vendorId]),
        Uint8List.fromList([type]),
        Uint8List.fromList([subType]),
        Uint8List.fromList([majorVersion]),
        Uint8List.fromList([minorVersion]),
        Uint8List.fromList([storageSize]),
        Uint8List.fromList([protocol]));

    return result1;
  }else{
    int offset = 2;
    final vendorId = cmdResultPart.elementAt(offset-1);
    offset++;
    final type = cmdResultPart.elementAt(offset-1);
    offset++;
    final subType = cmdResultPart.elementAt(offset-1);
    offset++;
    final majorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final minorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final storageSize = cmdResultPart.elementAt(offset-1);
    offset++;
    final protocol = cmdResultPart.elementAt(offset-1);

    final result1 = MifareGetVersionResultPart1(
        Uint8List.fromList([vendorId]),
        Uint8List.fromList([type]),
        Uint8List.fromList([subType]),
        Uint8List.fromList([majorVersion]),
        Uint8List.fromList([minorVersion]),
        Uint8List.fromList([storageSize]),
        Uint8List.fromList([protocol]));

    return result1;
  }

}

MifareGetVersionResultPart2 getVersionResult2(bool isIsoCmd, Uint8List cmdResultPart){
  if(isIsoCmd){
    int offset = 1;
    final vendorId = cmdResultPart.elementAt(offset-1);
    offset++;
    final type = cmdResultPart.elementAt(offset-1);
    offset++;
    final subType = cmdResultPart.elementAt(offset-1);
    offset++;
    final majorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final minorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final storageSize = cmdResultPart.elementAt(offset-1);
    offset++;
    final protocol = cmdResultPart.elementAt(offset-1);

    final result2 = MifareGetVersionResultPart2(
        Uint8List.fromList([vendorId]),
        Uint8List.fromList([type]),
        Uint8List.fromList([subType]),
        Uint8List.fromList([majorVersion]),
        Uint8List.fromList([minorVersion]),
        Uint8List.fromList([storageSize]),
        Uint8List.fromList([protocol]));

    return result2;
  }else{
    int offset = 2;
    final vendorId = cmdResultPart.elementAt(offset-1);
    offset++;
    final type = cmdResultPart.elementAt(offset-1);
    offset++;
    final subType = cmdResultPart.elementAt(offset-1);
    offset++;
    final majorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final minorVersion = cmdResultPart.elementAt(offset-1);
    offset++;
    final storageSize = cmdResultPart.elementAt(offset-1);
    offset++;
    final protocol = cmdResultPart.elementAt(offset-1);

    final result = MifareGetVersionResultPart2(
        Uint8List.fromList([vendorId]),
        Uint8List.fromList([type]),
        Uint8List.fromList([subType]),
        Uint8List.fromList([majorVersion]),
        Uint8List.fromList([minorVersion]),
        Uint8List.fromList([storageSize]),
        Uint8List.fromList([protocol]));

    return result;
  }

}

MifareGetVersionResultPart3 getVersionResult3(bool isIsoCmd, Uint8List cmdResultPart){
  if(isIsoCmd){
    int offset = 1;
    final uid = cmdResultPart.sublist(offset - 1, offset + 6);
    offset+=7;
    final batchNo = cmdResultPart.sublist(offset-1,offset + 4);
    offset+=5;
    final cwProd = cmdResultPart.elementAt(offset-1);
    offset++;
    final yearProd = cmdResultPart.elementAt(offset-1);
    final result = MifareGetVersionResultPart3(
      uid,
      batchNo,
      Uint8List.fromList([cwProd]),
      Uint8List.fromList([yearProd]),
    );

    return result;

  }else{
    int offset = 2;
    final uid = cmdResultPart.sublist(offset - 1, offset + 6);
    offset+=7;
    final batchNo = cmdResultPart.sublist(offset-1,offset + 4);
    offset+=5;
    final cwProd = cmdResultPart.elementAt(offset-1);
    offset++;
    final yearProd = cmdResultPart.elementAt(offset-1);
    final result = MifareGetVersionResultPart3(
      uid,
      batchNo,
      Uint8List.fromList([cwProd]),
      Uint8List.fromList([yearProd]),
    );

    return result;
  }

}


class MifareGetVersionCmd extends MifareCommand {
  final bool isIsoCmd;

  MifareGetVersionCmd(this.isIsoCmd): super(Uint8List.fromList([0x60]), isIsoCmd, mode: MifareCmdMode.Plain);//_sKey


  @override
  Future<MifareGetVersionResult?> performCommand() async {
    Uint8List cmd = Uint8List(0);
    MifareGetVersionResultPart1? resultPart1;
    MifareGetVersionResultPart2? resultPart2;
    MifareGetVersionResultPart3? resultPart3;

    cmd = await build();
    final cmdResultPart1 = await sendCommandRF(cmd);

    if(isIsoCmd){
      final status1 = validateStatusCodeAF(cmdResultPart1);
      if(!status1){
        throw Exception("El status obtenido como resultado no corresponde al AF esperado.");
      }
      if(cmdResultPart1.length == 9){
        resultPart1 =  getVersionResult1(isIsoCmd, cmdResultPart1);
      }else{
        throw Exception("La longitud del resultado obtenido no es válida");
      }
      cmd = await requestAF();
      final cmdResultPart2 = await sendCommandRF(cmd);
      final status2 = validateStatusCodeAF(cmdResultPart2);
      if(!status2){
        throw Exception("El status obtenido como resultado no corresponde al AF esperado.");
      }
      if(cmdResultPart2.length == 9){
        resultPart2 =  getVersionResult2(isIsoCmd, cmdResultPart2);
      }else{
        throw Exception("La longitud del resultado obtenido no es válida");
      }
      cmd = await requestAF();
      final cmdResultPart3 = await sendCommandRF(cmd);
      final status3 = validateStatusCodeOk(cmdResultPart3);
      if(!status3){
        throw Exception("El status obtenido como resultado no corresponde al 00 esperado.");
      }
      if(cmdResultPart3.length == 16){
        resultPart3 =  getVersionResult3(isIsoCmd, cmdResultPart3);
      }else{
        throw Exception("La longitud del resultado obtenido no es válida");
      }

    }else{
      final status1 = validateStatusCodeAF(cmdResultPart1);
      if(!status1){
        throw Exception("El status obtenido como resultado no corresponde al AF esperado.");
      }
      if(cmdResultPart1.length == 8){
        resultPart1 =  getVersionResult1(isIsoCmd, cmdResultPart1);
      }else{
        throw Exception("La longitud del resultado obtenido no es válida");
      }
      cmd = await requestAF();
      final cmdResultPart2 = await sendCommandRF(cmd);
      final status2 = validateStatusCodeAF(cmdResultPart2);
      if(!status2){
        throw Exception("El status obtenido como resultado no corresponde al AF esperado.");
      }
      if(cmdResultPart2.length == 8){
        resultPart2 =  getVersionResult2(isIsoCmd, cmdResultPart2);
      }else{
        throw Exception("La longitud del resultado obtenido no es válida");
      }
      cmd = await requestAF();
      final cmdResultPart3 = await sendCommandRF(cmd);
      final status3 = validateStatusCodeOk(cmdResultPart3);
      if(!status3){
        throw Exception("El status obtenido como resultado no corresponde al 00 esperado.");
      }
      if(cmdResultPart3.length == 15){
        resultPart3 =  getVersionResult3(isIsoCmd, cmdResultPart3);
      }else{
        throw Exception("La longitud del resultado obtenido no es válida");
      }
    }

    final completeResult = MifareGetVersionResult(resultPart1, resultPart2, resultPart3);
    return completeResult;

  }

  int getStatusCode(Uint8List cmdResultPart){
    if(isIsoCmd){
      return cmdResultPart.last;
    }else{
      return cmdResultPart.first;
    }
  }

  bool validateStatusCodeAF(Uint8List cmdResultPart){
    if(isIsoCmd){
      if(cmdResultPart.last == ResponseCodes.AditionalFrame.value){
        return true;
      }else{
        return false;
      }
    }else{
      if(cmdResultPart.first == ResponseCodes.AditionalFrame.value){
        return true;
      }else{
        return false;
      }
    }
  }

  bool validateStatusCodeOk(Uint8List cmdResultPart){
    if(isIsoCmd){
      if(cmdResultPart.last == ResponseCodes.OperationOk.value){
        return true;
      }else{
        return false;
      }
    }else{
      if(cmdResultPart.first == ResponseCodes.OperationOk.value){
        return true;
      }else{
        return false;
      }
    }
  }


}
