import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../utils/parameters.dart';

class SettingsCAPKView extends StatefulWidget {
  static String route = "/settings/params/capk";

  @override
  _SettingsCAPKViewState createState() => _SettingsCAPKViewState();
}

class _SettingsCAPKViewState extends State<SettingsCAPKView> {
  CAPK? _capkData;

  @override
  Widget build(BuildContext context) {
    if (_capkData == null) _loadCAPK();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('CAPK'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              enabled: false,
              title: Text('RID'),
              subtitle: Text(_capkData?.rid.toHexStr().toUpperCase() ?? '-'),
            ),
            ListTile(
              enabled: false,
              title: Text('Index'),
              subtitle: Text(_capkData?.index.toString() ?? '-'),
            ),
            ListTile(
              enabled: false,
              title: Text('Exponent'),
              subtitle: Text(
                _capkData?.exponent.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enabled: false,
              title: Text('Modulus'),
              subtitle: Text(
                _capkData?.modulus.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enabled: false,
              title: Text('Checksum'),
              subtitle: Text(
                _capkData?.checksum.toHexStr().toUpperCase() ?? '-',
              ),
            ),
            ListTile(
              enabled: false,
              title: Text('Expiration Date'),
              subtitle: Text(_expDateStr),
            ),
          ],
        ).toList(),
      ),
    );
  }

  String get _expDateStr {
    int? year = _capkData?.expirationDate.year;
    int? month = _capkData?.expirationDate.month;
    int? day = _capkData?.expirationDate.day;

    return "$year - $month - $day";
  }

  void _loadCAPK() async {
    try {
      final capkIndexInList = ModalRoute.of(context)?.settings.arguments as int;
      final capkList = await loadCAPKList();

      final capk = capkList[capkIndexInList];

      setState(() {
        _capkData = capk;
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}
