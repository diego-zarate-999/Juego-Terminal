import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_ag/dialogs/circular_progress_dialog.dart';
import 'package:prueba_ag/game/game_controller.dart';
import 'package:prueba_ag/game/level_generator.dart';
import 'package:prueba_ag/utils/locale.dart';
import 'package:prueba_ag/utils/printer_templates.dart';
import 'package:prueba_ag/providers/history_provider.dart';
import 'package:prueba_ag/widgets/history_container.dart';
import 'package:prueba_ag/widgets/level_selector.dart';
import 'package:prueba_ag/widgets/lives_counter.dart';
import 'package:prueba_ag/widgets/number_text_field.dart';
import 'package:prueba_ag/widgets/numbers_container.dart';

enum GameLevel { easy, medium, advanced, extreme }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static String route = "/game";

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController _gameController = GameController();

  List<int> _lessThan = [];
  List<int> _greaterThan = [];

  int _remainingAttempts = 5;
  int _levelSliderValue = 0;

  void _onSetGameLevel(GameLevel selectedLevel) {
    switch (selectedLevel) {
      case GameLevel.easy:
        _levelSliderValue = 0;
        _gameController.setLevelGenerator(EasyLevelGenerator());
        break;

      case GameLevel.medium:
        _levelSliderValue = 1;
        _gameController.setLevelGenerator(MediumLevelGenerator());
        break;

      case GameLevel.advanced:
        _levelSliderValue = 2;
        _gameController.setLevelGenerator(AdvancedLevelGenerator());
        break;

      case GameLevel.extreme:
        _levelSliderValue = 3;
        _gameController.setLevelGenerator(ExtremeLevelGenerator());
        break;
    }

    _startNewGame();
  }

  void _startNewGame() {
    _gameController.initializeGame();
    setState(() {
      _lessThan = [];
      _greaterThan = [];
      _remainingAttempts = _gameController.remainingAttempts;
    });
  }

  void _handleUserGuess(int guessedNumber) {
    Clue clue = _gameController.makeAGuess(guessedNumber);

    switch (clue) {
      case Clue.equal:
        {
          _addToHistory(true);
          _showMessage("¡Has ganado!");
        }
        break;

      case Clue.less:
        {
          setState(() {
            _remainingAttempts = _gameController.remainingAttempts;
            _lessThan.add(guessedNumber);
          });
        }
        break;

      case Clue.greater:
        {
          setState(() {
            _remainingAttempts = _gameController.remainingAttempts;
            _greaterThan.add(guessedNumber);
          });
        }
        break;

      case Clue.lost:
        {
          _addToHistory(false);
          _showMessage("¡Has perdido!");
        }
        break;
    }
  }

  void _addToHistory(bool userWon) {
    context
        .read<HistoryProvider>()
        .updateHistory(_gameController.secretNumber, userWon);

    _startNewGame();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(message),
      ),
    );
  }

  Future<void> _printHistory(PrinterScript printerScript) async {
    try {
      final ticketWidth = await getPaperWidth();
      final threeQuartersWidth = (ticketWidth * 3) ~/ 4;

      await printScript(
        printerScript,
        bottomFeed: false,
        customPaperWidth: threeQuartersWidth,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error imprimiendo"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Adivina el numero'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                List<PrinterObject> lines = [];
                lines.add(PrinterText(
                  "Historial",
                  format: TextFormat(
                    fontSize: 24,
                    bold: true,
                  ),
                ));

                final printerScript = PrinterScript(lines);
                await _printHistory(printerScript);
              },
              icon: const Icon(Icons.print),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NumberTextField(
                      onEnteredNumber: _handleUserGuess,
                    ),
                    const SizedBox(
                      width: 32,
                    ),
                    LivesCounter(_remainingAttempts),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  children: [
                    Expanded(
                      child: NumbersContainer(
                        title: "Mayor que",
                        data: _lessThan,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: NumbersContainer(
                        title: "Menor que",
                        data: _greaterThan,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: HistoryContainer(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 64,
                ),
                LevelSelector(
                  _levelSliderValue,
                  _onSetGameLevel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
