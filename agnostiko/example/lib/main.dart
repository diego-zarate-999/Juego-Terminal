import 'package:agnostiko_example/views/cryptography/cryptography_legacy_test.dart';
import 'package:agnostiko_example/views/cryptography/cryptography_des_test.dart';
import 'package:agnostiko_example/views/cryptography/cryptography_aes_test.dart';
import 'package:agnostiko_example/views/emv_test/emv_card_input.dart';
import 'package:agnostiko_example/views/printer/ticket_preview.dart';
import 'package:agnostiko_example/views/settings_mifare/settings_mifare.dart';
import 'package:agnostiko_example/views/settings_pinpad/settings_pinpad.dart';
import 'package:agnostiko_example/views/settings_printer/settings_printer.dart';
import 'package:agnostiko_example/views/stan_input/stan_input.dart';
import 'package:agnostiko_example/views/test_logger/test_logger.dart';
import 'package:agnostiko_example/views/test_pin/test_pin_input.dart';
import 'package:agnostiko_example/views/pin_online/pin_online_aes_test.dart';
import 'package:agnostiko_example/views/pin_online/pin_online_banorte_test.dart';
import 'package:agnostiko_example/views/pin_online/pin_online_des_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:agnostiko_example/views/home/home.dart';
import 'package:agnostiko_example/views/amount_input/amount_input.dart';
import 'package:agnostiko_example/views/card_input/card_input.dart';
import 'package:agnostiko_example/views/pan_input/pan_input.dart';
import 'package:agnostiko_example/views/emv_transaction_info/emv_transaction_info.dart';
import 'package:agnostiko_example/views/exp_date_input/exp_date_input.dart';
import 'package:agnostiko_example/views/cvv_input/cvv_input.dart';
import 'package:agnostiko_example/views/pin_input/pin_input.dart';
import 'package:agnostiko_example/views/settings_home/settings_home.dart';
import 'package:agnostiko_example/views/settings_tests/settings_tests.dart';
import 'package:agnostiko_example/views/settings_device/settings_device.dart';
import 'package:agnostiko_example/views/settings_params/settings_params.dart';
import 'package:agnostiko_example/views/settings_keys/settings_keys.dart';
import 'package:agnostiko_example/views/settings_aid_list/settings_aid_list.dart';
import 'package:agnostiko_example/views/settings_aid_params/settings_aid_params.dart';
import 'package:agnostiko_example/views/settings_capk_list/settings_capk_list.dart';
import 'package:agnostiko_example/views/settings_capk/settings_capk.dart';
import 'package:agnostiko_example/views/settings_terminal_params/settings_terminal_params.dart';
import 'package:agnostiko_example/views/logo/LogoPage.dart';
import 'package:agnostiko_example/utils/parameters.dart';

import 'views/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale? newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setState(() {
      state._locale = newLocale;
    });
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    initPos();
  }

  Future<void> initPos() async {
    print("Inicializando...");

    print("Cargando locale...");
    final locale = await loadAppLocale();
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/img/tap_card.png"), context);
    precacheImage(AssetImage("assets/img/insert_card.png"), context);
    precacheImage(AssetImage("assets/img/swipe_card.png"), context);
    return MaterialApp(
      locale: _locale,
      initialRoute: SplashScreenView.route,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Color(0xFF03045E),
        appBarTheme: AppBarTheme(color: const Color(0xFF03045E)),
      ),
      routes: {
        SplashScreenView.route: (BuildContext context) => SplashScreenView(),
        HomeView.route: (BuildContext context) => HomeView(),
        AmountInputView.route: (BuildContext context) => AmountInputView(),
        CardInputView.route: (BuildContext context) => CardInputView(),
        EMVTestCardInput.route: (BuildContext context) =>
            const EMVTestCardInput(),
        PanInputView.route: (BuildContext context) => PanInputView(),
        StanInputView.route: (BuildContext context) => StanInputView(),
        EmvTransactionInfoView.route: (BuildContext context) =>
            EmvTransactionInfoView(),
        ExpDateInputView.route: (BuildContext context) => ExpDateInputView(),
        CvvInputView.route: (BuildContext context) => CvvInputView(),
        PinInputView.route: (BuildContext context) => PinInputView(),
        LogoPage.route: (BuildContext context) => LogoPage(),
        SettingsHomeView.route: (BuildContext context) => SettingsHomeView(),
        SettingsKeysView.route: (BuildContext context) => SettingsKeysView(),
        SettingsTestsView.route: (BuildContext context) => SettingsTestsView(),
        SettingsDeviceView.route: (BuildContext context) =>
            SettingsDeviceView(),
        SettingsParamsView.route: (BuildContext context) =>
            SettingsParamsView(),
        SettingsAidListView.route: (BuildContext context) =>
            SettingsAidListView(),
        SettingsAidParamsView.route: (BuildContext context) =>
            SettingsAidParamsView(),
        SettingsCAPKListView.route: (BuildContext context) =>
            SettingsCAPKListView(),
        SettingsCAPKView.route: (BuildContext context) => SettingsCAPKView(),
        SettingsTerminalParamsView.route: (BuildContext context) =>
            SettingsTerminalParamsView(),
        SettingsMifareView.route: (BuildContext context) =>
            SettingsMifareView(),
        TicketPreview.route: (BuildContext context) => TicketPreview(),
        SettingsPrinterView.route: (BuildContext context) =>
            SettingsPrinterView(),
        SettingsPinpadView.route: (BuildContext context) =>
            SettingsPinpadView(),
        TestLoggerView.route: (BuildContext context) => TestLoggerView(),
        CryptographyLegacyTestView.route: (BuildContext context) =>
            CryptographyLegacyTestView(),
        CryptographyDESTestView.route: (BuildContext context) =>
            CryptographyDESTestView(),
        CryptographyAESTestView.route: (BuildContext context) =>
            CryptographyAESTestView(),
        PinOnlineAESTestView.route: (BuildContext context) =>
            PinOnlineAESTestView(),
        PinOnlineDESTestView.route: (BuildContext context) =>
            PinOnlineDESTestView(),
        PinOnlineBanorteTest.route: (BuildContext context) =>
            const PinOnlineBanorteTest(),
        TestPinInputView.route: (BuildContext context) => TestPinInputView(),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
