import 'package:flutter/material.dart';
import 'package:prueba_ag/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prueba_ag/utils/parameters.dart';
import 'package:prueba_ag/views/auth_screen/auth_screen.dart';
import 'package:prueba_ag/views/game_screen/game_screen.dart';

import 'views/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 20, 20, 20),
);

final theme = ThemeData().copyWith(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color.fromARGB(255, 38, 38, 38),
  colorScheme: colorScheme,
  appBarTheme: AppBarTheme(
    color: const Color.fromARGB(255, 45, 45, 45),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
    ),
  ),
);

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
    return MaterialApp(
      locale: _locale,
      initialRoute: SplashScreenView.route,
      theme: theme,
      routes: {
        SplashScreenView.route: (BuildContext context) => SplashScreenView(),
        AuthScreen.route: (BuildContext context) => const AuthScreen(),
        GameScreen.route: (BuildContext context) => const GameScreen(),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
