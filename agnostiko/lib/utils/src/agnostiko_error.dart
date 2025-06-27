import "package:flutter/services.dart";

class AgnostikoError {
  static const String TAG = "AgnostikoException";

  /// Sin error
  static const int OK = 0;

  /// Error general
  static const int FAIL = -1;

  /// Funcionalidad no soportada
  static const int UNSUPPORTED = -2;

  // Errores de módulo crypto

  /// Error básico de módulo crypto
  static const int CRYPTO_ERROR = -300;

  /// Error de validación del KCV suministrado
  static const int KCV_FAILED = -301;

  /// Llave no encontrada
  static const int KEY_MISSING = -302;

  /// KEK no soportado en marca
  static const int KEK_UNSUPPORTED = -303;

  /// La longitud de KEK es menor a la longitud de la llave que protege
  static const int KEK_STRENGTH = -304;

  /// El terminal no soporta el modo de cifrado para la operación solicitada
  static const int UNSUPPORTED_CIPHER_MODE = -305;

  /// El método invocado no soporta el tipo de llave especificado
  static const int UNSUPPORTED_KEY_TYPE = -306;

  /// Se intentó cargar una llave DUKPT sin el KSN
  static const int KSN_MISSING = -307;

  /// Se invocó modo de cifrado CBC sin el vector de inicialización
  static const int IV_MISSING = -308;

  /// Se parametrizó una longitud incorrecta para derivar una llave DUKPT
  static const int WRONG_DERIVATE_LENGTH = -309;

  // Errores de pinpad

  /// Error genérico de pinpad
  static const int PINPAD_ERROR = -400;

  /// Error de conexión con el pinpad
  static const int PINPAD_CONNECTION_ERROR = -401;

  /// Error de comunicación con el pinpad
  static const int PINPAD_COMUNICATION_ERROR = -402;
}

extension IsAgnostikoException on PlatformException {
  /// Indica si es un caso de excepción mapeado por el SDK Agnostiko
  ///
  /// Si es 'true', se puede comparar el [details] de esta excepción con los
  /// códigos de error de [AgnostikoError] para determinar el error específico
  bool isAgnostikoException() {
    return code == AgnostikoError.TAG;
  }
}
