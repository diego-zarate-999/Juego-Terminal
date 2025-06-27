import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../dialogs/confirm_dialog.dart';
import '../../dialogs/param_input_dialog.dart';
import '../../dialogs/param_bitmap_dialog.dart';
import '../../utils/locale.dart';
import '../../utils/parameters.dart';

class SettingsTerminalParamsView extends StatefulWidget {
  static String route = "/settings/params/terminal";

  @override
  _SettingsTerminalParamsViewState createState() =>
      _SettingsTerminalParamsViewState();
}

class _SettingsTerminalParamsViewState
    extends State<SettingsTerminalParamsView> {
  TerminalParameters? _params;

  @override
  Widget build(BuildContext context) {
    if (_params == null) _loadParams();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Terminal'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Floor Limit'),
              subtitle: Text(_floorLimit?.toString() ?? '-'),
              onTap: _onTapFloorLimit,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Country Code'),
              subtitle: Text(_countryCode),
              onTap: _onTapCountryCode,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Transaction Currency Code'),
              subtitle: Text(_currencyCode),
              onTap: _onTapCurrencyCode,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Transaction Currency Exponent'),
              subtitle: Text(_params?.transactionCurrencyExp.toString() ?? '-'),
              onTap: _onTapCurrencyExponent,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Transaction Reference Currency Code'),
              subtitle: Text(_referenceCurrencyCode),
              onTap: _onTapReferenceCurrencyCode,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Transaction Reference Currency Exponent'),
              subtitle: Text(_params?.referenceCurrencyExp.toString() ?? '-'),
              onTap: _onTapReferenceCurrencyExponent,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Capabilities'),
              subtitle: Text(_terminalCapabilities),
              onTap: _onTapTerminalCapabilities,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Additional Terminal Capabilities'),
              subtitle: Text(_additionalTerminalCapabilities),
              onTap: _onTapAdditionalTerminalCapabilities,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Identification'),
              subtitle: Text(_params?.terminalId ?? '-'),
              onTap: _onTapTerminalId,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Threshold Value'),
              subtitle: Text(_thresholdValue?.toString() ?? '-'),
              onTap: _onTapThresholdValue,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Target Percentage'),
              subtitle: Text(_params?.targetPercentage.toString() ?? '-'),
              onTap: _onTapTargetPercentage,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Maximum Target Percentage'),
              subtitle: Text(_params?.maxTargetPercentage.toString() ?? '-'),
              onTap: _onTapMaxTargetPercentage,
            ),
            ListTile(
              enabled: false,
              title: Text('Acquirer Identification'),
              subtitle: Text(
                _params?.acquirerId.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enabled: false,
              title: Text('Merchant Identifier'),
              subtitle: Text(_params?.merchantId ?? '-'),
            ),
            ListTile(
              enabled: false,
              title: Text('Merchant Name and Location'),
              subtitle: Text(_params?.merchantNameAndLocation ?? '-'),
            ),
            ListTile(
              enabled: false,
              title: Text('Default DDOL'),
              subtitle: Text(
                _params?.defaultDDOL.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enabled: false,
              title: Text('Default TDOL'),
              subtitle: Text(
                _params?.defaultTDOL.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enableFeedback: true,
              title: Text('RESET'),
              onTap: _onTapReset,
            ),
          ],
        ).toList(),
      ),
    );
  }

  int? get _floorLimit {
    final hexStr = _params?.terminalFloorLimit.toHexStr() ?? '-';
    return int.tryParse(hexStr, radix: 16);
  }

  String get _countryCode {
    return _params?.terminalCountryCode.toHexStr() ?? '0000';
  }

  String get _currencyCode {
    return _params?.transactionCurrencyCode.toHexStr() ?? '0000';
  }

  String get _referenceCurrencyCode {
    return _params?.referenceCurrencyCode.toHexStr() ?? '0000';
  }

  String get _terminalCapabilities {
    return _params?.terminalCapabilities.toHexStr().toUpperCase() ?? '-';
  }

  String get _additionalTerminalCapabilities {
    return _params?.additionalTerminalCapabilities.toHexStr().toUpperCase() ??
        '-';
  }

  int? get _thresholdValue {
    final hexStr = _params?.thresholdValue.toHexStr() ?? '-';
    return int.tryParse(hexStr, radix: 16);
  }

  void _onTapFloorLimit() async {
    final floorLimitStr = await showParamInputDialog(
      context,
      paramName: "Terminal Floor Limit",
      paramValue: _floorLimit.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    if (floorLimitStr is String) {
      final floorInt = int.tryParse(floorLimitStr) ?? 0;
      final floorStr = floorInt.toRadixString(16).padLeft(8, '0');
      final floorBytes = floorStr.toHexBytes();

      _params?.terminalFloorLimit = floorBytes;
      await _saveParams();
      _loadParams();
    }
  }

  void _onTapCountryCode() async {
    final codeStr = await showParamInputDialog(
      context,
      paramName: "Terminal Country Code",
      paramValue: _countryCode.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 4,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
    );

    if (codeStr is String) {
      if (codeStr.length == 4) {
        _params?.terminalCountryCode = codeStr.toHexBytes();
        await _saveParams();
        _loadParams();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              getLocalizations(context)
                  .valueMustBeExactLength("Country Code", 4),
            ),
          ),
        );
      }
    }
  }

  void _onTapCurrencyCode() async {
    final codeStr = await showParamInputDialog(
      context,
      paramName: "Transaction Currency Code",
      paramValue: _currencyCode.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 4,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
    );

    if (codeStr is String) {
      if (codeStr.length == 4) {
        _params?.transactionCurrencyCode = codeStr.toHexBytes();
        await _saveParams();
        _loadParams();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              getLocalizations(context)
                  .valueMustBeExactLength("Currency Code", 4),
            ),
          ),
        );
      }
    }
  }

  void _onTapCurrencyExponent() async {
    final exponentStr = await showParamInputDialog(
      context,
      paramName: "Transaction Currency Exponent",
      paramValue: _params?.transactionCurrencyExp.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    if (exponentStr is String) {
      _params?.transactionCurrencyExp = int.tryParse(exponentStr) ?? 0;
      await _saveParams();
      _loadParams();
    }
  }

  void _onTapReferenceCurrencyCode() async {
    final codeStr = await showParamInputDialog(
      context,
      paramName: "Transaction Reference Currency Code",
      paramValue: _referenceCurrencyCode.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 4,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
    );

    if (codeStr is String) {
      if (codeStr.length == 4) {
        _params?.referenceCurrencyCode = codeStr.toHexBytes();
        await _saveParams();
        _loadParams();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              getLocalizations(context)
                  .valueMustBeExactLength("Reference Currency Code", 4),
            ),
          ),
        );
      }
    }
  }

  void _onTapReferenceCurrencyExponent() async {
    final exponentStr = await showParamInputDialog(
      context,
      paramName: "Transaction Reference Currency Exponent",
      paramValue: _params?.referenceCurrencyExp.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    if (exponentStr is String) {
      _params?.referenceCurrencyExp = int.tryParse(exponentStr) ?? 0;
      await _saveParams();
      _loadParams();
    }
  }

  void _onTapTerminalCapabilities() async {
    final bitmap = getTerminalCapabilitiesBitmap();
    final bytes = _params?.terminalCapabilities;

    if (bytes is Uint8List) {
      bitmap.loadFromBytes(bytes);

      final newBitmap = await showParamBitmapDialog(context, bitmap: bitmap);

      if (newBitmap is EmvConfigBitmap) {
        _params?.terminalCapabilities = newBitmap.toBytes();
      }
      await _saveParams();
      _loadParams();
    }
  }

  void _onTapAdditionalTerminalCapabilities() async {
    final bitmap = getAdditionalTerminalCapabilitiesBitmap();
    final bytes = _params?.additionalTerminalCapabilities;

    if (bytes is Uint8List) {
      bitmap.loadFromBytes(bytes);

      final newBitmap = await showParamBitmapDialog(context, bitmap: bitmap);

      if (newBitmap is EmvConfigBitmap) {
        _params?.additionalTerminalCapabilities = newBitmap.toBytes();
      }
      await _saveParams();
      _loadParams();
    }
  }

  void _onTapTerminalId() async {
    final idStr = await showParamInputDialog(
      context,
      paramName: "Terminal Identification",
      paramValue: _params?.terminalId ?? '',
      inputFormatters: [
        // solo alfanúmerico de acuerdo a su definición
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
      ],
      maxLength: 8,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
    );

    if (idStr is String) {
      if (idStr.length == 8) {
        _params?.terminalId = idStr;
        await _saveParams();
        _loadParams();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              getLocalizations(context)
                  .valueMustBeExactLength("Terminal ID", 8),
            ),
          ),
        );
      }
    }
  }

  void _onTapThresholdValue() async {
    final newThresholdStr = await showParamInputDialog(
      context,
      paramName: "Threshold Value",
      paramValue: _thresholdValue?.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    if (newThresholdStr is String) {
      final thresholdInt = int.tryParse(newThresholdStr) ?? 0;
      final thresholdStr = thresholdInt.toRadixString(16).padLeft(8, '0');
      final thresholdBytes = thresholdStr.toHexBytes();

      _params?.thresholdValue = thresholdBytes;
      await _saveParams();
      _loadParams();
    }
  }

  void _onTapTargetPercentage() async {
    final targetPercentageStr = await showParamInputDialog(
      context,
      paramName: "Target Percentage",
      paramValue: _params?.targetPercentage.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    if (targetPercentageStr is String) {
      await _validateAndSaveTargetPercentage(targetPercentageStr);
    }
  }

  Future<void> _validateAndSaveTargetPercentage(
    String targetPercentageStr,
  ) async {
    int value = int.tryParse(targetPercentageStr) ?? 0;

    if (value < 0 || value > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getLocalizations(context)
                .valueMustBeInRange("Target Percentage", 0, 99),
          ),
        ),
      );
      return;
    }

    _params?.targetPercentage = value;

    await _saveParams();
    _loadParams();
  }

  void _onTapMaxTargetPercentage() async {
    final maxTargetPercentageStr = await showParamInputDialog(
      context,
      paramName: "Maximum Target Percentage",
      paramValue: _params?.maxTargetPercentage.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    if (maxTargetPercentageStr is String) {
      await _validateAndSaveMaxTargetPercentage(maxTargetPercentageStr);
    }
  }

  Future<void> _validateAndSaveMaxTargetPercentage(
    String maxTargetPercentageStr,
  ) async {
    int value = int.tryParse(maxTargetPercentageStr) ?? 0;

    if (value < 0 || value > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getLocalizations(context)
                .valueMustBeInRange("Maximum Target Percentage", 0, 99),
          ),
        ),
      );
      return;
    }

    _params?.maxTargetPercentage = value;

    await _saveParams();
    _loadParams();
  }

  void _onTapReset() {
    showConfirmDialog(
      context,
      message: getLocalizations(context).confirmResetTerminalParameters,
      onAccept: () async {
        await resetTerminalParameters();
        Navigator.pop(context);
        _loadParams();
      },
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  Future<void> _loadParams() async {
    final params = await loadTerminalParameters();

    setState(() {
      _params = params;
    });
  }

  Future<void> _saveParams() async {
    final params = _params ?? await loadTerminalParameters();
    await saveTerminalParameters(params);
    print("Parameters modified!!!");
  }
}
