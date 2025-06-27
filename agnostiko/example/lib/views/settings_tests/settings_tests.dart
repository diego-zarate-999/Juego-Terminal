import 'dart:async';

import 'package:agnostiko_example/dialogs/list_selection_dialog.dart';
import 'package:agnostiko_example/dialogs/map_selection_dialog.dart';
import 'package:agnostiko_example/dialogs/ic_command_dialog.dart';
import 'package:agnostiko_example/dialogs/mdb_test_dialog.dart';
import 'package:agnostiko_example/dialogs/serialport_test_dialog.dart';
import 'package:agnostiko_example/dialogs/shared_preferences_test_dialog.dart';
import 'package:agnostiko_example/views/cryptography/cryptography_legacy_test.dart';
import 'package:agnostiko_example/views/emv_test/emv_card_input.dart';
import 'package:agnostiko_example/views/settings_printer/settings_printer.dart';
import 'package:agnostiko_example/views/emv_test/emv_test.dart';
import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dialogs/card_reader_dialog.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../dialogs/card_indicator_dialog.dart';
import '../../dialogs/log_dialog.dart';
import '../../dialogs/selection_dialog.dart';
import '../../models/transaction_args.dart';
import '../../utils/emv.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../cryptography/cryptography_des_test.dart';
import '../cryptography/cryptography_aes_test.dart';
import '../pin_online/pin_online_aes_test.dart';
import '../pin_online/pin_online_banorte_test.dart';
import '../pin_online/pin_online_des_test.dart';
import '../settings_device/settings_device.dart';
import '../settings_mifare/settings_mifare.dart';
import '../settings_pinpad/settings_pinpad.dart';

class SettingsTestsView extends StatefulWidget {
  static String route = "/settings/tests";

  @override
  _SettingsTestsViewState createState() => _SettingsTestsViewState();
}

class _SettingsTestsViewState extends State<SettingsTestsView> {
  bool _hasCardReader = false;
  bool _hasPrinter = false;
  bool _hasMDB = false;
  bool _isMe60 = false;
  int testsPage = 0;
  bool _isPinpad = false;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      final deviceName = await getModel();
      final platformInfo = await getPlatformInfo();
      final deviceType = await getDeviceType();
      setState(() {
        _hasCardReader = platformInfo.hasCardReader;
        _hasPrinter = platformInfo.hasPrinter;
        _hasMDB = platformInfo.hasMDB;
        if (deviceName == "ME60") {
          _isMe60 = true;
        }
        _isPinpad = deviceType == DeviceType.PINPAD ? true : false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list1 = [
      ListTile(
        enabled: _hasCardReader,
        enableFeedback: true,
        leading: const Icon(Icons.credit_card),
        title: Text("1. ${getLocalizations(context).cardReader}"),
        onTap: _onTapCardReader,
      ),
      ListTile(
        enabled: _hasPrinter,
        enableFeedback: true,
        leading: const Icon(Icons.print),
        title: Text("2. ${getLocalizations(context).printer}"),
        onTap: () => Navigator.pushNamed(context, SettingsPrinterView.route),
      ),
      ListTile(
        enableFeedback: true,
        leading: const Icon(Icons.smartphone),
        title: Text("3. ${getLocalizations(context).device}"),
        onTap: () {
          Navigator.pushNamed(context, SettingsDeviceView.route);
        },
      ),
      // Se debe cambiar para el nuevo manejo de test de crypto en Linux
      ListTile(
        enableFeedback: true,
        leading: const Icon(Icons.lock),
        title: Text("4. ${getLocalizations(context).cryptography}"),
        onTap: _cryptographyOptions,
      ),
    ];

    List<Widget> list2 = [
      ListTile(
        enableFeedback: true,
        leading: const Icon(Icons.contactless),
        title: Text("1. ${getLocalizations(context).mifare}"),
        onTap: () => Navigator.pushNamed(context, SettingsMifareView.route),
      ),
      ListTile(
        enableFeedback: true,
        leading: const Icon(Icons.payments),
        title: Text("2. ${getLocalizations(context).emv}"),
        onTap: () async {
          await testEmv(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.microwave),
        title: Text("3. ${getLocalizations(context).testIcCommand}"),
        onTap: _testIcCommand,
      ),
      ListTile(
        enabled: _hasMDB,
        enableFeedback: true,
        leading: const Icon(Icons.question_mark),
        title: const Text("4. MDB"),
        onTap: _testMdb,
      ),
    ];

    List<Widget> list3 = [
      ListTile(
        enableFeedback: true,
        leading: const Icon(Icons.usb),
        title: const Text("1. Serial"),
        onTap: _testSerial,
      ),
      ListTile(
        leading: Icon(Icons.work),
        title: Text("2. UL test"),
        onTap: _testUL,
      ),
      ListTile(
        leading: Icon(Icons.create),
        title: Text("3. SharedPreference"),
        onTap: _testSharedPrefs,
      ),
      ListTile(
        enableFeedback: true,
        leading: const Icon(Icons.pin_invoke),
        title: Text("4. Pin Online"),
        onTap: _testPinOnline,
      ),
    ];

    var listofLists = [list1, list2, list3];

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) {
          if (digit == 1) {
            if (_isMe60) {
              switch (testsPage) {
                case 0:
                  _onTapCardReader();
                  break;
                case 1:
                  Navigator.pushNamed(context, SettingsMifareView.route);
                  break;
                case 2:
                  _testSerial();
                  break;
              }
            } else {
              final cardTypes = <CardType>[
                CardType.IC,
                CardType.Magnetic,
                CardType.RF
              ];
              _onCardReader(cardTypes);
            }
          } else if (digit == 2) {
            if (_isMe60) {
              switch (testsPage) {
                case 0:
                  if (_hasPrinter) {
                    Navigator.pushNamed(context, SettingsPrinterView.route);
                  }
                  break;
                case 1:
                  testEmv(context);
                  break;
                case 2:
                  _testUL();
                  break;
              }
            }
            if (_hasPrinter) {
              Navigator.pushNamed(context, SettingsPrinterView.route);
            }
          } else if (digit == 3) {
            if (_isMe60) {
              switch (testsPage) {
                case 0:
                  Navigator.pushNamed(context, SettingsDeviceView.route);
                  break;
                case 1:
                  _testIcCommand();
                  break;
                case 2:
                  _testSharedPrefs();
                  break;
              }
            }
            Navigator.pushNamed(context, SettingsDeviceView.route);
          } else if (digit == 4) {
            if (_isMe60) {
              switch (testsPage) {
                case 0:
                  _cryptographyOptions();
                  break;
                case 1:
                  _testMdb();
                  break;
                case 2:
                  _testPinOnline();
                  break;
              }
            }
          }
        },
        onEscape: () {
          Navigator.pop(context, (route) => true);
        },
        onBackspace: () {
          Navigator.pop(context, (route) => true);
        },
        onArrowUp: () {
          testsPage++;
          if (testsPage > 2) {
            testsPage = 0;
          }
          setState(() {});
        },
        onArrowDown: () {
          testsPage--;
          if (testsPage < 0) {
            testsPage = 2;
          }
          setState(() {});
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(_isMe60
              ? "${testsPage + 1}/3 ${getLocalizations(context).tests}"
              : getLocalizations(context).tests),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: _isMe60
                ? listofLists[testsPage]
                : [
                    ListTile(
                      enabled: _hasCardReader,
                      enableFeedback: true,
                      leading: const Icon(Icons.credit_card),
                      title: Text(getLocalizations(context).cardReader),
                      onTap: _onTapCardReader,
                    ),
                    ListTile(
                      enabled: _hasPrinter,
                      enableFeedback: true,
                      leading: const Icon(Icons.print),
                      title: Text(getLocalizations(context).printer),
                      onTap: () => Navigator.pushNamed(
                          context, SettingsPrinterView.route),
                    ),
                    ListTile(
                      enableFeedback: true,
                      leading: const Icon(Icons.smartphone),
                      title: Text(getLocalizations(context).device),
                      onTap: () {
                        Navigator.pushNamed(context, SettingsDeviceView.route);
                      },
                    ),
                    ListTile(
                      enableFeedback: true,
                      leading: const Icon(Icons.lock),
                      title: Text(getLocalizations(context).cryptography),
                      onTap: _cryptographyOptions,
                    ),
                    ListTile(
                      enableFeedback: true,
                      leading: const Icon(Icons.contactless),
                      title: Text(getLocalizations(context).mifare),
                      onTap: () => Navigator.pushNamed(
                          context, SettingsMifareView.route),
                    ),
                    ListTile(
                      enableFeedback: true,
                      leading: const Icon(Icons.payments),
                      title: Text(getLocalizations(context).emv),
                      onTap: () async {
                        await testEmv(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.microwave),
                      title: Text(getLocalizations(context).testIcCommand),
                      onTap: _testIcCommand,
                    ),
                    ListTile(
                      enableFeedback: true,
                      leading: const Icon(Icons.question_mark),
                      title: const Text("MDB"),
                      onTap: _testMdb,
                    ),
                    ListTile(
                      enableFeedback: true,
                      leading: const Icon(Icons.pin_invoke),
                      title: const Text("Pin Online"),
                      onTap: _testPinOnline,
                    ),
                    ListTile(
                      enableFeedback: true,
                      leading: const Icon(Icons.usb),
                      title: const Text("Serial"),
                      onTap: _testSerial,
                    ),
                    ListTile(
                      enabled: _isPinpad,
                      leading: Icon(Icons.screen_share),
                      title: Text(getLocalizations(context).pinpad),
                      onTap: () {
                        Navigator.pushNamed(context, SettingsPinpadView.route);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.work),
                      title: Text("UL test"),
                      onTap: _testUL,
                    ),
                    ListTile(
                      leading: Icon(Icons.create),
                      title: Text("SharedPreferences"),
                      onTap: _testSharedPrefs,
                    ),
                  ],
          ).toList(),
        ),
      ),
    );
  }

  Future<void> _testSharedPrefs() async {
    final testType = await showSharedPreferencesTestOptionDialog(context);
    print("Encryption Option");
    bool create = true;
    if (testType == 0) {
      create = true;
    } else if (testType == 1) {
      create = false;
    }

    try {
      if (create) {
        await _testSavePrefs();
      } else {
        await _testClearPrefs();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).sharedPrefsOK),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).sharedPrefsError),
      ));
    }
  }

  _testSavePrefs() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("testInt", 123);
    prefs.setBool("testBool", true);
    prefs.setDouble("testDouble", 12.34);
    prefs.setString("testString", "hola");
    prefs.setStringList("testStringList", ["hola", "lista"]);
    final testkeys = prefs.getKeys();
    print("got test keys: $testkeys");

    final testIntBool = prefs.containsKey("testInt");
    print("got testInt Bool: $testIntBool");
    final testint = prefs.get("testInt");
    print("got testInt get: $testint");

    final testBoolBool = prefs.containsKey("testBool");
    print("got testBool Bool: $testBoolBool");
    final testbool = prefs.get("testBool");
    print("got testBool get: $testbool");

    final testDoubeBool = prefs.containsKey("testDouble");
    print("got testDouble Bool: $testDoubeBool");
    final testdouble = prefs.get("testDouble");
    print("got testDouble get: $testdouble");

    final testStringBool = prefs.containsKey("testString");
    print("got testString Bool: $testStringBool");
    final teststring = prefs.get("testString");
    print("got testString get: $teststring");

    final testStringListBool = prefs.containsKey("testStringList");
    print("got testStringList Bool: $testStringListBool");
    final teststringlist = prefs.get("testStringList");
    print("got testStringList get: $teststringlist");
  }

  _testClearPrefs() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    final finalkeys = prefs.getKeys();
    print("final keys: $finalkeys");
  }

  _testSerial() {
    showSerialPortTestDialog(context);
  }

  _testMdb() {
    showMdbTestDialog(context);
  }

  _testIcCommand() async {
    showICCommandDialog(context);
  }

  _onCardReader(List<CardType> cardTypes) async {
    showCircularProgressDialog(
      context,
      getLocalizations(context).waitingForCard,
      onWillPop: () async {
        await closeCardReader();
        return true;
      },
    );

    final cardReaderStream = openCardReader(
      cardTypes: cardTypes,
      timeout: 10,
    );

    try {
      await for (final event in cardReaderStream) {
        if (!mounted) return;

        if (event.cardType == CardType.Magnetic) {
          _showSnackBarAndPop(getLocalizations(context).magCardDetected);

          final tracksData = await getTracksData();
          _showTracksLog(tracksData);
        } else if (event.cardType == CardType.IC) {
          showCardIndicatorDialog(context, false);
          await waitUntilICCardRemoved();
          Navigator.pop(context);
          _showSnackBarAndPop(getLocalizations(context).icCardDetected);
        } else if (event.cardType == CardType.RF) {
          showCardIndicatorDialog(context, false);
          await waitUntilRFCardRemoved();
          Navigator.pop(context);
          _showSnackBarAndPop(getLocalizations(context).rfCardDetected);
        }
      }
    } on TimeoutException {
      if (!mounted) return;
      _showSnackBarAndPop(getLocalizations(context).cardDetectionTimeout);
      await closeCardReader();
    } catch (e) {
      if (!mounted) return;
      print("Error: $e");
      _showSnackBarAndPop(getLocalizations(context).cardDetectionError);
      await closeCardReader();
    }
    print("****************CARD READER CLOSED*****************");
  }

  _onTapCardReader() async {
    final cardTypes = await showCardReaderDialog(context);
    if (cardTypes == null || cardTypes.isEmpty) return;
    _onCardReader(cardTypes);
  }

  _showSnackBarAndPop(String snackBarMsg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(snackBarMsg),
    ));
    Navigator.pop(context);
  }

  _showTracksLog(TracksData? tracksData) {
    showLogDialog(context, children: [
      const Text(""),
      const Text("Track 1:"),
      SelectableText("'${tracksData?.track1}'"),
      const Text(""),
      const Text("Track 2:"),
      SelectableText("'${tracksData?.track2}'"),
      const Text(""),
      const Text("Track 3:"),
      SelectableText("'${tracksData?.track3}'"),
    ], onClose: () {
      Navigator.pop(context);
    });
  }

  Future<void> _cryptographyOptions() async {
    final selectedFunction = await showSelectionDialog<Function>(
      context,
      {
        getLocalizations(context).cryptographyLegacy: () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            CryptographyLegacyTestView.route,
          );
        },
        getLocalizations(context).cryptographyDES: () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            CryptographyDESTestView.route,
          );
        },
        getLocalizations(context).cryptographyAES: () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            CryptographyAESTestView.route,
          );
        },
      },
    );
    if (selectedFunction != null) {
      selectedFunction();
    }
  }

  void _testPinOnline() async {
    final selectedFunction = await showSelectionDialog<Function>(
      context,
      {
        "DES": () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            PinOnlineDESTestView.route,
          );
        },
        "AES": () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            PinOnlineAESTestView.route,
          );
        },
        "Banorte": () {
          //Este flujo se crea para pruebas de Banorte con TR31 y RSA
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            PinOnlineBanorteTest.route,
          );
        },
      },
    );
    if (selectedFunction != null) {
      selectedFunction();
    }
  }

  Future<void> _testUL() async {
    final platformInfo = await getPlatformInfo();

    final String? testSetName = await showListSelectionDialog(
      context,
      [
        "Visa",
        "MasterCard",
      ],
    );
    final Map<String, String> testOptions;
    if (testSetName == "Visa") {
      testOptions = {
        "Visa Aprobada": "Aprove",
        "Visa Declined": "Decline",
        "Visa CVN18": "CVN18",
        "Visa CVN10": "CVN10",
      };
    } else if (testSetName == "MasterCard") {
      testOptions = {
        "MasterCard Aprobada": "Aprove",
      };
    } else {
      return;
    }

    final String? testType = await showMapSelectionDialog(context, testOptions);
    if (testType == null) return;
    final List<CardType> cardType;
    final EntryMode entryMode;
    switch (testType) {
      case "CVN18":
      case "CVN10":
        cardType = [CardType.IC];
        entryMode = EntryMode.Contact;
        break;
      case "Aprove":
      case "Decline":
        cardType = [CardType.IC, CardType.RF];
        entryMode = EntryMode.Contact;
        break;
      default:
        cardType = [];
        entryMode = EntryMode.Manual;
        break;
    }

    await emvPreTransaction(isTestMode: true);

    Navigator.pushNamed(
      context,
      EMVTestCardInput.route,
      arguments: TransactionArgs(
        platformInfo: platformInfo,
        entryMode: entryMode,
        showNumericKeyboard: true,
        supportedCardTypes: cardType,
        emvTransactionType: EmvTransactionType.Goods,
        amountInCents: 2000,
        testSetName: testSetName,
        ulTestType: testType,
        ulTestMode: true,
      ),
    );
  }
}
