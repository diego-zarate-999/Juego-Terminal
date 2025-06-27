import 'dart:math';

import 'package:prueba_ag/game/game_state.dart';

final rnd = Random();

abstract class LevelGenerator {
  late int _upperLimit;
  late int _inititalNumberOfAttemps;

  int get upperLimit => _upperLimit;
  int get inititalNumberOfAttemps => _inititalNumberOfAttemps;
  GameState generateLevel();
}

class EasyLevelGenerator extends LevelGenerator {
  EasyLevelGenerator() {
    _upperLimit = 10;
    _inititalNumberOfAttemps = 5;
  }

  @override
  GameState generateLevel() {
    int secretNumber = rnd.nextInt(_upperLimit) + 1;
    return GameState(_inititalNumberOfAttemps, secretNumber);
  }
}

class MediumLevelGenerator extends LevelGenerator {
  MediumLevelGenerator() {
    _upperLimit = 20;
    _inititalNumberOfAttemps = 8;
  }

  @override
  GameState generateLevel() {
    int secretNumber = rnd.nextInt(_upperLimit) + 1;
    return GameState(_inititalNumberOfAttemps, secretNumber);
  }
}

class AdvancedLevelGenerator extends LevelGenerator {
  AdvancedLevelGenerator() {
    _upperLimit = 100;
    _inititalNumberOfAttemps = 15;
  }

  @override
  GameState generateLevel() {
    int secretNumber = rnd.nextInt(_upperLimit) + 1;
    return GameState(_inititalNumberOfAttemps, secretNumber);
  }
}

class ExtremeLevelGenerator extends LevelGenerator {
  ExtremeLevelGenerator() {
    _upperLimit = 1000;
    _inititalNumberOfAttemps = 25;
  }

  @override
  GameState generateLevel() {
    int secretNumber = rnd.nextInt(_upperLimit) + 1;
    return GameState(_inititalNumberOfAttemps, secretNumber);
  }
}
