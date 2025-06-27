import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:prueba_ag/flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:prueba_ag/flutter_gen/gen_l10n/app_localizations_es.dart';


/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Agnostiko - Demo'**
  String get title;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @cardTransaction.
  ///
  /// In en, this message translates to:
  /// **'Card Transaction'**
  String get cardTransaction;

  /// No description provided for @otherTransaction.
  ///
  /// In en, this message translates to:
  /// **'Other Trans.'**
  String get otherTransaction;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @pinpadEntry.
  ///
  /// In en, this message translates to:
  /// **'Please enter the PIN on the pinpad.'**
  String get pinpadEntry;

  /// No description provided for @isoMessageString.
  ///
  /// In en, this message translates to:
  /// **'ISO Message String:'**
  String get isoMessageString;

  /// No description provided for @isoMessageBCD.
  ///
  /// In en, this message translates to:
  /// **'ISO Message BCD:'**
  String get isoMessageBCD;

  /// No description provided for @isoMessageFields.
  ///
  /// In en, this message translates to:
  /// **'ISO Message Fields:'**
  String get isoMessageFields;

  /// No description provided for @internalError.
  ///
  /// In en, this message translates to:
  /// **'Internal error.'**
  String get internalError;

  /// No description provided for @unsupported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported.'**
  String get unsupported;

  /// No description provided for @commError.
  ///
  /// In en, this message translates to:
  /// **'Check your connection. Communication error.'**
  String get commError;

  /// No description provided for @notImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not implemented.'**
  String get notImplemented;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @voidLabel.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get voidLabel;

  /// No description provided for @voidAccepted.
  ///
  /// In en, this message translates to:
  /// **'Void accepted'**
  String get voidAccepted;

  /// No description provided for @voidRejected.
  ///
  /// In en, this message translates to:
  /// **'Void rejected'**
  String get voidRejected;

  /// No description provided for @saleFailed.
  ///
  /// In en, this message translates to:
  /// **'Sale failed. The transaction was reversed'**
  String get saleFailed;

  /// No description provided for @refundFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund failed. The transaction was reversed'**
  String get refundFailed;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get expirationDate;

  /// No description provided for @mmyy.
  ///
  /// In en, this message translates to:
  /// **'MMYY'**
  String get mmyy;

  /// No description provided for @deviceWithoutCardReader.
  ///
  /// In en, this message translates to:
  /// **'This device doesn\'t have a card reader.'**
  String get deviceWithoutCardReader;

  /// No description provided for @invalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value.'**
  String get invalidValue;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get tap;

  /// No description provided for @insert.
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get insert;

  /// No description provided for @swipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get swipe;

  /// No description provided for @chipCardUseChip.
  ///
  /// In en, this message translates to:
  /// **'Chip card. Please, try to use the contact chip.'**
  String get chipCardUseChip;

  /// No description provided for @chipError.
  ///
  /// In en, this message translates to:
  /// **'Chip error.'**
  String get chipError;

  /// No description provided for @selectApp.
  ///
  /// In en, this message translates to:
  /// **'Select an app:'**
  String get selectApp;

  /// No description provided for @confirmCancelTransaction.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel the transaction?'**
  String get confirmCancelTransaction;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'Remove the card.'**
  String get removeCard;

  /// No description provided for @wrongPIN.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN.'**
  String get wrongPIN;

  /// No description provided for @pinCancelled.
  ///
  /// In en, this message translates to:
  /// **'PIN Cancelled.'**
  String get pinCancelled;

  /// No description provided for @pinTimeout.
  ///
  /// In en, this message translates to:
  /// **'PIN Timeout.'**
  String get pinTimeout;

  /// No description provided for @emvTransactionInfo.
  ///
  /// In en, this message translates to:
  /// **'EMV Transaction Info'**
  String get emvTransactionInfo;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @cashbackAmount.
  ///
  /// In en, this message translates to:
  /// **'Cashback Amount'**
  String get cashbackAmount;

  /// No description provided for @appliedCVM.
  ///
  /// In en, this message translates to:
  /// **'Applied CVM'**
  String get appliedCVM;

  /// No description provided for @plaintextPINOffline.
  ///
  /// In en, this message translates to:
  /// **'Plaintext PIN Offline'**
  String get plaintextPINOffline;

  /// No description provided for @encipheredPINOffline.
  ///
  /// In en, this message translates to:
  /// **'Enciphered PIN Offline'**
  String get encipheredPINOffline;

  /// No description provided for @encipheredPINOnline.
  ///
  /// In en, this message translates to:
  /// **'Enciphered PIN Online'**
  String get encipheredPINOnline;

  /// No description provided for @plaintextPINOfflineAndSignature.
  ///
  /// In en, this message translates to:
  /// **'Plaintext PIN Offline and Signature'**
  String get plaintextPINOfflineAndSignature;

  /// No description provided for @encipheredPINOfflineAndSignature.
  ///
  /// In en, this message translates to:
  /// **'Enciphered PIN Offline and Signature'**
  String get encipheredPINOfflineAndSignature;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @noCVM.
  ///
  /// In en, this message translates to:
  /// **'No CVM'**
  String get noCVM;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @encryptionTest.
  ///
  /// In en, this message translates to:
  /// **'Encryption Test:'**
  String get encryptionTest;

  /// No description provided for @encryptionClearOption.
  ///
  /// In en, this message translates to:
  /// **'Clear (Without KEK)'**
  String get encryptionClearOption;

  /// No description provided for @encryptionCipherOption.
  ///
  /// In en, this message translates to:
  /// **'Cipher (With KEK)'**
  String get encryptionCipherOption;

  /// No description provided for @dataEncryptionOption.
  ///
  /// In en, this message translates to:
  /// **'Data Encryption (With KEK)'**
  String get dataEncryptionOption;

  /// No description provided for @loadKEK.
  ///
  /// In en, this message translates to:
  /// **'Load KEK'**
  String get loadKEK;

  /// No description provided for @loadKEKError.
  ///
  /// In en, this message translates to:
  /// **'KEK load failed'**
  String get loadKEKError;

  /// No description provided for @loadKEKSucceed.
  ///
  /// In en, this message translates to:
  /// **'KEK loaded successfully'**
  String get loadKEKSucceed;

  /// No description provided for @loadKeyTest.
  ///
  /// In en, this message translates to:
  /// **'Load Key'**
  String get loadKeyTest;

  /// No description provided for @dataEncryptionTest.
  ///
  /// In en, this message translates to:
  /// **'Data Encryption'**
  String get dataEncryptionTest;

  /// No description provided for @dataDecryptionTest.
  ///
  /// In en, this message translates to:
  /// **'Data Decryption'**
  String get dataDecryptionTest;

  /// No description provided for @deleteKeyTest.
  ///
  /// In en, this message translates to:
  /// **'Delete Key'**
  String get deleteKeyTest;

  /// No description provided for @loadAESKeyTest.
  ///
  /// In en, this message translates to:
  /// **'Load AES Key'**
  String get loadAESKeyTest;

  /// No description provided for @aesDataEncryptionTest.
  ///
  /// In en, this message translates to:
  /// **'AES Data Encryption'**
  String get aesDataEncryptionTest;

  /// No description provided for @aesDataDecryptionTest.
  ///
  /// In en, this message translates to:
  /// **'AES Data Decryption'**
  String get aesDataDecryptionTest;

  /// No description provided for @deleteAESKeyTest.
  ///
  /// In en, this message translates to:
  /// **'Delete AES Key'**
  String get deleteAESKeyTest;

  /// No description provided for @testLog.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testLog;

  /// No description provided for @loadRSAKeyWithAsymKey.
  ///
  /// In en, this message translates to:
  /// **'Load RSA Key With AsymKey'**
  String get loadRSAKeyWithAsymKey;

  /// No description provided for @randomKeyWithRSASet.
  ///
  /// In en, this message translates to:
  /// **'PIN key generation with RSA'**
  String get randomKeyWithRSASet;

  /// No description provided for @deleteRandomKeyWithRSASet.
  ///
  /// In en, this message translates to:
  /// **'Delete RSA PIN key'**
  String get deleteRandomKeyWithRSASet;

  /// No description provided for @failedTest.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failedTest;

  /// No description provided for @succeedTest.
  ///
  /// In en, this message translates to:
  /// **'Succeed'**
  String get succeedTest;

  /// No description provided for @testsFinished.
  ///
  /// In en, this message translates to:
  /// **'Tests finished!'**
  String get testsFinished;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @emvParameters.
  ///
  /// In en, this message translates to:
  /// **'EMV Parameters'**
  String get emvParameters;

  /// No description provided for @valueMustBeInRange.
  ///
  /// In en, this message translates to:
  /// **'The value \'{valueName}\' must be in range {minValue}-{maxValue}.'**
  String valueMustBeInRange(String valueName, int minValue, int maxValue);

  /// No description provided for @valueMustBeExactLength.
  ///
  /// In en, this message translates to:
  /// **'The value \'{valueName}\' must be exactly {length} characters long.'**
  String valueMustBeExactLength(String valueName, int length);

  /// No description provided for @confirmResetTerminalParameters.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the parameters?'**
  String get confirmResetTerminalParameters;

  /// No description provided for @tests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get tests;

  /// No description provided for @cardReader.
  ///
  /// In en, this message translates to:
  /// **'Card Reader'**
  String get cardReader;

  /// No description provided for @waitingForCard.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Card...'**
  String get waitingForCard;

  /// No description provided for @magCardDetected.
  ///
  /// In en, this message translates to:
  /// **'Magnetic Card detected!'**
  String get magCardDetected;

  /// No description provided for @icCardDetected.
  ///
  /// In en, this message translates to:
  /// **'Contact Chip Card detected!'**
  String get icCardDetected;

  /// No description provided for @rfCardDetected.
  ///
  /// In en, this message translates to:
  /// **'Contactless Chip Card detected!'**
  String get rfCardDetected;

  /// No description provided for @cardDetectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Card detection timeout!'**
  String get cardDetectionTimeout;

  /// No description provided for @cardDetectionError.
  ///
  /// In en, this message translates to:
  /// **'Card detection error.'**
  String get cardDetectionError;

  /// No description provided for @printer.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get printer;

  /// No description provided for @printing.
  ///
  /// In en, this message translates to:
  /// **'Printing...'**
  String get printing;

  /// No description provided for @printingError.
  ///
  /// In en, this message translates to:
  /// **'Printing Error'**
  String get printingError;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @downloadApp.
  ///
  /// In en, this message translates to:
  /// **'Download App'**
  String get downloadApp;

  /// No description provided for @downloadingApp.
  ///
  /// In en, this message translates to:
  /// **'Downloading App...'**
  String get downloadingApp;

  /// No description provided for @appDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'App downloaded successfully!'**
  String get appDownloadSuccess;

  /// No description provided for @installApp.
  ///
  /// In en, this message translates to:
  /// **'Install App'**
  String get installApp;

  /// No description provided for @installingApp.
  ///
  /// In en, this message translates to:
  /// **'Installing \'{appFilePath}\'...'**
  String installingApp(String appFilePath);

  /// No description provided for @appInstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'App installed successfully!'**
  String get appInstallSuccess;

  /// No description provided for @appInstallerNotExist.
  ///
  /// In en, this message translates to:
  /// **'Error: The app installer file does not exist.'**
  String get appInstallerNotExist;

  /// No description provided for @uninstallApp.
  ///
  /// In en, this message translates to:
  /// **'Uninstall App'**
  String get uninstallApp;

  /// No description provided for @uninstallingApp.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling \'{appPackageName}\'...'**
  String uninstallingApp(String appPackageName);

  /// No description provided for @appUninstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'App uninstalled successfully!'**
  String get appUninstallSuccess;

  /// No description provided for @rebootDevice.
  ///
  /// In en, this message translates to:
  /// **'Reboot Device'**
  String get rebootDevice;

  /// No description provided for @rebootDeviceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reboot the device?'**
  String get rebootDeviceConfirmation;

  /// No description provided for @deviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInformation;

  /// No description provided for @deviceBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery:'**
  String get deviceBattery;

  /// No description provided for @deviceMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory usage:'**
  String get deviceMemory;

  /// No description provided for @deviceModel.
  ///
  /// In en, this message translates to:
  /// **'Model:'**
  String get deviceModel;

  /// No description provided for @datetime.
  ///
  /// In en, this message translates to:
  /// **'Datetime'**
  String get datetime;

  /// No description provided for @deviceNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network Type:'**
  String get deviceNetwork;

  /// No description provided for @shutdownDevice.
  ///
  /// In en, this message translates to:
  /// **'Shutdown Device'**
  String get shutdownDevice;

  /// No description provided for @shutdownDeviceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to shutdown the device?'**
  String get shutdownDeviceConfirmation;

  /// No description provided for @encryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get encryption;

  /// No description provided for @cryptography.
  ///
  /// In en, this message translates to:
  /// **'Cryptography'**
  String get cryptography;

  /// No description provided for @cryptographyDES.
  ///
  /// In en, this message translates to:
  /// **'Cryptography DES'**
  String get cryptographyDES;

  /// No description provided for @cryptographyAES.
  ///
  /// In en, this message translates to:
  /// **'Cryptography AES'**
  String get cryptographyAES;

  /// No description provided for @cryptographyLegacy.
  ///
  /// In en, this message translates to:
  /// **'Cryptography Legacy'**
  String get cryptographyLegacy;

  /// No description provided for @encryptionModuleOk.
  ///
  /// In en, this message translates to:
  /// **'Encryption module is OK.'**
  String get encryptionModuleOk;

  /// No description provided for @encryptionError.
  ///
  /// In en, this message translates to:
  /// **'Encryption error.'**
  String get encryptionError;

  /// No description provided for @encryptionDataOk.
  ///
  /// In en, this message translates to:
  /// **'Data encryption is OK.'**
  String get encryptionDataOk;

  /// No description provided for @deviceFirmwareVersion.
  ///
  /// In en, this message translates to:
  /// **'Firmware Version:'**
  String get deviceFirmwareVersion;

  /// No description provided for @deviceInternalStorage.
  ///
  /// In en, this message translates to:
  /// **'Internal Storage Usage:'**
  String get deviceInternalStorage;

  /// No description provided for @updateFirmware.
  ///
  /// In en, this message translates to:
  /// **'Update Firmware'**
  String get updateFirmware;

  /// No description provided for @updateFirmwareEnterFullPath.
  ///
  /// In en, this message translates to:
  /// **'Enter the full path'**
  String get updateFirmwareEnterFullPath;

  /// No description provided for @updatingFirmware.
  ///
  /// In en, this message translates to:
  /// **'Updating firmware, the device will reboot.'**
  String get updatingFirmware;

  /// No description provided for @beeper.
  ///
  /// In en, this message translates to:
  /// **'Beeper'**
  String get beeper;

  /// No description provided for @led.
  ///
  /// In en, this message translates to:
  /// **'LED'**
  String get led;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @scannerContent.
  ///
  /// In en, this message translates to:
  /// **'Scanned code'**
  String get scannerContent;

  /// No description provided for @scannerNullResult.
  ///
  /// In en, this message translates to:
  /// **'Value not detected'**
  String get scannerNullResult;

  /// No description provided for @scannerStop.
  ///
  /// In en, this message translates to:
  /// **'Scan was cancelled'**
  String get scannerStop;

  /// No description provided for @scannerTimeout.
  ///
  /// In en, this message translates to:
  /// **'Scanner timeout'**
  String get scannerTimeout;

  /// No description provided for @scannerNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Hardware scanner not suppoted by device'**
  String get scannerNotSupported;

  /// No description provided for @signalStrength.
  ///
  /// In en, this message translates to:
  /// **'Signal strength'**
  String get signalStrength;

  /// No description provided for @printerNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Printer not suppoted by device'**
  String get printerNotSupported;

  /// No description provided for @printerError.
  ///
  /// In en, this message translates to:
  /// **'Printer error'**
  String get printerError;

  /// No description provided for @printerTestNormalTicket.
  ///
  /// In en, this message translates to:
  /// **'Normal Ticket'**
  String get printerTestNormalTicket;

  /// No description provided for @printerTestLargeTicket.
  ///
  /// In en, this message translates to:
  /// **'Extra Large Ticket'**
  String get printerTestLargeTicket;

  /// No description provided for @sendCmd.
  ///
  /// In en, this message translates to:
  /// **'Send command'**
  String get sendCmd;

  /// No description provided for @mifare.
  ///
  /// In en, this message translates to:
  /// **'MIFARE'**
  String get mifare;

  /// No description provided for @getVersionCmd.
  ///
  /// In en, this message translates to:
  /// **'Get Version'**
  String get getVersionCmd;

  /// No description provided for @selectAppCmd.
  ///
  /// In en, this message translates to:
  /// **'Select Application'**
  String get selectAppCmd;

  /// No description provided for @selectAppPiccCmd.
  ///
  /// In en, this message translates to:
  /// **'Select Application (PICC level)'**
  String get selectAppPiccCmd;

  /// No description provided for @resultPart.
  ///
  /// In en, this message translates to:
  /// **'Result Part'**
  String get resultPart;

  /// No description provided for @emv.
  ///
  /// In en, this message translates to:
  /// **'EMV'**
  String get emv;

  /// No description provided for @emvModuleOk.
  ///
  /// In en, this message translates to:
  /// **'Is the EMV Module OK?'**
  String get emvModuleOk;

  /// No description provided for @pinOnlineTestOk.
  ///
  /// In en, this message translates to:
  /// **'Is this the PIN entered?'**
  String get pinOnlineTestOk;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option:'**
  String get selectOption;

  /// No description provided for @ksnFailed.
  ///
  /// In en, this message translates to:
  /// **'KSN increment failed'**
  String get ksnFailed;

  /// No description provided for @fixedKeyTest.
  ///
  /// In en, this message translates to:
  /// **'Fixed key test'**
  String get fixedKeyTest;

  /// No description provided for @dukptKeyTest.
  ///
  /// In en, this message translates to:
  /// **'DUKPT key test'**
  String get dukptKeyTest;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission should be enabled'**
  String get storagePermissionRequired;

  /// No description provided for @bluetoothPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission should be enabled'**
  String get bluetoothPermissionRequired;

  /// No description provided for @keys.
  ///
  /// In en, this message translates to:
  /// **'Keys'**
  String get keys;

  /// No description provided for @initialization.
  ///
  /// In en, this message translates to:
  /// **'Initialization'**
  String get initialization;

  /// No description provided for @keyAlreadyExistsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Key already exists. Are you sure you want to replace it?'**
  String get keyAlreadyExistsConfirmation;

  /// No description provided for @keyInitialized.
  ///
  /// In en, this message translates to:
  /// **'Succesfull key initialization!'**
  String get keyInitialized;

  /// No description provided for @wrongCRC.
  ///
  /// In en, this message translates to:
  /// **'Wrong CRC.'**
  String get wrongCRC;

  /// No description provided for @failedValidation.
  ///
  /// In en, this message translates to:
  /// **'Failed validation.'**
  String get failedValidation;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error.'**
  String get serverError;

  /// No description provided for @field63Missing.
  ///
  /// In en, this message translates to:
  /// **'Field 63 missing.'**
  String get field63Missing;

  /// No description provided for @eraseKeys.
  ///
  /// In en, this message translates to:
  /// **'Erase Keys'**
  String get eraseKeys;

  /// No description provided for @eraseKeysConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to erase the encryption keys?'**
  String get eraseKeysConfirmation;

  /// No description provided for @keyMissing.
  ///
  /// In en, this message translates to:
  /// **'Key Missing'**
  String get keyMissing;

  /// No description provided for @kcvFailed.
  ///
  /// In en, this message translates to:
  /// **'KCV Check Failed'**
  String get kcvFailed;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select a language:'**
  String get selectLanguage;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong password.'**
  String get passwordWrong;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @selectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select a device:'**
  String get selectDevice;

  /// No description provided for @paired.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get paired;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @connectionErrorToken.
  ///
  /// In en, this message translates to:
  /// **'Connection Error. Could not get the token'**
  String get connectionErrorToken;

  /// No description provided for @serialErrorToken.
  ///
  /// In en, this message translates to:
  /// **'The serial number cannot be null for obtaining token'**
  String get serialErrorToken;

  /// No description provided for @generalErrorToken.
  ///
  /// In en, this message translates to:
  /// **'Error. Token initialization failed'**
  String get generalErrorToken;

  /// No description provided for @initError.
  ///
  /// In en, this message translates to:
  /// **'The payment plugin cannot be initialized'**
  String get initError;

  /// No description provided for @certificateError.
  ///
  /// In en, this message translates to:
  /// **'The certificate could not be loaded'**
  String get certificateError;

  /// No description provided for @testIcCommand.
  ///
  /// In en, this message translates to:
  /// **'Test IC command'**
  String get testIcCommand;

  /// No description provided for @icSlotSelect.
  ///
  /// In en, this message translates to:
  /// **'IC command slot'**
  String get icSlotSelect;

  /// No description provided for @icFinancial.
  ///
  /// In en, this message translates to:
  /// **'Financial IC'**
  String get icFinancial;

  /// No description provided for @testIcCommandResp.
  ///
  /// In en, this message translates to:
  /// **'IC command response'**
  String get testIcCommandResp;

  /// No description provided for @pinpad.
  ///
  /// In en, this message translates to:
  /// **'Pinpad'**
  String get pinpad;

  /// No description provided for @pinpadError.
  ///
  /// In en, this message translates to:
  /// **'Pinpad isn\'t working correctly.'**
  String get pinpadError;

  /// No description provided for @pinpadConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to Pinpad.'**
  String get pinpadConnectionError;

  /// No description provided for @goBackHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goBackHome;

  /// No description provided for @clearScreen.
  ///
  /// In en, this message translates to:
  /// **'Clear screen'**
  String get clearScreen;

  /// No description provided for @displayText.
  ///
  /// In en, this message translates to:
  /// **'Display text'**
  String get displayText;

  /// No description provided for @displayImg.
  ///
  /// In en, this message translates to:
  /// **'Display image'**
  String get displayImg;

  /// No description provided for @displayColorImg.
  ///
  /// In en, this message translates to:
  /// **'Display Color image'**
  String get displayColorImg;

  /// No description provided for @pingPinpad.
  ///
  /// In en, this message translates to:
  /// **'Ping pinpad'**
  String get pingPinpad;

  /// No description provided for @pinpadTest.
  ///
  /// In en, this message translates to:
  /// **'Pinpad Test'**
  String get pinpadTest;

  /// No description provided for @pinpadHelloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get pinpadHelloWorld;

  /// No description provided for @pharosRSAError.
  ///
  /// In en, this message translates to:
  /// **'Pharos RSA key internal error'**
  String get pharosRSAError;

  /// No description provided for @pharosKeyError.
  ///
  /// In en, this message translates to:
  /// **'Pharos key initialization internal error'**
  String get pharosKeyError;

  /// No description provided for @commErrorPharos.
  ///
  /// In en, this message translates to:
  /// **'Communication with Pharos Failed'**
  String get commErrorPharos;

  /// No description provided for @sharedPrefsOK.
  ///
  /// In en, this message translates to:
  /// **'SharedPrefs module OK'**
  String get sharedPrefsOK;

  /// No description provided for @sharedPrefsError.
  ///
  /// In en, this message translates to:
  /// **'SharedPreferences error'**
  String get sharedPrefsError;

  /// No description provided for @sharedPrefsInit.
  ///
  /// In en, this message translates to:
  /// **'SharedPreferences save test'**
  String get sharedPrefsInit;

  /// No description provided for @sharedPrefsClear.
  ///
  /// In en, this message translates to:
  /// **'SharedPreferences clear test'**
  String get sharedPrefsClear;

  /// No description provided for @pinpadDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Pinpad device info:'**
  String get pinpadDeviceInfo;

  /// No description provided for @masterDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Master device info:'**
  String get masterDeviceInfo;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
