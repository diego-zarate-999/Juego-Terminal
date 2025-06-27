import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../dialogs/param_bitmap_dialog.dart';
import '../../dialogs/param_input_dialog.dart';
import '../../utils/locale.dart';
import '../../utils/parameters.dart';

class SettingsAidParamsView extends StatefulWidget {
  static String route = "/settings/params/aid";

  @override
  _SettingsAidParamsViewState createState() => _SettingsAidParamsViewState();
}

class _SettingsAidParamsViewState extends State<SettingsAidParamsView> {
  EmvApp? _appData;

  @override
  Widget build(BuildContext context) {
    if (_appData == null) _loadApp();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('AID'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              enabled: false,
              title: Text('Application Identifier (AID)'),
              subtitle: Text(_appData?.aid.toHexStr().toUpperCase() ?? '-'),
            ),
            ListTile(
              enabled: false,
              title: Text('Application Version Number'),
              subtitle: Text(
                _appData?.appVersionNum.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Action Code - Denial'),
              subtitle: Text(
                _appData?.tacDenial.toHexStr().toUpperCase() ?? '-',
              ),
              onTap: _onTapTacDenial,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Action Code - Online'),
              subtitle: Text(
                _appData?.tacOnline.toHexStr().toUpperCase() ?? '-',
              ),
              onTap: _onTapTacOnline,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Action Code - Default'),
              subtitle: Text(
                _appData?.tacDefault.toHexStr().toUpperCase() ?? '-',
              ),
              onTap: _onTapTacDefault,
            ),
            ListTile(
              enabled: false,
              title: Text('Terminal Risk Management Data'),
              subtitle: Text(
                _appData?.riskManagementData?.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Terminal Floor Limit'),
              subtitle: Text(_floorLimit?.toString() ?? '-'),
              onTap: _onTapFloorLimit,
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
              subtitle: Text(_appData?.targetPercentage?.toString() ?? '-'),
              onTap: _onTapTargetPercentage,
            ),
            ListTile(
              enableFeedback: true,
              title: Text('Maximum Target Percentage'),
              subtitle: Text(_appData?.maxTargetPercentage?.toString() ?? '-'),
              onTap: _onTapMaxTargetPercentage,
            ),
          ],
        ).toList(),
      ),
    );
  }

  int? get _floorLimit {
    final hexStr = _appData?.terminalFloorLimit?.toHexStr() ?? '-';
    return int.tryParse(hexStr, radix: 16);
  }

  int? get _thresholdValue {
    final hexStr = _appData?.thresholdValue?.toHexStr() ?? '-';
    return int.tryParse(hexStr, radix: 16);
  }

  void _loadApp() async {
    try {
      final aidIndex = ModalRoute.of(context)?.settings.arguments as int;
      final appList = await loadEmvAppList();

      final app = appList[aidIndex];

      setState(() {
        _appData = app;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _onTapTacDenial() async {
    final tacBitmap = getTacDenialBitmap();
    final tacBytes = _appData?.tacDenial;

    if (tacBytes is Uint8List) {
      tacBitmap.loadFromBytes(tacBytes);

      final newTac = await showParamBitmapDialog(context, bitmap: tacBitmap);

      if (newTac is EmvConfigBitmap) {
        final appList = await loadEmvAppList();
        final aidIndex = ModalRoute.of(context)?.settings.arguments as int;

        appList[aidIndex].tacDenial = newTac.toBytes();

        await saveEmvAppList(appList);
        _loadApp();
      }
    }
  }

  void _onTapTacOnline() async {
    final tacBitmap = getTacOnlineBitmap();
    final tacBytes = _appData?.tacOnline;

    if (tacBytes is Uint8List) {
      tacBitmap.loadFromBytes(tacBytes);

      final newTac = await showParamBitmapDialog(context, bitmap: tacBitmap);

      if (newTac is EmvConfigBitmap) {
        final appList = await loadEmvAppList();
        final aidIndex = ModalRoute.of(context)?.settings.arguments as int;

        appList[aidIndex].tacOnline = newTac.toBytes();

        await saveEmvAppList(appList);
        _loadApp();
      }
    }
  }

  void _onTapTacDefault() async {
    final tacBitmap = getTacDefaultBitmap();
    final tacBytes = _appData?.tacDefault;

    if (tacBytes is Uint8List) {
      tacBitmap.loadFromBytes(tacBytes);

      final newTac = await showParamBitmapDialog(context, bitmap: tacBitmap);

      if (newTac is EmvConfigBitmap) {
        final appList = await loadEmvAppList();
        final aidIndex = ModalRoute.of(context)?.settings.arguments as int;

        appList[aidIndex].tacDefault = newTac.toBytes();

        await saveEmvAppList(appList);
        _loadApp();
      }
    }
  }

  void _onTapFloorLimit() async {
    final newFloorLimit = await showParamInputDialog(
      context,
      paramName: "Terminal Floor Limit",
      paramValue: _floorLimit?.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    final appList = await loadEmvAppList();
    final aidIndex = ModalRoute.of(context)?.settings.arguments as int;

    if (newFloorLimit is String) {
      if (newFloorLimit.isEmpty) {
        appList[aidIndex].terminalFloorLimit = null;
      } else {
        final floorInt = int.tryParse(newFloorLimit);
        final floorStr = floorInt?.toRadixString(16).padLeft(8, '0');
        final floorBytes = floorStr?.toHexBytes();

        appList[aidIndex].terminalFloorLimit = floorBytes;
      }

      await saveEmvAppList(appList);
      _loadApp();
    }
  }

  void _onTapThresholdValue() async {
    final newThreshold = await showParamInputDialog(
      context,
      paramName: "Threshold Value",
      paramValue: _thresholdValue?.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    final appList = await loadEmvAppList();
    final aidIndex = ModalRoute.of(context)?.settings.arguments as int;

    if (newThreshold is String) {
      if (newThreshold.isEmpty) {
        appList[aidIndex].thresholdValue = null;
      } else {
        final thresholdInt = int.tryParse(newThreshold);
        final thresholdStr = thresholdInt?.toRadixString(16).padLeft(8, '0');
        final thresholdBytes = thresholdStr?.toHexBytes();

        appList[aidIndex].thresholdValue = thresholdBytes;
      }

      await saveEmvAppList(appList);
      _loadApp();
    }
  }

  void _onTapTargetPercentage() async {
    final targetPercentageStr = await showParamInputDialog(
      context,
      paramName: "Target Percentage",
      paramValue: _appData?.targetPercentage?.toString() ?? '',
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
    final appList = await loadEmvAppList();
    final aidIndex = ModalRoute.of(context)?.settings.arguments as int;

    if (targetPercentageStr.isEmpty) {
      appList[aidIndex].targetPercentage = null;
    } else {
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

      appList[aidIndex].targetPercentage = value;
    }

    await saveEmvAppList(appList);
    _loadApp();
  }

  void _onTapMaxTargetPercentage() async {
    final maxTargetPercentageStr = await showParamInputDialog(
      context,
      paramName: "Maximum Target Percentage",
      paramValue: _appData?.maxTargetPercentage?.toString() ?? '',
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
    final appList = await loadEmvAppList();
    final aidIndex = ModalRoute.of(context)?.settings.arguments as int;

    if (maxTargetPercentageStr.isEmpty) {
      appList[aidIndex].maxTargetPercentage = null;
    } else {
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

      appList[aidIndex].maxTargetPercentage = value;
    }

    await saveEmvAppList(appList);
    _loadApp();
  }
}
