import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:agnostiko/agnostiko.dart';

import 'package:flutter/services.dart' show rootBundle;

const _defaultPath = "assets/params";
const _paramsFilename = "terminal_parameters.json";
const _aidFilename = "aid.json";
const _capkFilename = "capk.json";
const _localeFilename = "locale";

/// Carga los parámetros de terminal configurados en un archivo JSON de la app.
Future<TerminalParameters> loadTerminalParameters() async {
  String jsonStr = "";

  // Si falla la carga del archivo...
  try {
    final externalPath = (await getApplicationDocumentsDirectory()).path;
    final file = File('$externalPath/$_paramsFilename');

    jsonStr = await file.readAsString();
  } catch (e) {
    // ...utilizamos los valores por defecto.
    jsonStr = await rootBundle.loadString("$_defaultPath/$_paramsFilename");
  }

  return TerminalParameters.fromJson(jsonDecode(jsonStr));
}

/// Guarda los parámetros de terminal en un archivo JSON de la app.
Future<void> saveTerminalParameters(TerminalParameters parameters) async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_paramsFilename');

  await file.writeAsString(jsonEncode(parameters));
}

/// Resetea los parámetros del terminal de la app a su valor por defecto.
Future<void> resetTerminalParameters() async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_paramsFilename');
  final fileExists = await file.exists();

  // Eliminamos el archivo de parámetros para que la próxima carga sea de los
  // valores por defecto
  if (fileExists) await file.delete();
}

List<EmvApp> parseEmvAppList(String jsonData) {
  final resList = jsonDecode(jsonData) as List;
  return resList.map((app) => EmvApp.fromJson(app)).toList();
}

/// Carga la lista de apps EMV y sus parámetros asociados por cada AID.
Future<List<EmvApp>> loadEmvAppList() async {
  String jsonStr = "";

  // Si falla la carga del archivo...
  try {
    final externalPath = (await getApplicationDocumentsDirectory()).path;
    final file = File('$externalPath/$_aidFilename');

    jsonStr = await file.readAsString();
  } catch (e) {
    // ...utilizamos los valores por defecto.
    jsonStr = await rootBundle.loadString("$_defaultPath/$_aidFilename");
  }

  return parseEmvAppList(jsonStr);
}

/// Guarda la lista de apps EMV y sus parámetros asociados por cada AID.
Future<void> saveEmvAppList(List<EmvApp> appList) async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_aidFilename');
  await file.writeAsString(jsonEncode(appList));
}

/// Resetea la lista de apps EMV y sus parámetros de AID a su valor por defecto.
Future<void> resetEmvAppList() async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_aidFilename');
  final fileExists = await file.exists();

  // Eliminamos el archivo de parámetros para que la próxima carga sea de los
  // valores por defecto
  if (fileExists) await file.delete();
}

/// Carga la lista de llaves públicas (CAPK) para aplicaciones EMV.
Future<List<CAPK>> loadCAPKList() async {
  String jsonStr = "";

  // Si falla la carga del archivo...
  try {
    final externalPath = (await getApplicationDocumentsDirectory()).path;
    final file = File('$externalPath/$_capkFilename');

    jsonStr = await file.readAsString();
  } catch (e) {
    // ...utilizamos los valores por defecto.
    jsonStr = await rootBundle.loadString("$_defaultPath/$_capkFilename");
  }

  return CAPK.parseJsonArray(jsonStr);
}

Future<void> saveAppLocale(Locale locale) async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_localeFilename');
  await file.writeAsString(locale.toLanguageTag());
}

Future<void> clearAppLocale() async {
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_localeFilename');
  await file.delete();
}

Future<Locale?> loadAppLocale() async {
  Locale? locale;

  try {
    final externalPath = (await getApplicationDocumentsDirectory()).path;
    final file = File('$externalPath/$_localeFilename');
    final languageTag = await file.readAsString();
    if (languageTag.isNotEmpty) {
      locale = Locale.fromSubtags(languageCode: languageTag);
    }
  } catch (e) {
    locale = null;
  }

  return locale;
}
