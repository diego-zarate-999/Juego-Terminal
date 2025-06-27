import 'package:flutter/material.dart';

import '../../utils/parameters.dart';
import '../settings_capk/settings_capk.dart';

import 'package:agnostiko/agnostiko.dart';

class SettingsCAPKListView extends StatefulWidget {
  static String route = "/settings/params/capk_list";

  @override
  _SettingsCAPKListViewState createState() => _SettingsCAPKListViewState();
}

class _SettingsCAPKListViewState extends State<SettingsCAPKListView> {
  Widget? _listView;

  @override
  Widget build(BuildContext context) {
    if (_listView == null) _createViewWidget();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('CAPK'),
      ),
      body: _listView,
    );
  }

  void _createViewWidget() async {
    final tiles = await _getCAPKListTiles();

    setState(() {
      // Por alguna razón, un ListView con 0 elementos genera error y por eso
      // verificamos que haya elementos en la lista
      if (tiles.isNotEmpty) {
        _listView = ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList(),
        );
      }
    });
  }

  Future<List<ListTile>> _getCAPKListTiles() async {
    print("CARGANDO TILES...");
    final capkList = await loadCAPKList();

    return capkList.asMap().entries.map((entry) {
      final app = entry.value;
      final appIndex = entry.key;
      return _getCAPKTile(app, appIndex);
    }).toList();
  }

  ListTile _getCAPKTile(CAPK capk, int capkIndexInList) {
    final rid = capk.rid.toHexStr().toUpperCase();
    final keyIndex = capk.index;

    return ListTile(
      enableFeedback: true,
      title: Text("RID: $rid - Index: $keyIndex"),
      onTap: () {
        Navigator.pushNamed(
          context,
          SettingsCAPKView.route,
          arguments: capkIndexInList,
        );
      },
    );
  }
}
