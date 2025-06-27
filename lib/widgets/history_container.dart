import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_ag/providers/history_provider.dart';
import 'package:prueba_ag/widgets/numbers_container.dart';

class HistoryContainer extends StatelessWidget {
  const HistoryContainer({super.key});

  @override
  Widget build(BuildContext context) {
    History loadedHistory = context.watch<HistoryProvider>().history;

    List<Color> colors = loadedHistory.results.map((userWon) {
      return userWon ? Colors.green : Colors.red;
    }).toList();

    return NumbersContainer(
      title: "Historial",
      data: loadedHistory.numbers,
      colors: colors,
    );
  }
}
