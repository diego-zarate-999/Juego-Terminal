import 'dart:typed_data';

import 'package:agnostiko/agnostiko.dart';

/// Configuración del módulo para transacciones EMV.
///
/// Para dispositivos POS, los métodos de este módulo deben llamarse antes de
/// cada transacción EMV para asegurar una correcta inicialización de parámetros
/// independientemente de la marca.
///
/// Para implementaciones Pinpad, la carga de parámetros se puede llevar a cabo
/// una sola vez al iniciar la aplicación (no es necesario repetir antes de
/// cada transacción), y de hecho es la forma recomendada ya que por lo general
/// la transmisión de estos datos suele ser bastante lenta hacia estos
/// dispositivos.
///
/// Básicamente, para una correcta carga de parámetros EMV, se deberá llamar
/// primeramente [initKernel] y posteriormente, [addApp] y [addCAPK] para
/// inicializar y cargar correctamente los parámetros. Para dispositivos POS,
/// se debe llevar a cabo esa secuencia de llamados previa a cada transacción,
/// para Pinpad solo es necesario repetir cada vez que se inicia la app.
class EmvModule {
  static const channel = const HybridMethodChannel('agnostiko/EmvModule');

  EmvModule._();

  /// Instancia única (**singleton**) del módulo EMV.
  static final EmvModule instance = EmvModule._();

  /// Inicializa el kernel EMV con los [TerminalParameters] correspondientes.
  ///
  /// Debe llamarse antes de cada transacción EMV y antes de cualquier otro
  /// método asociado a la operación del módulo.
  ///
  /// Tras llamar a esta función, los parámetros de AID y CAPK deberán ser
  /// cargados mediante [addApp] y [addCAPK].
  Future<void> initKernel(TerminalParameters terminalParameters) async {
    await channel.invokeMethod('initKernel', terminalParameters.toJson());
  }

  /// Agrega una aplicación EMV para uso del terminal a través del Kernel.
  ///
  /// Este proceso de carga de apps EMV con su AID debe repetirse antes de cada
  /// transacción para garantizar el funcionamiento independiente de la marca.
  Future<void> addApp(EmvApp app) async {
    await channel.invokeMethod('addApp', app.toJson());
  }

  /// Agrega una llave pública (CAPK) para uso del Kernel.
  ///
  /// Este proceso de carga de llaves CAPK debe repetirse antes de cada
  /// transacción para garantizar el funcionamiento independiente de la marca.
  ///
  /// Lanza [CAPKChecksumException] si falla la validación de Checksum.
  Future<void> addCAPK(CAPK capk) async {
    assertCAPKChecksum(capk);
    await channel.invokeMethod('addCAPK', capk.toJson());
  }

  /// Obtiene desde el Kernel el valor de [tag].
  Future<Uint8List?> getTagValue(int tag) async {
    final response = await channel.invokeMethod('getTagValue', tag);
    return response as Uint8List?;
  }

  /// Obtiene el valor de un tag EMV encriptado con llave DUKPT y algoritmo 3DES
  ///
  /// Este método permite obtener directamente el valor encriptado sin manejar
  /// la data en claro lo cual es especialmente necesario para seguridad en mPOS
  Future<DUKPTResult?> getDUKPTEncryptedTagValue(
    int tag,
    int keyIndex,
    CipherMode cipherMode, [
    Uint8List? iv,
  ]) async {
    final result = await channel.invokeMethod('getDUKPTEncryptedTagValue', {
      "tag": tag,
      "keyIndex": keyIndex,
      "cipherMode": cipherMode.index,
      "iv": iv,
    });
    if (result != null) {
      return DUKPTResult.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  /// Retorna el valor de PAN enmascarado desde el Kernel EMV.
  ///
  /// Se obtiene a partir del tag 5A o 57 (si hay alguno disponible).
  ///
  /// El valor enmascarado tiene visible solo los 6 primeros y los 4 últimos
  /// dígitos del valor original. Ej: '541333******4111'. Esto es válido de
  /// acuerdo al requerimiento 3.3 de PCI DSS.
  Future<String?> getMaskPAN() async {
    final result = await channel.invokeMethod('getMaskPAN');
    return result as String?;
  }

  /// Retorna un TLV con los valores de los tags solicitados [tagsList].
  ///
  /// Nota: si el valor del tag es nulo, la longitud del mismo en el formato TLV
  /// es 0.
  Future<Uint8List> getTLV(List<int> tagsList) async {
    final tlvPackage = TlvPackage();
    for (var tag in tagsList) {
      var value = await getTagValue(tag);
      if (value == null) {
        value = Uint8List(0);
      }
      tlvPackage.add(tag, value);
    }
    return tlvPackage.pack();
  }

  /// Método EXPERIMENTAL que setea en el Kernel el valor de [tag].
  ///
  /// ADVERTENCIA: método EXPERIMENTAL. No utilizar
  @Deprecated(
      'Este método no es estable. Es preferible setear los valores a través de la carga de parámetros')
  Future<void> setTagValue(int tag, Uint8List value) async {
    await channel.invokeMethod('setTagValue', {
      "tag": tag,
      "value": value,
    });
  }
}
