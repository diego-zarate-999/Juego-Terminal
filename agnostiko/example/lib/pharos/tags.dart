import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';

class Tags{
  Uint8List? tag9A;
  Uint8List? tagC0;
  Uint8List? tag9F26;
  Uint8List? tag9B;
  Uint8List? tag4F;
  Uint8List? tag9F27;
  //Uint8List? tagC2;


  Tags({
    this.tag9A,
    this.tagC0,
    this.tag9F26,
    this.tag9B,
    this.tag4F,
    this.tag9F27,
    //this.tagC2,
  });

  Map<String, dynamic> toJson() {
    return {
      '9A': tag9A?.toHexStr().toUpperCase(),
      'C0': tagC0?.toHexStr().toUpperCase(),
      '9F26': tag9F26?.toHexStr().toUpperCase(),
      '9B': tag9B?.toHexStr().toUpperCase(),
      '4F': tag4F?.toHexStr().toUpperCase(),
      '9F27': tag9F27?.toHexStr().toUpperCase(),
      //'C2': tagC2?.toHexStr(),

    };
  }


}

