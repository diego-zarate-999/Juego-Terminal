import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Agnostiko - Demo';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get cardTransaction => 'Card Transaction';

  @override
  String get otherTransaction => 'Other Trans.';

  @override
  String get platform => 'Platform';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get accept => 'Accept';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get info => 'Info';

  @override
  String get processing => 'Processing...';

  @override
  String get pinpadEntry => 'Please enter the PIN on the pinpad.';

  @override
  String get isoMessageString => 'ISO Message String:';

  @override
  String get isoMessageBCD => 'ISO Message BCD:';

  @override
  String get isoMessageFields => 'ISO Message Fields:';

  @override
  String get internalError => 'Internal error.';

  @override
  String get unsupported => 'Unsupported.';

  @override
  String get commError => 'Check your connection. Communication error.';

  @override
  String get notImplemented => 'Not implemented.';

  @override
  String get sale => 'Sale';

  @override
  String get refund => 'Refund';

  @override
  String get voidLabel => 'Void';

  @override
  String get voidAccepted => 'Void accepted';

  @override
  String get voidRejected => 'Void rejected';

  @override
  String get saleFailed => 'Sale failed. The transaction was reversed';

  @override
  String get refundFailed => 'Refund failed. The transaction was reversed';

  @override
  String get amount => 'Amount';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expirationDate => 'Expiration Date';

  @override
  String get mmyy => 'MMYY';

  @override
  String get deviceWithoutCardReader => 'This device doesn\'t have a card reader.';

  @override
  String get invalidValue => 'Invalid value.';

  @override
  String get tap => 'Tap';

  @override
  String get insert => 'Insert';

  @override
  String get swipe => 'Swipe';

  @override
  String get chipCardUseChip => 'Chip card. Please, try to use the contact chip.';

  @override
  String get chipError => 'Chip error.';

  @override
  String get selectApp => 'Select an app:';

  @override
  String get confirmCancelTransaction => 'Do you want to cancel the transaction?';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get removeCard => 'Remove the card.';

  @override
  String get wrongPIN => 'Wrong PIN.';

  @override
  String get pinCancelled => 'PIN Cancelled.';

  @override
  String get pinTimeout => 'PIN Timeout.';

  @override
  String get emvTransactionInfo => 'EMV Transaction Info';

  @override
  String get transaction => 'Transaction';

  @override
  String get approved => 'Approved';

  @override
  String get declined => 'Declined';

  @override
  String get failed => 'Failed';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get cashbackAmount => 'Cashback Amount';

  @override
  String get appliedCVM => 'Applied CVM';

  @override
  String get plaintextPINOffline => 'Plaintext PIN Offline';

  @override
  String get encipheredPINOffline => 'Enciphered PIN Offline';

  @override
  String get encipheredPINOnline => 'Enciphered PIN Online';

  @override
  String get plaintextPINOfflineAndSignature => 'Plaintext PIN Offline and Signature';

  @override
  String get encipheredPINOfflineAndSignature => 'Enciphered PIN Offline and Signature';

  @override
  String get signature => 'Signature';

  @override
  String get noCVM => 'No CVM';

  @override
  String get unknown => 'Unknown';

  @override
  String get encryptionTest => 'Encryption Test:';

  @override
  String get encryptionClearOption => 'Clear (Without KEK)';

  @override
  String get encryptionCipherOption => 'Cipher (With KEK)';

  @override
  String get dataEncryptionOption => 'Data Encryption (With KEK)';

  @override
  String get loadKEK => 'Load KEK';

  @override
  String get loadKEKError => 'KEK load failed';

  @override
  String get loadKEKSucceed => 'KEK loaded successfully';

  @override
  String get loadKeyTest => 'Load Key';

  @override
  String get dataEncryptionTest => 'Data Encryption';

  @override
  String get dataDecryptionTest => 'Data Decryption';

  @override
  String get deleteKeyTest => 'Delete Key';

  @override
  String get loadAESKeyTest => 'Load AES Key';

  @override
  String get aesDataEncryptionTest => 'AES Data Encryption';

  @override
  String get aesDataDecryptionTest => 'AES Data Decryption';

  @override
  String get deleteAESKeyTest => 'Delete AES Key';

  @override
  String get testLog => 'Test';

  @override
  String get loadRSAKeyWithAsymKey => 'Load RSA Key With AsymKey';

  @override
  String get randomKeyWithRSASet => 'PIN key generation with RSA';

  @override
  String get deleteRandomKeyWithRSASet => 'Delete RSA PIN key';

  @override
  String get failedTest => 'Failed';

  @override
  String get succeedTest => 'Succeed';

  @override
  String get testsFinished => 'Tests finished!';

  @override
  String get settings => 'Settings';

  @override
  String get emvParameters => 'EMV Parameters';

  @override
  String valueMustBeInRange(String valueName, int minValue, int maxValue) {
    return 'The value \'$valueName\' must be in range $minValue-$maxValue.';
  }

  @override
  String valueMustBeExactLength(String valueName, int length) {
    return 'The value \'$valueName\' must be exactly $length characters long.';
  }

  @override
  String get confirmResetTerminalParameters => 'Are you sure you want to reset the parameters?';

  @override
  String get tests => 'Tests';

  @override
  String get cardReader => 'Card Reader';

  @override
  String get waitingForCard => 'Waiting for Card...';

  @override
  String get magCardDetected => 'Magnetic Card detected!';

  @override
  String get icCardDetected => 'Contact Chip Card detected!';

  @override
  String get rfCardDetected => 'Contactless Chip Card detected!';

  @override
  String get cardDetectionTimeout => 'Card detection timeout!';

  @override
  String get cardDetectionError => 'Card detection error.';

  @override
  String get printer => 'Printer';

  @override
  String get printing => 'Printing...';

  @override
  String get printingError => 'Printing Error';

  @override
  String get device => 'Device';

  @override
  String get downloadApp => 'Download App';

  @override
  String get downloadingApp => 'Downloading App...';

  @override
  String get appDownloadSuccess => 'App downloaded successfully!';

  @override
  String get installApp => 'Install App';

  @override
  String installingApp(String appFilePath) {
    return 'Installing \'$appFilePath\'...';
  }

  @override
  String get appInstallSuccess => 'App installed successfully!';

  @override
  String get appInstallerNotExist => 'Error: The app installer file does not exist.';

  @override
  String get uninstallApp => 'Uninstall App';

  @override
  String uninstallingApp(String appPackageName) {
    return 'Uninstalling \'$appPackageName\'...';
  }

  @override
  String get appUninstallSuccess => 'App uninstalled successfully!';

  @override
  String get rebootDevice => 'Reboot Device';

  @override
  String get rebootDeviceConfirmation => 'Are you sure you want to reboot the device?';

  @override
  String get deviceInformation => 'Device Information';

  @override
  String get deviceBattery => 'Battery:';

  @override
  String get deviceMemory => 'Memory usage:';

  @override
  String get deviceModel => 'Model:';

  @override
  String get datetime => 'Datetime';

  @override
  String get deviceNetwork => 'Network Type:';

  @override
  String get shutdownDevice => 'Shutdown Device';

  @override
  String get shutdownDeviceConfirmation => 'Are you sure you want to shutdown the device?';

  @override
  String get encryption => 'Encryption';

  @override
  String get cryptography => 'Cryptography';

  @override
  String get cryptographyDES => 'Cryptography DES';

  @override
  String get cryptographyAES => 'Cryptography AES';

  @override
  String get cryptographyLegacy => 'Cryptography Legacy';

  @override
  String get encryptionModuleOk => 'Encryption module is OK.';

  @override
  String get encryptionError => 'Encryption error.';

  @override
  String get encryptionDataOk => 'Data encryption is OK.';

  @override
  String get deviceFirmwareVersion => 'Firmware Version:';

  @override
  String get deviceInternalStorage => 'Internal Storage Usage:';

  @override
  String get updateFirmware => 'Update Firmware';

  @override
  String get updateFirmwareEnterFullPath => 'Enter the full path';

  @override
  String get updatingFirmware => 'Updating firmware, the device will reboot.';

  @override
  String get beeper => 'Beeper';

  @override
  String get led => 'LED';

  @override
  String get scanner => 'Scanner';

  @override
  String get scanning => 'Scanning...';

  @override
  String get scannerContent => 'Scanned code';

  @override
  String get scannerNullResult => 'Value not detected';

  @override
  String get scannerStop => 'Scan was cancelled';

  @override
  String get scannerTimeout => 'Scanner timeout';

  @override
  String get scannerNotSupported => 'Hardware scanner not suppoted by device';

  @override
  String get signalStrength => 'Signal strength';

  @override
  String get printerNotSupported => 'Printer not suppoted by device';

  @override
  String get printerError => 'Printer error';

  @override
  String get printerTestNormalTicket => 'Normal Ticket';

  @override
  String get printerTestLargeTicket => 'Extra Large Ticket';

  @override
  String get sendCmd => 'Send command';

  @override
  String get mifare => 'MIFARE';

  @override
  String get getVersionCmd => 'Get Version';

  @override
  String get selectAppCmd => 'Select Application';

  @override
  String get selectAppPiccCmd => 'Select Application (PICC level)';

  @override
  String get resultPart => 'Result Part';

  @override
  String get emv => 'EMV';

  @override
  String get emvModuleOk => 'Is the EMV Module OK?';

  @override
  String get pinOnlineTestOk => 'Is this the PIN entered?';

  @override
  String get selectOption => 'Select an option:';

  @override
  String get ksnFailed => 'KSN increment failed';

  @override
  String get fixedKeyTest => 'Fixed key test';

  @override
  String get dukptKeyTest => 'DUKPT key test';

  @override
  String get storagePermissionRequired => 'Storage permission should be enabled';

  @override
  String get bluetoothPermissionRequired => 'Bluetooth permission should be enabled';

  @override
  String get keys => 'Keys';

  @override
  String get initialization => 'Initialization';

  @override
  String get keyAlreadyExistsConfirmation => 'Key already exists. Are you sure you want to replace it?';

  @override
  String get keyInitialized => 'Succesfull key initialization!';

  @override
  String get wrongCRC => 'Wrong CRC.';

  @override
  String get failedValidation => 'Failed validation.';

  @override
  String get serverError => 'Server Error.';

  @override
  String get field63Missing => 'Field 63 missing.';

  @override
  String get eraseKeys => 'Erase Keys';

  @override
  String get eraseKeysConfirmation => 'Are you sure you want to erase the encryption keys?';

  @override
  String get keyMissing => 'Key Missing';

  @override
  String get kcvFailed => 'KCV Check Failed';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select a language:';

  @override
  String get password => 'Password';

  @override
  String get passwordWrong => 'Wrong password.';

  @override
  String get changePassword => 'Change Password';

  @override
  String get selectDevice => 'Select a device:';

  @override
  String get paired => 'Paired';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connected => 'Connected';

  @override
  String get loading => 'Loading...';

  @override
  String get exit => 'Exit';

  @override
  String get retry => 'Retry';

  @override
  String get connectionErrorToken => 'Connection Error. Could not get the token';

  @override
  String get serialErrorToken => 'The serial number cannot be null for obtaining token';

  @override
  String get generalErrorToken => 'Error. Token initialization failed';

  @override
  String get initError => 'The payment plugin cannot be initialized';

  @override
  String get certificateError => 'The certificate could not be loaded';

  @override
  String get testIcCommand => 'Test IC command';

  @override
  String get icSlotSelect => 'IC command slot';

  @override
  String get icFinancial => 'Financial IC';

  @override
  String get testIcCommandResp => 'IC command response';

  @override
  String get pinpad => 'Pinpad';

  @override
  String get pinpadError => 'Pinpad isn\'t working correctly.';

  @override
  String get pinpadConnectionError => 'Couldn\'t connect to Pinpad.';

  @override
  String get goBackHome => 'Go home';

  @override
  String get clearScreen => 'Clear screen';

  @override
  String get displayText => 'Display text';

  @override
  String get displayImg => 'Display image';

  @override
  String get displayColorImg => 'Display Color image';

  @override
  String get pingPinpad => 'Ping pinpad';

  @override
  String get pinpadTest => 'Pinpad Test';

  @override
  String get pinpadHelloWorld => 'Hello World!';

  @override
  String get pharosRSAError => 'Pharos RSA key internal error';

  @override
  String get pharosKeyError => 'Pharos key initialization internal error';

  @override
  String get commErrorPharos => 'Communication with Pharos Failed';

  @override
  String get sharedPrefsOK => 'SharedPrefs module OK';

  @override
  String get sharedPrefsError => 'SharedPreferences error';

  @override
  String get sharedPrefsInit => 'SharedPreferences save test';

  @override
  String get sharedPrefsClear => 'SharedPreferences clear test';

  @override
  String get pinpadDeviceInfo => 'Pinpad device info:';

  @override
  String get masterDeviceInfo => 'Master device info:';
}
