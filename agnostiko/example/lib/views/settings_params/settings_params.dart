import 'package:agnostiko/device/src/device.dart';
import 'package:agnostiko_example/utils/keypad.dart';
import 'package:flutter/material.dart';

import '../settings_terminal_params/settings_terminal_params.dart';
import '../settings_aid_list/settings_aid_list.dart';
import '../settings_capk_list/settings_capk_list.dart';
import '../../utils/locale.dart';

class SettingsParamsView extends StatefulWidget {
  static String route = "/settings/params";

  @override
  _SettingsParamsViewState createState() => _SettingsParamsViewState();
}

class _SettingsParamsViewState extends State<SettingsParamsView> {
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
            Navigator.pushNamed(context, SettingsAidListView.route);
          } else if (digit == 2) {
            Navigator.pushNamed(context, SettingsCAPKListView.route);
          } else if (digit == 3) {
            Navigator.pushNamed(context, SettingsTerminalParamsView.route);
          }
        },
        onEscape: () {
          Navigator.pop(context, (route) => true);
        },
        onBackspace: () {
          Navigator.pop(context, (route) => true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).emvParameters),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60 ? '1. AID' : 'AID'),
                onTap: () {
                  Navigator.pushNamed(context, SettingsAidListView.route);
                },
              ),
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60 ? '2. CAPK' : 'CAPK'),
                onTap: () {
                  Navigator.pushNamed(context, SettingsCAPKListView.route);
                },
              ),
              ListTile(
                enableFeedback: true,
                title: Text(_isMe60 ? '3. Terminal' : 'Terminal'),
                onTap: () {
                  Navigator.pushNamed(
                      context, SettingsTerminalParamsView.route);
                },
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
