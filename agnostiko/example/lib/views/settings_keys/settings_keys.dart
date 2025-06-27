import 'dart:io';

import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/services.dart';

import '../../config/app_keys.dart';
import '../../utils/comm.dart';
import '../../utils/iso8583.dart';
import '../../dialogs/info_dialog.dart';
import '../../dialogs/confirm_dialog.dart';
import '../../dialogs/change_password_dialog.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../pharos/pharos.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';

class SettingsKeysView extends StatefulWidget {
  static String route = "/settings/keys";

  @override
  _SettingsKeysViewState createState() => _SettingsKeysViewState();
}

class _SettingsKeysViewState extends State<SettingsKeysView> {
  bool _isMe60 = false;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      final deviceName = await getModel();
      setState(() {
        if (deviceName == "ME60") {
          _isMe60 = true;
        }
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) {
          if (digit == 1) {
            _validateKeyInitialization();
          } else if (digit == 2) {
            _validateKeyErase();
          } else if (digit == 3) {
            _validateLoadKEK();
          } else if (digit == 4) {
            showChangePasswordDialog(context);
          }
        },
        onEscape: () {
          Navigator.pop(context, true);
        },
        onBackspace: () {
          Navigator.pop(context, true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).keys),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60
                    ? "1. ${getLocalizations(context).initialization}"
                    : getLocalizations(context).initialization),
                onTap: _validateKeyInitialization,
              ),
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60
                    ? "2. ${getLocalizations(context).eraseKeys}"
                    : getLocalizations(context).eraseKeys),
                onTap: _validateKeyErase,
              ),
              ListTile(
                  enableFeedback: true,
                  title: Text(_isMe60
                      ? "3. ${getLocalizations(context).loadKEK}"
                      : getLocalizations(context).loadKEK),
                  onTap: _validateLoadKEK),
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60
                    ? "4. ${getLocalizations(context).changePassword}"
                    : getLocalizations(context).changePassword),
                onTap: () {
                  showChangePasswordDialog(context);
                },
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }

  Future<void> _validateKeyInitialization() async {
    bool keyExists =
        await cryptoDUKPTCheckKeyExists(AppKeys.des.transaction.index);
    if (keyExists) {
      showConfirmDialog(
        context,
        message: getLocalizations(context).keyAlreadyExistsConfirmation,
        onAccept: () {
          Navigator.pop(context);
          _tryKeyInitialization();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      );
    } else {
      _tryKeyInitialization();
    }
  }

  Future<void> _tryKeyInitialization() async {
    showCircularProgressDialog(context, getLocalizations(context).processing);
    try {
      await _keyInitializationPharos();
      await cryptoPINLoadKey(
        AppKeys.des.pinFixed,
        kek: AppKeys.des.kek,
        algorithmParameters: AppKeys.des.pinFixedParams,
      );
      Navigator.pop(context);
      showInfoDialog(context, getLocalizations(context).keyInitialized);
    } on SocketException catch (e, stacktrace) {
      print(stacktrace);
      Navigator.pop(context);
      showInfoDialog(
        context,
        "${getLocalizations(context).commError} - ${e.message}",
      );
    } on StateError catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "Error: ${e.message}");
    } on PlatformException catch (e) {
      if (e.isAgnostikoException()) {
        if (e.details == AgnostikoError.KEY_MISSING) {
          Navigator.pop(context);
          showInfoDialog(
              context, "Error: ${getLocalizations(context).keyMissing}");
        } else if (e.details == AgnostikoError.KCV_FAILED) {
          Navigator.pop(context);
          showInfoDialog(
              context, "Error: ${getLocalizations(context).kcvFailed}");
        } else if (e.details == AgnostikoError.KEK_UNSUPPORTED) {
          Navigator.pop(context);
          showInfoDialog(context, "Error: KEK Unsupported");
        } else {
          Navigator.pop(context);
          showInfoDialog(context,
              "${getLocalizations(context).internalError}\n${e.code}\n${e.message}\n${e.details}");
          print(e);
        }
      } else {
        showInfoDialog(context, e.toString());
        print(e);
      }
    } catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).internalError}\n$e");
      print(e);
    }
  }

  Future<void> _keyInitializationPharos() async {
    // creamos un objeto de "Capítulo X" para la sesión de inicialización de
    // llaves
    final capx = CapX(AppKeys.des.transaction.index);

    // solicitamos la llave de transporte encriptada mediante su
    // correspondiente llave RSA
    late var tk;
    try {
      tk = await capx.getEncryptedTransportKey("assets/capx/public_pharos.pem");
    } catch (e) {
      _showError(e, getLocalizations(context).pharosRSAError);
    }
    // generamos el mensaje de solicitud para el host
    late var pharosMsgKeyInit;
    try {
      pharosMsgKeyInit = await pharosGenerateKeyInitialization(
        cipheredTK: tk.keyData,
        kcv: tk.kcv,
      );
    } catch (e) {
      _showError(e, getLocalizations(context).pharosKeyError);
    }
    late var pharosResponse;
    try {
      pharosResponse = await processKeyInitPharos(pharosMsgKeyInit);
    } catch (e) {
      _showError(e, getLocalizations(context).commErrorPharos);
    }
    // En entorno de producción se utilizarían los siguientes valores que
    // responde pharos
    //final ksn = pharosResponse.newKeyKsn;
    //final encryptedK0 = pharosResponse.encryptedNewKey;
    //capx.loadEncryptedIPEK(ksn.toHexBytes(), encryptedK0.toHexBytes());

    // Dado que estamos en entorno de prueba, cargamos con valores demo
    final kek = AppKeys.des.kek;
    final key = AppKeys.des.transaction;
    final data = key.data;
    final ksn = key.ksn;
    if (data == null || ksn == null) {
      throw StateError("data missing for transaction key");
    }
    await cryptoDataLoadKey(key, kek: kek);
  }

  Future<void> _keyInitializationServerAgnostiko() async {
    // creamos un objeto de "Capítulo X" para la sesión de inicialización de
    // llaves
    final capx = CapX(AppKeys.des.transaction.index);

    // solicitamos la llave de transporte encriptada mediante su
    // correspondiente llave RSA
    final tk = await capx.getEncryptedTransportKey("assets/capx/public.pem");

    // generamos el mensaje de solicitud para el host
    final isoMsg = await isoGenerateKeyInitialization(
      cipheredTK: tk.keyData,
      kcv: tk.kcv,
    );
    final isoResponse = await processKeyInit(isoMsg);

    final responseCode = isoResponse.getField(39);
    if (responseCode != "00") {
      if (responseCode == "73") {
        throw StateError(getLocalizations(context).wrongCRC);
      } else if (responseCode == "72") {
        throw StateError(getLocalizations(context).failedValidation);
      } else {
        throw StateError(getLocalizations(context).serverError);
      }
    }

    final field63 = isoResponse.getField(63);
    if (field63 == null) {
      throw StateError(getLocalizations(context).field63Missing);
    }
    // buscamos la llave K0 encriptada con la llave de transporte
    final tokenEXIndex = field63.indexOf("! EX");
    final tokenEX = field63.substring(tokenEXIndex, tokenEXIndex + 78);
    final encryptedK0 = tokenEX.substring(10, 42).toHexBytes();
    final ksn = tokenEX.substring(42, 62).toHexBytes();

    // y se lo pasamos al objeto de "Capítulo X" para que complete la
    // inicialización
    await capx.loadEncryptedIPEK(ksn, encryptedK0);
  }

  Future<void> _validateKeyErase() async {
    showConfirmDialog(
      context,
      message: getLocalizations(context).eraseKeysConfirmation,
      onAccept: () async {
        Navigator.pop(context);
        showCircularProgressDialog(
            context, getLocalizations(context).processing);
        await cryptoDeleteAllKeys();
        Navigator.pop(context);
      },
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  Future<void> _validateLoadKEK() async {
    showCircularProgressDialog(context, getLocalizations(context).processing);
    try {
      await loadTestKEK();
      Navigator.pop(context);
      showInfoDialog(context, getLocalizations(context).loadKEKSucceed);
    } catch (e) {
      Navigator.pop(context);
      showInfoDialog(context, "${getLocalizations(context).loadKEKError}: $e");
      print(e);
    }
  }

  void _showError(dynamic e, String message) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
    print("Error: $e");
    Navigator.popUntil(context, (route) => route.isFirst == true);
  }
}
