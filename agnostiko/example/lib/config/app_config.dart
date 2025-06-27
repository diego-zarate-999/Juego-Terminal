import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConfig {
  static NumberFormat getCurrencyFormat(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return NumberFormat.currency(locale: locale.toLanguageTag(), symbol: "\$");
  }

  static const clearTestPAN = "4761731000000043";

  AppConfig._();
}
