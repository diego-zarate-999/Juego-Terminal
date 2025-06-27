import 'package:flutter/material.dart';
import 'package:prueba_ag/views/game_screen/game_screen.dart';

class LevelSelector extends StatelessWidget {
  const LevelSelector(this.value, this.onLevelChange, {super.key});

  final int value;
  final Function(GameLevel) onLevelChange;

  void _chooseLevel(double chosenValue) {
    int selectedValue = chosenValue.toInt();
    GameLevel gameLevel = GameLevel.easy;

    switch (selectedValue) {
      case 0:
        gameLevel = GameLevel.easy;
        break;
      case 1:
        gameLevel = GameLevel.medium;
        break;

      case 2:
        gameLevel = GameLevel.advanced;
        break;

      case 3:
        gameLevel = GameLevel.extreme;
        break;

      default:
        throw Exception("Nivel inexistente.");
    }

    onLevelChange(gameLevel);
  }

  String _getLevelName() {
    int selectedValue = value.toInt();
    switch (selectedValue) {
      case 0:
        return "Fácil";

      case 1:
        return "Medio";

      case 2:
        return "Avanzado";

      case 3:
        return "Experto";

      default:
        throw Exception("Nivel inexistente.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelName = _getLevelName();

    return Column(
      children: [
        Text(levelName),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 3,
          divisions: 3,
          onChanged: _chooseLevel,
        ),
      ],
    );
  }
}
