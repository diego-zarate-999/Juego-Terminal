import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import '../../main.dart';
import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/parameters.dart';

class _LanguageOption {
  final String languageName;
  final String? languageTag;
  _LanguageOption(this.languageName, this.languageTag);
}

Future<int?> showLanguageSelectDialog(BuildContext context) async {
  final mediaQuery = MediaQuery.of(context);
  bool showTitle = mediaQuery.size.height > 320;
  bool hasKeypad = (await getPlatformInfo()).hasKeypad;

  List<_LanguageOption> languageOptions = [
    _LanguageOption("AUTO", null),
    _LanguageOption("English", "en"),
    _LanguageOption("Español", "es"),
  ];

  return showDialog<int?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: rawKeypadHandler(
          context,
          onDigit: (digit) {
            int index = digit - 1;
            if (index >= 0 && index < languageOptions.length) {
              _changeLanguage(context, languageOptions[index]);
            }
          },
        ),
        child: AlertDialog(
          title: showTitle
              ? Center(child: Text(getLocalizations(context).selectLanguage))
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: Container(
            height: (mediaQuery.size.height * 3) / 5,
            width: mediaQuery.size.width / 2,
            child: _languageList(context, languageOptions, hasKeypad),
          ),
        ),
      );
    },
  );
}

ListView _languageList(
  BuildContext context,
  List<_LanguageOption> languageOptions,
  bool hasKeypad,
) {
  return ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: languageOptions.asMap().entries.map((entry) {
        int index = entry.key;
        String languageName = entry.value.languageName;
        if (hasKeypad) {
          languageName = "${index + 1} - $languageName";
        }

        return ListTile(
          title: Text(languageName),
          onTap: () => _changeLanguage(context, entry.value),
        );
      }).toList(),
    ).toList(),
  );
}

void _changeLanguage(
  BuildContext context,
  _LanguageOption languageOption,
) async {
  final languageTag = languageOption.languageTag;

  try {
    if (languageTag != null) {
      final locale = Locale.fromSubtags(languageCode: languageTag);
      MyApp.setLocale(context, locale);
      await saveAppLocale(locale);
    } else {
      MyApp.setLocale(context, null);
      await clearAppLocale();
    }
  } catch (e) {}

  Navigator.pop(context);
}
