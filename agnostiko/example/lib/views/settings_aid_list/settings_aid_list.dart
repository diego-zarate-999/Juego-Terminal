import 'package:flutter/material.dart';

import '../../utils/parameters.dart';
import '../../dialogs/confirm_dialog.dart';
import '../settings_aid_params/settings_aid_params.dart';

import 'package:agnostiko/agnostiko.dart';

class SettingsAidListView extends StatefulWidget {
  static String route = "/settings/params/aid_list";

  @override
  _SettingsAidListViewState createState() => _SettingsAidListViewState();
}

class _SettingsAidListViewState extends State<SettingsAidListView> {
  Widget? _listView;

  @override
  Widget build(BuildContext context) {
    if (_listView == null) _createViewWidget();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('AID'),
      ),
      body: _listView,
    );
  }

  void _createViewWidget() async {
    final tiles = await _getAidListTiles();

    if (mounted) {
      setState(() {
        // Por alguna razón, un ListView con 0 elementos genera error y por eso
        // verificamos que haya elementos en la lista
        if (tiles.isNotEmpty) {
          _listView = ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                ...tiles,
                ListTile(
                  enableFeedback: true,
                  title: Text('RESET'),
                  onTap: _onTapReset,
                ),
              ],
            ).toList(),
          );
        }
      });
    }
  }

  Future<List<ListTile>> _getAidListTiles() async {
    final appList = await loadEmvAppList();

    return appList.asMap().entries.map((entry) {
      final app = entry.value;
      final appIndex = entry.key;
      return _getAppTile(app, appIndex);
    }).toList();
  }

  ListTile _getAppTile(EmvApp app, int appIndex) {
    return ListTile(
      enableFeedback: true,
      title: Text(app.aid.toHexStr().toUpperCase()),
      onTap: () {
        Navigator.pushNamed(
          context,
          SettingsAidParamsView.route,
          arguments: appIndex,
        );
      },
    );
  }

  void _onTapReset() {
    showConfirmDialog(
      context,
      message:
          "Está seguro que desea resetear la lista de AID y sus parámetros?",
      onAccept: () async {
        await resetEmvAppList();
        Navigator.pop(context);
      },
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }
}
