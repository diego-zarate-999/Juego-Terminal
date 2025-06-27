import 'dart:async';
import 'dart:io';

import 'package:prueba_ag/utils/emv.dart';
import 'package:flutter/material.dart';
import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:prueba_ag/views/auth_screen/auth_screen.dart';
import 'package:prueba_ag/views/game_screen/game_screen.dart';

import '../../dialogs/mpos_selection_dialog.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/token.dart';

class SplashScreenView extends StatefulWidget {
  static String route = "/";

  @override
  SplashScreenViewState createState() => SplashScreenViewState();
}

class SplashScreenViewState extends State<SplashScreenView> {
  String _cardMsg = "";
  bool _visibility = false;
  bool _exit = false;
  String _buttonTitle = "";
  bool _invalidToken = false;
  int _initFailedCounter = 0;

  @override
  void initState() {
    super.initState();
    initSplashScreen();
  }

  void loadingCardMsg(String cardMsg) {
    setState(() {
      _cardMsg = cardMsg;
    });
  }

  void setInvalidToken(bool invalidToken) {
    setState(() {
      _invalidToken = invalidToken;
    });
  }

  void loadingVisibility(bool visibility, {bool? exit}) {
    setState(() {
      _visibility = visibility;
      if (exit != null) {
        _exit = exit;
        _exit
            ? _buttonTitle = getLocalizations(context).exit
            : _buttonTitle = getLocalizations(context).retry;
      }
    });
  }

  void onTapButton() {
    if (!_exit) {
      loadingCardMsg("");
      loadingVisibility(false);
      initSplashScreen();
    } else {
      exit(0);
    }
  }

  Future<void> loadServerCertificate() async {
    ByteData data = await rootBundle.load(
      'assets/ca/insightone-server.agnostiko.cer',
    );
    SecurityContext context = SecurityContext.defaultContext;
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  }

  Future<Uint8List?> _getTokenOnline(String serialNumber, String brand) async {
    String? tokenStr;
    Uint8List authToken;

    // El appId debe coincidir con el registrado en la licencia de TMS para poder obtener token
    const appId = "agnostiko_example";

    // intentamos obtener el token de la URL productiva
    try {
      const productionUrl = "https://insightone-server.agnostiko.com";
      authToken = await getSDKToken(productionUrl, brand, serialNumber, appId);
    } catch (e) {
      // en caso de fallo, intentamos con la URL demo a ver si el dispositivo
      // está autorizado por ahí
      try {
        const demoUrl = "https://tms-server-demo.apps2go.tech";
        authToken = await getSDKToken(demoUrl, brand, serialNumber, appId);
      } catch (e) {
        String cardMsg = getLocalizations(context).connectionErrorToken;
        loadingCardMsg(cardMsg);
        loadingVisibility(true, exit: false);
        return null;
      }
    }
    tokenStr = authToken.toHexStr();
    saveToken(tokenStr);
    print("No se tenía un token guardado. Se obtuvo uno nuevo del servidor");
    return authToken;
  }

  Future<Uint8List?> _getLocalToken() async {
    Uint8List? token;
    try {
      token = await checkToken();
      return token;
    } catch (e) {
      setInvalidToken(true);
      return null;
    }
  }

  Future<Uint8List?> _initToken() async {
    Uint8List? authToken;
    bool isTokenExpired;
    try {
      Uint8List? token = await _getLocalToken();
      if (token != null && _invalidToken == false) {
        authToken = token;
        isTokenExpired = validateExpDateToken(authToken);
        if (!isTokenExpired) {
          print("Ya existe un token guardado no vencido");
          return authToken;
        } else {
          setInvalidToken(true);
          initSplashScreen();
          return null;
        }
      } else {
        final brand = (await getPlatformInfo()).deviceBrand;
        final serialNumber = await getSerialNumber();
        if (serialNumber != null) {
          authToken = await _getTokenOnline(serialNumber, brand);
          return authToken;
        } else {
          // ignore: use_build_context_synchronously
          String cardMsg = getLocalizations(context).serialErrorToken;
          loadingCardMsg(cardMsg);
          loadingVisibility(true, exit: true);
          return null;
        }
      }
    } catch (e) {
      String cardMsg = getLocalizations(context).generalErrorToken;
      loadingCardMsg(cardMsg);
      loadingVisibility(true, exit: true);
      return null;
    }
  }

  bool _catchInitFailed({Object? e}) {
    bool initCompleted;
    String cardMsg = getLocalizations(context).initError;
    loadingCardMsg(cardMsg);
    loadingVisibility(true, exit: true);
    initCompleted = false;
    return initCompleted;
  }

  bool _catchPlatformException(PlatformException e) {
    if (e.details == AgnostikoError.PINPAD_ERROR) {
      loadingCardMsg(getLocalizations(context).pinpadError);
      loadingVisibility(true, exit: true);
      return false;
    }
    if (e.details == AgnostikoError.PINPAD_CONNECTION_ERROR) {
      loadingCardMsg(getLocalizations(context).pinpadConnectionError);
      loadingVisibility(true, exit: false);
      return false;
    }

    if (_initFailedCounter < 3) {
      setInvalidToken(true);
      _initFailedCounter++;
      print("Token inválido, obteniendo otro, intento: $_initFailedCounter");
      initSplashScreen();
      return false;
    } else {
      return _catchInitFailed();
    }
  }

  // Retorna *true* cuando se haya inicializado el SDK correctamente
  Future<bool> _initPos() async {
    Uint8List? authToken;
    final deviceType = await getDeviceType();
    try {
      if (deviceType == DeviceType.POS) {
        authToken = await _initToken();
        if (authToken == null) {
          return false;
        } else {
          await initSDK(authToken: authToken);
        }
      } else if (deviceType == DeviceType.PINPAD) {
        final bluetoothFlag = await isBluetoothEnabled();
        if (bluetoothFlag) {
          final devices = await getBondedBluetoothDevices();
          final selectedDevice =
              // ignore: use_build_context_synchronously
              await showMPOSSelectionDialog(context, devices);
          if (selectedDevice != null) {
            await connectBluetoothPinpad(selectedDevice.address);
          }
        } else {
          await connectPinpad();
        }
        authToken = await _initToken();
        if (authToken == null) {
          return false;
        } else {
          await initSDK(authToken: authToken);
          await emvPreTransaction();
        }
      } else {
        await initSDK();
      }
      print("Librería Universal de Pagos inicializada!");
      return true;
    } on PlatformException catch (e, stackTrace) {
      print(stackTrace);
      return _catchPlatformException(e);
    } catch (e, stackTrace) {
      print(stackTrace);
      return _catchInitFailed(e: e);
    }
  }

  bool isCertificateLoaded = false;
  Future<void> initSplashScreen() async {
    if (!isCertificateLoaded && Platform.isLinux) {
      await loadServerCertificate();
      isCertificateLoaded = true;
    }
    List<bool> future = await Future.wait<bool>([
      _initPos(),
      Future.delayed(Duration(seconds: 2), () => true),
    ]);
    if (future[0] && future[1]) {
      // Navigator.pushReplacementNamed(context, GameScreen.route);
      Navigator.pushReplacementNamed(context, AuthScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    String _label;
    if (_cardMsg == "") {
      _label = getLocalizations(context).loading;
    } else {
      _label = _cardMsg;
    }

    final queryData = MediaQuery.of(context);
    double padding = 15.0;
    final screenHeight = queryData.size.height - (padding * 2);
    final screenWidth = queryData.size.width - (padding * 2);

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onEscape: () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
      ),
      child: Container(
          constraints:
              BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
          color: const Color(0xFF03045E),
          child: Column(children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: screenHeight / 6),
              height: screenHeight / 3,
              width: 400.0,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/img/logo_agnostiko_blanco_eslogan.png'),
                  ),
                  shape: BoxShape.rectangle),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              color: const Color(0xFF03045E),
              child: ListTile(
                title: Center(
                  child: Text(
                    _label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Visibility(
              visible: !_visibility,
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 120,
                //size: 150,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Visibility(
              child: SizedBox(
                width: 150,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Color(0xFF03045E),
                    elevation: 10,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.white,
                            width: 3,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    onTapButton();
                  },
                  child: Text(
                    _buttonTitle,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              visible: _visibility,
            ),
            SizedBox(
              height: 5,
            ),
          ])
          //child:FlutterLogo(size:MediaQuery.of(context).size.height)
          ),
    );
  }
}
