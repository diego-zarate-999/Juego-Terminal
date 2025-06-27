import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prueba_ag/widgets/numbers_container.dart';

final rnd = Random();

class History {
  late final List<int> _secretNumbers;
  late final List<bool> _results;

  History() {
    _secretNumbers = [];
    _results = [];
  }

  History.test()
      : _secretNumbers = List.generate(10, (_) => rnd.nextInt(100) + 1),
        _results = List.generate(10, (_) => rnd.nextBool());

  void addRecord(int secretNumber, bool result) {
    _secretNumbers.add(secretNumber);
    _results.add(result);
  }

  List<int> get secretNumbers => _secretNumbers;
  List<bool> get results => _results;
}

class HistoryContainer extends StatelessWidget {
  const HistoryContainer(this.history, {super.key});

  final History history;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = history.results
        .map(
          (result) => result ? Colors.green : Colors.red,
        )
        .toList();

    return NumbersContainer(
      title: "Historial",
      data: history.secretNumbers,
      colors: colors,
    );
  }
}
