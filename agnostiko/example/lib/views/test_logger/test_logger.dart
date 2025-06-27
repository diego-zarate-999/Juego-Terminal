import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../utils/keypad.dart';
import '../../utils/locale.dart';
import '../../utils/log_test.dart';

class LogMessage {
  final String message;
  final Color color;

  LogMessage(this.message, this.color);
}

class CustomLogOutput extends LogOutput {
  final Function(String, Color) onLog;

  CustomLogOutput(this.onLog);

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      Color color;
      switch (event.level) {
        case Level.debug:
          color = Colors.green;
          break;
        case Level.info:
          color = Colors.blue;
          break;
        case Level.warning:
          color = Colors.yellow;
          break;
        case Level.error:
          color = Colors.red;
          break;
        default:
          color = Colors.black;
      }
      onLog(line, color);
    }
  }
}

class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level.value >= level!.value) {
      return true;
    }
    return false;
  }
}

var logger = Logger();

class TestLoggerView extends StatefulWidget {
  static String route = "/test/logger";

  @override
  _TestLoggerViewState createState() => _TestLoggerViewState();
}

class _TestLoggerViewState extends State<TestLoggerView> {
  List<LogMessage> _logs = [];

  @override
  void initState() {
    super.initState();

    // Para Linux no mostramos la caja alrededor de los logs para ahorrar en
    // espacio de pantalla
    bool noBoxing = Platform.isLinux;
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0, // No stack trace
        errorMethodCount: 0,
        lineLength: 0,
        colors: false,
        printEmojis: false,
        printTime: false,
        noBoxingByDefault: noBoxing,
      ),
      filter: CustomLogFilter(),
      output: CustomLogOutput((log, color) {
        setState(() {
          _logs.add(LogMessage(log, color));
        });
      }),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as List<LogTest>;
      _runTestSet(args);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: rawKeypadHandler(
        context,
        onEscape: () {
          Navigator.pop(context, (route) => true);
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text("Logs"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    'Logs',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          _logs[index].message,
                          style: TextStyle(
                            fontSize: 12,
                            color: _logs[index].color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resultLogger(Future<LogTestResult> Function() function, String title,
      {String? failMsg, String? successMsg}) async {
    try {
      final result = await function();
      _generateResultLog(title, result,
          failMsg: failMsg, successMsg: successMsg);
    } catch (e, stackTrace) {
      print(stackTrace);
      _generateResultLog(title, LogTestResult(false), failMsg: e.toString());
    }
  }

  void _generateResultLog(String title, LogTestResult result,
      {String? failMsg, String? successMsg}) {
    if (result.success) {
      if(result.infoMsg != null){
        logger.i("${getLocalizations(context).testLog} $title : ${result.infoMsg}");
      }
      else if(successMsg != null) {
        logger.i("${getLocalizations(context).testLog} $title : $successMsg");
      }
      else{
        logger.i(
            "${getLocalizations(context).testLog} $title : ${getLocalizations(context).succeedTest}");
      }
    } else {
      if (failMsg != null)
        logger.e("${getLocalizations(context).testLog} $title : $failMsg");
      else
        logger.e(
            "${getLocalizations(context).testLog} $title : ${getLocalizations(context).failedTest}");
    }
  }

  Future<void> _runTestSet(List<LogTest> list) async {
    for (int i = 0; i < list.length; i++) {
      await _resultLogger(list[i].function, list[i].title);
    }
    logger.d(getLocalizations(context).testsFinished);
  }
}
