import 'dart:io';

import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:crypt/crypt.dart';

const _defaultPath = "assets/password";
const _settingsFilename = "settings";

Future<bool> verifySettingsPassword(String password) async {
  final hashedPassword = Crypt(await _loadSettingsPassword());
  return hashedPassword.match(password);
}

Future<void> saveSettingsPassword(String password) async {
  final hashedPassword = Crypt.sha256(password).toString();
  final externalPath = (await getApplicationDocumentsDirectory()).path;
  final file = File('$externalPath/$_settingsFilename');
  await file.writeAsString(hashedPassword);
}

Future<String> _loadSettingsPassword() async {
  // Si falla la carga del archivo...
  try {
    final externalPath = (await getApplicationDocumentsDirectory()).path;
    final file = File('$externalPath/$_settingsFilename');
    final str = await file.readAsString();
    return str;
  } catch (e) {
    // ...utilizamos los valores por defecto.
    return rootBundle.loadString("$_defaultPath/$_settingsFilename");
  }
}
