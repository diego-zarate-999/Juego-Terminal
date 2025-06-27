import 'app_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get title => 'Agnostiko - Demo';

  @override
  String get manualEntry => 'Venta Digitada';

  @override
  String get cardTransaction => 'Venta Con Tarjeta';

  @override
  String get otherTransaction => 'Otra Transacción';

  @override
  String get platform => 'Plataforma';

  @override
  String get yes => 'Si';

  @override
  String get no => 'No';

  @override
  String get accept => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get info => 'Info';

  @override
  String get processing => 'Procesando...';

  @override
  String get pinpadEntry => 'Por favor ingrese el PIN en el Pinpad.';

  @override
  String get isoMessageString => 'Texto Mensaje ISO:';

  @override
  String get isoMessageBCD => 'BCD Mensaje ISO:';

  @override
  String get isoMessageFields => 'Campos Mensaje ISO:';

  @override
  String get internalError => 'Error interno.';

  @override
  String get unsupported => 'No soportado.';

  @override
  String get commError => 'Verifique su conexión. Error de comunicación.';

  @override
  String get notImplemented => 'No implementado.';

  @override
  String get sale => 'Venta';

  @override
  String get refund => 'Reembolso';

  @override
  String get voidLabel => 'Reverso';

  @override
  String get voidAccepted => 'Reverso aceptado';

  @override
  String get voidRejected => 'Reverso rechazado';

  @override
  String get saleFailed => 'Falló la venta. La transacción fue revertida';

  @override
  String get refundFailed => 'Falló el reembolso. La transacción fue revertida';

  @override
  String get amount => 'Monto';

  @override
  String get cardNumber => 'Número de Tarjeta';

  @override
  String get expirationDate => 'Fecha de Vencimiento';

  @override
  String get mmyy => 'MMAA';

  @override
  String get deviceWithoutCardReader => 'Este dispositivo no tiene lector de tarjetas.';

  @override
  String get invalidValue => 'Valor inválido.';

  @override
  String get tap => 'Acerque';

  @override
  String get insert => 'Inserte';

  @override
  String get swipe => 'Deslice';

  @override
  String get chipCardUseChip => 'Tarjeta de Chip. Por favor, intente utilizar el chip.';

  @override
  String get chipError => 'Error de chip.';

  @override
  String get selectApp => 'Seleccione una app:';

  @override
  String get confirmCancelTransaction => 'Desea cancelar la transacción?';

  @override
  String get pleaseWait => 'Por favor espere...';

  @override
  String get removeCard => 'Retire la tarjeta.';

  @override
  String get wrongPIN => 'PIN Incorrecto.';

  @override
  String get pinCancelled => 'PIN Cancelado.';

  @override
  String get pinTimeout => 'PIN Timeout.';

  @override
  String get emvTransactionInfo => 'Info de Transacción EMV';

  @override
  String get transaction => 'Transacción';

  @override
  String get approved => 'Aprobada';

  @override
  String get declined => 'Rechazada';

  @override
  String get failed => 'Fallida';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get transactionType => 'Tipo de Transacción';

  @override
  String get cashbackAmount => 'Monto de Cashback';

  @override
  String get appliedCVM => 'CVM Aplicado';

  @override
  String get plaintextPINOffline => 'PIN Offline En Claro';

  @override
  String get encipheredPINOffline => 'PIN Offline Cifrado';

  @override
  String get encipheredPINOnline => 'PIN Online Cifrado';

  @override
  String get plaintextPINOfflineAndSignature => 'PIN Offline En Claro y Firma';

  @override
  String get encipheredPINOfflineAndSignature => 'PIN Offline Cifrado y Firma';

  @override
  String get signature => 'Firma';

  @override
  String get noCVM => 'Sin CVM';

  @override
  String get unknown => 'Desconocido';

  @override
  String get encryptionTest => 'Test de encriptado:';

  @override
  String get encryptionClearOption => 'En claro (sin KEK)';

  @override
  String get encryptionCipherOption => 'Cifrado (con KEK)';

  @override
  String get dataEncryptionOption => 'Encripción de datos (con KEK)';

  @override
  String get loadKEK => 'Cargar KEK';

  @override
  String get loadKEKError => 'Falló la carga de KEK';

  @override
  String get loadKEKSucceed => 'Carga de KEK exitosa';

  @override
  String get loadKeyTest => 'Carga de llaves';

  @override
  String get dataEncryptionTest => 'Encripción de datos';

  @override
  String get dataDecryptionTest => 'Desencripción de datos';

  @override
  String get deleteKeyTest => 'Borrado de llaves';

  @override
  String get loadAESKeyTest => 'Carga de llaves AES';

  @override
  String get aesDataEncryptionTest => 'Encripción AES de datos';

  @override
  String get aesDataDecryptionTest => 'Desencripción AES de datos';

  @override
  String get deleteAESKeyTest => 'Borrado de llaves AES';

  @override
  String get testLog => 'Prueba';

  @override
  String get loadRSAKeyWithAsymKey => 'Carga de llave RSA con AsymKey';

  @override
  String get randomKeyWithRSASet => 'Generación de llave PIN con RSA';

  @override
  String get deleteRandomKeyWithRSASet => 'Borrar llave PIN con RSA';

  @override
  String get failedTest => 'Falló';

  @override
  String get succeedTest => 'Fue exitosa';

  @override
  String get testsFinished => 'Pruebas finalizadas!';

  @override
  String get settings => 'Configuración';

  @override
  String get emvParameters => 'Parámetros EMV';

  @override
  String valueMustBeInRange(String valueName, int minValue, int maxValue) {
    return 'El \'$valueName\' debe estar en el rango $minValue-$maxValue.';
  }

  @override
  String valueMustBeExactLength(String valueName, int length) {
    return 'El valor \'$valueName\' debe tener $length caracteres de longitud.';
  }

  @override
  String get confirmResetTerminalParameters => 'Está seguro que desea resetear los parámetros?';

  @override
  String get tests => 'Pruebas';

  @override
  String get cardReader => 'Lector de Tarjetas';

  @override
  String get waitingForCard => 'Esperando tarjeta...';

  @override
  String get magCardDetected => 'Tarjeta de banda magnética detectada!';

  @override
  String get icCardDetected => 'Tarjeta de chip contacto detectada!';

  @override
  String get rfCardDetected => 'Tarjeta Contactless detectada!';

  @override
  String get cardDetectionTimeout => 'Tiempo de espera agotado!';

  @override
  String get cardDetectionError => 'Error leyendo tarjeta.';

  @override
  String get printer => 'Impresora';

  @override
  String get printing => 'Imprimiendo...';

  @override
  String get printingError => 'Error de Impresión';

  @override
  String get device => 'Dispositivo';

  @override
  String get downloadApp => 'Descargar App';

  @override
  String get downloadingApp => 'Descargando App...';

  @override
  String get appDownloadSuccess => 'App descargada exitosamente!';

  @override
  String get installApp => 'Instalar App';

  @override
  String installingApp(String appFilePath) {
    return 'Instalando \'$appFilePath\'...';
  }

  @override
  String get appInstallSuccess => 'App instalada exitosamente!';

  @override
  String get appInstallerNotExist => 'Error: El archivo de instalación no existe.';

  @override
  String get uninstallApp => 'Desinstalar App';

  @override
  String uninstallingApp(String appPackageName) {
    return 'Desinstalando \'$appPackageName\'...';
  }

  @override
  String get appUninstallSuccess => 'App desinstalada exitosamente!';

  @override
  String get rebootDevice => 'Reiniciar Dispositivo';

  @override
  String get rebootDeviceConfirmation => 'Está seguro que desea reiniciar el dispositivo?';

  @override
  String get deviceInformation => 'Información del Dispositivo';

  @override
  String get deviceBattery => 'Batería:';

  @override
  String get deviceMemory => 'Memoria Ocupada:';

  @override
  String get deviceModel => 'Modelo:';

  @override
  String get datetime => 'Fecha y Hora';

  @override
  String get deviceNetwork => 'Tipo de Conexión:';

  @override
  String get shutdownDevice => 'Apagar Dispositivo';

  @override
  String get shutdownDeviceConfirmation => 'Está seguro que desea apagar el dispositivo?';

  @override
  String get encryption => 'Encriptado';

  @override
  String get cryptography => 'Criptografía';

  @override
  String get cryptographyDES => 'Criptografía DES';

  @override
  String get cryptographyAES => 'Criptografía AES';

  @override
  String get cryptographyLegacy => 'Criptografía antigua';

  @override
  String get encryptionModuleOk => 'El módulo de encriptado está OK.';

  @override
  String get encryptionError => 'Error de encriptado.';

  @override
  String get encryptionDataOk => 'La encripción de datos esta OK.';

  @override
  String get deviceFirmwareVersion => 'Versión de Firmware:';

  @override
  String get deviceInternalStorage => 'Almacenamiento Interno Ocupado:';

  @override
  String get updateFirmware => 'Actualizar Firmware';

  @override
  String get updateFirmwareEnterFullPath => 'Introduzca la ruta completa';

  @override
  String get updatingFirmware => 'Actualizando firmware, el equipo se reiniciará';

  @override
  String get beeper => 'Bíper';

  @override
  String get led => 'LED';

  @override
  String get scanner => 'Scanner';

  @override
  String get scanning => 'Escaneando...';

  @override
  String get scannerContent => 'Código escaneado';

  @override
  String get scannerNullResult => 'Valor no detectado';

  @override
  String get scannerStop => 'El escaneo fue cancelado';

  @override
  String get scannerTimeout => 'Tiempo de espera agotado para el escaneo';

  @override
  String get scannerNotSupported => 'Escaner de hardware no es soportado por este equipo';

  @override
  String get signalStrength => 'Intensidad de la señal';

  @override
  String get printerNotSupported => 'La impresora no es soportada por este equipo';

  @override
  String get printerError => 'Error de impresión';

  @override
  String get printerTestNormalTicket => 'Ticket Normal';

  @override
  String get printerTestLargeTicket => 'Ticket Extra Largo';

  @override
  String get sendCmd => 'Enviar comando';

  @override
  String get mifare => 'MIFARE';

  @override
  String get getVersionCmd => 'Obtener Versión';

  @override
  String get selectAppCmd => 'Seleccionar Aplicación';

  @override
  String get selectAppPiccCmd => 'Seleccionar Aplicación (nivel PICC)';

  @override
  String get resultPart => 'Resultado Parte';

  @override
  String get emv => 'EMV';

  @override
  String get emvModuleOk => '¿Está OK el Módulo EMV?';

  @override
  String get pinOnlineTestOk => '¿Es este el PIN ingresado?';

  @override
  String get selectOption => 'Seleccione una opción:';

  @override
  String get ksnFailed => 'Falló el incremento del KSN';

  @override
  String get fixedKeyTest => 'Prueba de llave fija';

  @override
  String get dukptKeyTest => 'Prueba de llave DUKPT';

  @override
  String get storagePermissionRequired => 'El permiso de almacenamiento debe ser habilitado';

  @override
  String get bluetoothPermissionRequired => 'El permiso de Bluetooth debe ser habilitado';

  @override
  String get keys => 'Llaves';

  @override
  String get initialization => 'Inicialización';

  @override
  String get keyAlreadyExistsConfirmation => 'Ya existe una llave cargada. Está seguro que desea reemplazarla?';

  @override
  String get keyInitialized => 'Inicialización de llaves exitosa!';

  @override
  String get wrongCRC => 'Validación de CRC errónea.';

  @override
  String get failedValidation => 'Validación fallida.';

  @override
  String get serverError => 'Error de servidor.';

  @override
  String get field63Missing => 'Campo 63 no encontrado.';

  @override
  String get eraseKeys => 'Borrar Llaves';

  @override
  String get eraseKeysConfirmation => 'Está seguro que desea borrar las llaves de encriptado?';

  @override
  String get keyMissing => 'Llave no encontrada';

  @override
  String get kcvFailed => 'Falló el chequeo del KCV';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccione un idioma:';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordWrong => 'Contraseña inválida.';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get selectDevice => 'Selecciona un dispositivo:';

  @override
  String get paired => 'Emparejado';

  @override
  String get connecting => 'Conectando...';

  @override
  String get connected => 'Conectado';

  @override
  String get loading => 'Cargando...';

  @override
  String get exit => 'Salir';

  @override
  String get retry => 'Reintentar';

  @override
  String get connectionErrorToken => 'Error de conexión. No se pudo obtener el token';

  @override
  String get serialErrorToken => 'El número serial no puede ser nulo para la obtencion de token';

  @override
  String get generalErrorToken => 'Error. Falló la inicialización de token';

  @override
  String get initError => 'No se pudo inicializar la librería de pagos';

  @override
  String get certificateError => 'El certificado no pudo ser cargado';

  @override
  String get testIcCommand => 'Prueba comando IC';

  @override
  String get icSlotSelect => 'IC command slot';

  @override
  String get icFinancial => 'IC Financiera';

  @override
  String get testIcCommandResp => 'Respuesta del comando IC';

  @override
  String get pinpad => 'Pinpad';

  @override
  String get pinpadError => 'El pinpad no funciona correctamente.';

  @override
  String get pinpadConnectionError => 'No se pudo conectar el pinpad.';

  @override
  String get goBackHome => 'Ir al inicio';

  @override
  String get clearScreen => 'Limpiar pantalla';

  @override
  String get displayText => 'Mostrar texto';

  @override
  String get displayImg => 'Mostrar imagen';

  @override
  String get displayColorImg => 'Mostrar imagen a color';

  @override
  String get pingPinpad => 'Ping a pinpad';

  @override
  String get pinpadTest => 'Prueba Pinpad';

  @override
  String get pinpadHelloWorld => 'Hola mundo!';

  @override
  String get pharosRSAError => 'Error interno de RSA con Pharos';

  @override
  String get pharosKeyError => 'Error interno de inicialización de llaves de Pharos';

  @override
  String get commErrorPharos => 'Error de comunicacion con Pharos';

  @override
  String get sharedPrefsOK => 'Modulo SharedPrefs OK';

  @override
  String get sharedPrefsError => 'Error de SharedPreferences';

  @override
  String get sharedPrefsInit => 'Guardar SharedPreferences';

  @override
  String get sharedPrefsClear => 'Borrar SharedPreferences';

  @override
  String get pinpadDeviceInfo => 'Informacion del Pinpad:';

  @override
  String get masterDeviceInfo => 'Informacion del Master:';
}
