import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations getLocalizations(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  if (localizations == null) {
    throw StateError("Error obteniendo localizaciones.");
  }
  return localizations;
}

List<Locale> getSupportedLocales(BuildContext context) {
  return AppLocalizations.supportedLocales;
}
