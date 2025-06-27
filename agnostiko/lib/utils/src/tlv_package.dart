import "dart:typed_data";

import 'package:agnostiko/agnostiko.dart';

import "../../utils/src/codecs.dart";

class TlvTag {
  final int tag;
  final Uint8List value;

  const TlvTag(this.tag, this.value);

  /// Retorna la lista de bytes que representa la data del TLvTag.
  Uint8List pack() {
    List<int> intsList = List.empty(growable: true);
    if (tag <= 0xff) {
      intsList.add(tag);
    } else {
      Uint8List tagBytes = intToUint8List(tag);
      intsList.addAll(tagBytes);
    }

    Uint8List lenBytes = intToBerTlvLen(value.length);
    intsList.addAll(lenBytes);

    intsList.addAll(value);
    return Uint8List.fromList(intsList);
  }

  /// Retorna el tamaño en bytes del TLvTag.
  int get size{
    final tlvPack = pack();
    return tlvPack.length;
  }

  /// Parsea un objeto TlvTag.
  factory TlvTag.unpack(Uint8List bytes) {
      List<int> tagIdBytes = List.empty(growable: true);
      List<int> lenBytes = List.empty(growable: true);
      List<int> realLenBytes = List.empty(growable: true);
      List<int> valueBytes = List.empty(growable: true);

      var tagIdFinished = false;
      var lenBytesRemaining = 1;
      var valueBytesRemaining = 0;

      for(var b in bytes) {
        if(!tagIdFinished) {
          tagIdBytes.add(b);
          // Si los 5 bits finales del byte están ON, significa que todavía
          // continúa el TAG ID en el siguiente byte
          if(b & 0x1F != 0x1F) tagIdFinished = true;
        } else if(lenBytesRemaining > 0) {
          lenBytes.add(b);
          if(b & 0x80 == 0x80) {
            // si el primer bit del byte 1 está ON, la longitud de los bytes de
            // longitud está codificada en el resto de bits
            lenBytesRemaining = b & 127;
          } else {
            realLenBytes.add(b);
            lenBytesRemaining -= 1;
          }
          if(lenBytesRemaining == 0) {
            valueBytesRemaining = int.parse(Uint8List.fromList(realLenBytes).toHexStr(), radix: 16);
          }
        } else if(valueBytesRemaining > 0) {
          valueBytes.add(b);
          valueBytesRemaining -= 1;
        } else {
          break;
        }
      }
      return TlvTag(int.parse(Uint8List.fromList(tagIdBytes).toHexStr(), radix: 16), Uint8List.fromList(valueBytes));
    }
}

/// Colección de tags EMV en formato BER-TLV.
class TlvPackage {
  final _elements = List<TlvTag>.empty(growable: true);

  TlvPackage({List<TlvTag>? elements}){
    if(elements != null){
      this._elements.addAll(elements);
    }
  }

  /// Retorna el elemento en el [index] indicado dentro de la lista.
  TlvTag? getAt(int index){
    if(index <= (_elements.length-1)){
      return _elements[index];
    }
    return null;
  }

  /// Retorna el primer elemento de la lista que coincide con [tag].
  TlvTag? get(int tag){
    for(var el in _elements){
      if(el.tag == tag){
        return el;
      }
    }
    return null;
  }

  /// Retorna el índice que corresponda con el valor del [tag].
  ///
  /// Se puede pasar el valor de un offset [start]. Si este no es suministrado,
  /// por defecto se retorna el primer valor en el que exista coincidencia.
  int? indexOf(int tag, [int start = 0]){
    int? index;
    for(var el in _elements){
      if(el.tag == tag){
        index = _elements.indexOf(el, start);
      }
    }
    return index;
  }

  /// Agrega un nuevo TlvTag a la lista.
  void add(int tag, Uint8List value) {
    _elements.add(TlvTag(tag, value));
  }

  /// Elimina el elemento correspondiente al [index] indicado de la lista.
  void removeAt(int index){
    _elements.removeAt(index);
  }

  /// Elimina el primer elemento de la lista que coincide con [tag].
  void remove(int tag){
    TlvTag? tlvTag;
    for(var el in _elements){
      if(el.tag == tag){
        tlvTag = el;
      }
    }
    _elements.remove(tlvTag);
  }

  /// Remplaza un elemento de la lista correspondiente al [index].
  void replaceAt(int index, int tag, Uint8List value){
    _elements[index] = TlvTag(tag, value);
  }

  /// Limpia los elementos de la lista.
  void clear(){
    _elements.clear();
  }

  /// Retorna la lista de bytes que representan la data TLV.
  Uint8List pack() {
    List<int> intsList = List.empty(growable: true);

    for (final el in _elements) {
      final tlvTag = TlvTag(el.tag, el.value);
      final tlvTagPack = tlvTag.pack();
      intsList.addAll(tlvTagPack);
    }

    return Uint8List.fromList(intsList);
  }

  /// Parsea un objeto TlvPackage.
  factory TlvPackage.unpack(Uint8List bytes){
    Uint8List tlvPackagePack = bytes;
    final tlvUnpack = List<TlvTag>.empty(growable: true);
    while(tlvPackagePack.length > 0){
      final tlvTag = TlvTag.unpack(tlvPackagePack);
      tlvUnpack.add(tlvTag);
      final offset = tlvTag.size;
      tlvPackagePack = tlvPackagePack.sublist(offset);
    }

   return TlvPackage(elements: tlvUnpack);
  }
}
