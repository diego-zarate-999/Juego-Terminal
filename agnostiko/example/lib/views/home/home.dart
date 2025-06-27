import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agnostiko/agnostiko.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../dialogs/info_dialog.dart';
import '../../models/transaction_args.dart';
import '../../dialogs/circular_progress_dialog.dart';
import '../../dialogs/mpos_selection_dialog.dart';
import '../../utils/comm.dart';
import '../../utils/token.dart';
import '../../views/amount_input/amount_input.dart';
import '../../views/settings_home/settings_home.dart';
import '../../views/home/widgets/home_view_button.dart';
import '../../utils/emv.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../stan_input/stan_input.dart';

class HomeView extends StatefulWidget {
  static String route = "/home";

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  PlatformInfo? _platformInfo;
  String _platformInfoStr = '...';
  bool _hasKeypad = false;
  List<CardType> _supportedCardTypes = [];

  bool _showMPOSButton = false;
  String? _activeMPOSName;

  bool _invalidToken = false;
  bool _activeConnection = false;
  int _initFailedCounter = 0;

  ui.Image? img;

  Map<String, int> transactionTypeOptions = {
    "Sale":  EmvTransactionType.Goods,
    'Refund': EmvTransactionType.Refund,
    'Void': EmvTransactionType.Void,
  };

  String _selectedTransactionType = "Sale";

  @override
  void initState() {
    super.initState();
    // registramos un listener para mostrar en pantalla etiqueta de conexión
    // MPOS activa (si aplica)
    MPOSController.instance.addConnectionChangeListener(
      _updateActiveConnectionLabel,
    );
    //initPlatformState();
    _initPos();
  }

  @override
  void dispose() {
    // eliminamos el listener de conexión MPOS
    MPOSController.instance.removeConnectionChangeListener(
      _updateActiveConnectionLabel,
    );
    super.dispose();
  }

  /// Actualiza la etiqueta de conexión MPOS activa mostrada en barra superior
  void _updateActiveConnectionLabel() {
    setState(() {
      _activeMPOSName = MPOSController.instance.getActiveConnection()?.name;
    });
  }

  Future<void> _initPos() async {
    String platformStr;
    bool hasKeypad;
    bool showMPOSButton = false;
    List<CardType> supportedCardTypes;

    try {
      final platformInfo = await getPlatformInfo();
      print("Tiene Lector de tarjetas? = ${platformInfo.hasCardReader}");
      print("Tiene módulo EMV? = ${platformInfo.hasEmvModule}");
      print("Tiene Impresora? = ${platformInfo.hasPrinter}");
      print("Tiene PinPad? = ${platformInfo.hasPinEntryDevice}");
      print("Tiene Keypad? = ${platformInfo.hasKeypad}");

      final deviceType = await getDeviceType();
      if (deviceType == DeviceType.Mobile || deviceType == DeviceType.MPOS) {
        showMPOSButton = true;
      }

      final serialNumber = await getSerialNumber();
      print("Serial number? = $serialNumber");

      platformStr = "${platformInfo.baseOs} ${platformInfo.version} - " +
          "${platformInfo.deviceBrand} Implementation";
      hasKeypad = platformInfo.hasKeypad;
      supportedCardTypes = platformInfo.supportedCardTypes;

      _platformInfo = platformInfo;
    } on PlatformException {
      platformStr = _platformInfoStr;
      hasKeypad = false;
      supportedCardTypes = [];
    }

    if (_platformInfo?.hasMDB == true) {
      print("MDB possible!");
    }

    if (!mounted) return;

    setState(() {
      _showMPOSButton = showMPOSButton;
      _platformInfoStr = platformStr;
      _hasKeypad = hasKeypad;
      _supportedCardTypes = supportedCardTypes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final queryData = MediaQuery.of(context);
    final screenHeight = queryData.size.height;
    final screenWidth = queryData.size.width;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onDigit: (digit) {
           if (digit == 1) {
            _onTapTransaction();
          } else if (digit == 2) {
            Navigator.pushNamed(context, SettingsHomeView.route);
          }
        },
        // Necesario para poder cerrar la app en terminales embebidos
        onEscape: () =>
            SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          actions: [
            Center(child: Text(_activeMPOSName ?? "")),
            if (_showMPOSButton)
              IconButton(
                icon: Icon(Icons.bluetooth),
                onPressed: _onTapBluetoothConnection,
              ),
              IconButton(
                icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(
                        context, SettingsHomeView.route);
                  }
              ),
          ],
          title: Text(getLocalizations(context).title),
        ),
        body: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth,
            maxHeight: screenHeight,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalVerticalPadding = _getVerticalPadding();
              final remainingHeight = _getRemainingHeight(constraints, totalVerticalPadding);
              final showImage = _getShowImage(remainingHeight);
              double cardHeight = _getCardHeight(showImage, remainingHeight);
              double dropdownWidth = _getDropdownWidth(constraints);
              double buttonWidth = dropdownWidth;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: showImage ? 10 : 5),
                    if (showImage)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        width: constraints.maxWidth - 40,
                        height: cardHeight,
                        child: Image.asset(
                          'assets/img/card_sale.png',
                          fit: BoxFit.contain, // Ajusta proporcionalmente
                        ),
                      ),
                    if (showImage) SizedBox(height: 10),

                    // Selector de tipo de transacción
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: dropdownWidth,
                        child: Align(
                          alignment: Alignment.centerRight, // Alinear la flecha a la derecha
                          child: DropdownButton<String>(
                            isExpanded: true, // Para que el DropdownButton ocupe completo el espacio
                            value: _selectedTransactionType,
                            items: transactionTypeOptions.keys.map<DropdownMenuItem<String>>((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(key),
                              );
                            }).toList(),
                            onChanged: (String? newKey) {
                              setState(() {
                                _selectedTransactionType = newKey!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const Spacer(), // Aumentar el espacio entre el dropdown y el botón si hay espacio disponible

                    // Botón de transacción
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: buttonWidth,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF03045E),
                            side: const BorderSide(color: Color(0xFF03045E), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _onTapTransaction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.credit_card,
                                color: Color(0xFF03045E),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                getLocalizations(context).transaction,
                                style: const TextStyle(
                                  color: Color(0xFF03045E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(), // Aumentar el espacio adicional opcional al final si hay espacio disponible
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onTapBluetoothConnection() async {
    // nos aseguramos de obtener los permisos de Bluetooth necesarios
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    print("Statuses: $statuses");
    if (statuses[Permission.bluetooth] != PermissionStatus.granted ||
        statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
        statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
      showInfoDialog(
        context,
        getLocalizations(context).bluetoothPermissionRequired,
      );
      return;
    }

    final devices = await getBondedBluetoothDevices();
    final selectedDevice = await showMPOSSelectionDialog(context, devices);
    if (selectedDevice == null) return;

    final controller = MPOSController.instance;
    if (controller.checkAddressConnection(selectedDevice.address)) {
      controller.setActiveConnectionByAddress(selectedDevice.address);
    } else {
      await _connectDevice(selectedDevice);
    }

    await _initPos();
  }

  void setInvalidToken(bool invalidToken) {
    setState(() {
      _invalidToken = invalidToken;
    });
  }

  void checkActiveconnection(bool activeConnection) {
    setState(() {
      _activeConnection = activeConnection;
    });
  }

  Future<Uint8List?> _getTokenOnline(String serialNumber,
      MPOSController controller, BluetoothDevice device) async {
    Uint8List? authToken;
    String? tokenStr;
    setInvalidToken(false);
    try {
      authToken = await getToken(serialNumber);
    } catch (e) {
      String cardMsg = getLocalizations(context).connectionErrorToken;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(cardMsg),
      ));
      controller.closeBluetoothConnection(device.address);
      return null;
    }
    if (authToken != null) {
      tokenStr = authToken.toHexStr();
      saveTokenMpos(serialNumber, tokenStr);
      print("No se tenía un token guardado. Se obtuvo uno nuevo del servidor");
    }
    return authToken;
  }

  Future<Uint8List?> _getLocalToken(String? serialNumber) async {
    Uint8List? token;
    try {
      if (serialNumber != null) {
        token = await checkTokenMpos(serialNumber);
        return token;
      }
      return null;
    } catch (e) {
      setInvalidToken(true);
      return null;
    }
  }

  Future<Uint8List?> _initToken(
      MPOSController controller, BluetoothDevice device) async {
    Uint8List? authToken;
    String? serialNumber = await getSerialNumber();
    bool isTokenExpired;
    try {
      Uint8List? token = await _getLocalToken(serialNumber);
      if (token != null && _invalidToken == false) {
        authToken = token;
        isTokenExpired = validateExpDateToken(authToken);
        if (!isTokenExpired) {
          print("Ya existe un token guardado no vencido");
          return authToken;
        } else {
          setInvalidToken(true);
          print("Token vencido, obteniendo otro online");
          Navigator.pop(context);
          checkActiveconnection(true);
          await _connectDevice(device);
          return null;
        }
      } else {
        if (serialNumber != null) {
          authToken = await _getTokenOnline(serialNumber, controller, device);
        } else {
          String cardMsg = getLocalizations(context).serialErrorToken;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(cardMsg),
          ));
          controller.closeBluetoothConnection(device.address);
          return null;
        }
      }
    } catch (e) {
      String cardMsg = getLocalizations(context).generalErrorToken;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(cardMsg),
      ));
      controller.closeBluetoothConnection(device.address);
      return null;
    }

    return authToken;
  }

  Future<bool> _catchPlatformException(
      MPOSController controller, BluetoothDevice device) async {
    bool initCompleted;
    if (_initFailedCounter < 3) {
      setInvalidToken(true);
      _initFailedCounter++;
      print("Token inválido, obteniendo otro, intentos: $_initFailedCounter");
      Navigator.pop(context);
      checkActiveconnection(true);
      await _connectDevice(device);
      initCompleted = false;
      return initCompleted;
    } else {
      String cardMsg = getLocalizations(context).initError;
      Navigator.pop(context);
      _initFailedCounter = 0;
      checkActiveconnection(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(cardMsg),
      ));
      controller.closeBluetoothConnection(device.address);
      initCompleted = false;
      return initCompleted;
    }
  }

  Future<bool> _initMpos(Uint8List authToken, MPOSController controller,
      BluetoothDevice device) async {
    bool initCompleted;
    try {
      await initSDK(authToken: authToken);
      print("Librería Universal de Pagos inicializada!");
      initCompleted = true;
    } on PlatformException {
      initCompleted = await _catchPlatformException(controller, device);
      return initCompleted;
    } catch (e) {
      String cardMsg = getLocalizations(context).initError;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(cardMsg),
      ));
      controller.closeBluetoothConnection(device.address);
      initCompleted = false;
      return initCompleted;
    }

    return initCompleted;
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    final controller = MPOSController.instance;

    showCircularProgressDialog(context, getLocalizations(context).connecting);
    try {
      if (!_activeConnection) {
        await controller.openBluetoothConnection(device);
        controller.setActiveConnectionByAddress(device.address);
      }

      checkActiveconnection(false);

      Uint8List? authToken = await _initToken(controller, device);
      bool initMpos;
      if (authToken == null) {
        return;
      } else {
        initMpos = await _initMpos(authToken, controller, device);
        if (!initMpos) {
          return;
        }
      }

      // inicializamos EMV en este MPOS recién conectado
      await emvPreTransaction();

      // sincronizamos la hora del movil con el MPOS
      await controller.syncDateTime();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getLocalizations(context).connected),
      ));
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${getLocalizations(context).internalError}\n$e"),
      ));
    }
    Navigator.pop(context);
    //return initCompleted;
  }

  void _onTapManualEntry() {
    final platformInfo = _platformInfo;
    if (platformInfo == null) return;
    Navigator.pushNamed(
      context,
      AmountInputView.route,
      arguments: TransactionArgs(
        platformInfo: platformInfo,
        entryMode: EntryMode.Manual,
        showNumericKeyboard: !_hasKeypad,
        supportedCardTypes: _supportedCardTypes,
        emvTransactionType: EmvTransactionType.Goods,
      ),
    );
  }

  void _onTapTransaction() {
    int? transactionValue = transactionTypeOptions[_selectedTransactionType];

    if(transactionValue != null){
      print("Tipo de transacción seleccionado: $_selectedTransactionType con valor $transactionValue");
      // Aquí puedes agregar la lógica para procesar el valor del mapa processTransaction(transactionValue);

      final platformInfo = _platformInfo;
      if (platformInfo == null) return;
      if(transactionValue != EmvTransactionType.Void){
        Navigator.pushNamed(
          context,
          AmountInputView.route,
          arguments: TransactionArgs(
            platformInfo: platformInfo,
            entryMode: EntryMode.Magstripe,
            showNumericKeyboard: !_hasKeypad,
            supportedCardTypes: _supportedCardTypes,
            emvTransactionType: transactionValue,
          ),
        );
      }else{
        Navigator.pushNamed(
          context,
          StanInputView.route,
          arguments: TransactionArgs(
            platformInfo: platformInfo,
            entryMode: EntryMode.Magstripe,
            showNumericKeyboard: !_hasKeypad,
            supportedCardTypes: _supportedCardTypes,
            emvTransactionType: EmvTransactionType.Void,
          ),
        );
      }

    }

  }

 // Suma de los márgenes verticales y el botón
  int _getVerticalPadding() {
    return 10 + 10 + 20 + 60 + 20;
  }

  // Altura disponible para la imagen
  double _getRemainingHeight(BoxConstraints constraints, int totalVerticalPadding){
    return constraints.maxHeight - totalVerticalPadding;
  }

  // Devuelve true si la imagen tiene suficiente espacio para ser mostrada
  bool _getShowImage(double remainingHeight){
    return remainingHeight > 100;
  }

  // Obtiene la el valor de la altura de la imagen
  double _getCardHeight(bool showImage, double remainingHeight){
    return showImage ? remainingHeight * 0.5 : 0;
  }

  double _getDropdownWidth(BoxConstraints constraints){
    if (constraints.maxHeight > constraints.maxWidth) {
      // Pantalla vertical
      return constraints.maxWidth - 40;
    } else {
      // Pantalla horizontal
      return constraints.maxWidth * 0.6;
    }
  }

  double _buttonWidth(BoxConstraints constraints){
    if (constraints.maxHeight > constraints.maxWidth) {
      // Pantalla vertical
      return constraints.maxWidth - 40;
    } else {
      // Pantalla horizontal
      return constraints.maxWidth * 0.6;
    }
  }

}
