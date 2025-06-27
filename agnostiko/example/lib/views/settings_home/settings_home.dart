import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';

import '../../dialogs/language_select_dialog.dart';
import '../../utils/keypad.dart';
import '../settings_keys/settings_keys.dart';
import '../settings_params/settings_params.dart';
import '../settings_tests/settings_tests.dart';
import '../../utils/locale.dart';

class SettingsHomeView extends StatefulWidget {
  static String route = "/settings";

  @override
  _SettingsHomeViewState createState() => _SettingsHomeViewState();
}

class _SettingsHomeViewState extends State<SettingsHomeView> {
  bool _hasEmvModule = false;
  bool _isMe60 = false;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      final platformInfo = await getPlatformInfo();
      final deviceName = await getModel();
      setState(() {
        _hasEmvModule = platformInfo.hasEmvModule;
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
            Navigator.pushNamed(context, SettingsTestsView.route);
          } else if (digit == 2) {
            showLanguageSelectDialog(context);
          } else if (digit == 3) {
            Navigator.pushNamed(context, SettingsKeysView.route);
          } else if (digit == 4) {
            Navigator.pushNamed(context, SettingsParamsView.route);
          }
        },
        onEscape: () {
          Navigator.popUntil(context, (route) => route.isFirst == true);
        },
        onBackspace: () {
          Navigator.popUntil(context, (route) => route.isFirst == true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(getLocalizations(context).settings),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                enableFeedback: true,
                leading: const Icon(Icons.settings_overscan),
                title: Text(
                  _isMe60
                      ? "1. ${getLocalizations(context).tests}"
                      : getLocalizations(context).tests,
                ),
                onTap: () {
                  Navigator.pushNamed(context, SettingsTestsView.route);
                },
              ),
              ListTile(
                enableFeedback: true,
                leading: const Icon(Icons.language),
                title: Text(
                  _isMe60
                      ? "2. ${getLocalizations(context).language}"
                      : getLocalizations(context).language,
                ),
                onTap: () {
                  showLanguageSelectDialog(context);
                },
              ),
              ListTile(
                enabled: true,
                enableFeedback: true,
                leading: const Icon(Icons.lock),
                title: Text(_isMe60
                    ? "3. ${getLocalizations(context).keys}"
                    : getLocalizations(context).keys),
                onTap: () =>
                    Navigator.pushNamed(context, SettingsKeysView.route),
              ),
              ListTile(
                enabled: _hasEmvModule,
                enableFeedback: true,
                leading: const Icon(Icons.settings),
                title: Text(_isMe60
                    ? "4. ${getLocalizations(context).emvParameters}"
                    : getLocalizations(context).emvParameters),
                onTap: () =>
                    Navigator.pushNamed(context, SettingsParamsView.route),
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
