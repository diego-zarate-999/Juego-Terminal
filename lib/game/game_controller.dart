import 'package:flutter/material.dart';
import 'package:prueba_ag/game/game_state.dart';
import 'package:prueba_ag/game/level_generator.dart';

enum Clue { less, equal, greater, lost }

class GameController {
  late GameState _gameState;
  late LevelGenerator _levelGenerator;

  GameController() {
    _levelGenerator = EasyLevelGenerator();
    _gameState = _levelGenerator.generateLevel();
  }

  void initializeGame() {
    _gameState = _levelGenerator.generateLevel();
    debugPrint("Numero: ${_gameState.secretNumber}");
  }

  Clue makeAGuess(int guessedNumber) {
    _gameState.remainingAttempts = _gameState.remainingAttemps - 1;
    int secretNumber = _gameState.secretNumber;

    if (guessedNumber == secretNumber) {
      return Clue.equal;
    }

    if (_gameState.remainingAttemps == 0) {
      return Clue.lost;
    }

    if (guessedNumber > secretNumber) {
      return Clue.greater;
    } else {
      return Clue.less;
    }
  }

  int get remainingAttempts => _gameState.remainingAttemps;
  int get secretNumber => _gameState.secretNumber;
  void setLevelGenerator(LevelGenerator levelGenerator) =>
      _levelGenerator = levelGenerator;
}
