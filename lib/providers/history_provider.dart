import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History {
  List<int> numbers;
  List<bool> results;

  History(this.numbers, this.results);

  factory History.empty() {
    return History([], []);
  }
}

class HistoryProvider extends ChangeNotifier {
  History history = History.empty();

  Future<void> loadHistory() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final loadedNumbersHistory =
        preferences.getStringList("history_numbers") ?? [];
    final loadedResultsHistory =
        preferences.getStringList("history_results") ?? [];

    final numbersHistory =
        loadedNumbersHistory.map((s) => int.parse(s)).toList();
    final resultsHistory =
        loadedResultsHistory.map((s) => bool.parse(s)).toList();

    history = History(numbersHistory, resultsHistory);
    notifyListeners();
  }

  Future<void> updateHistory(int number, bool result) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    history.numbers = [...history.numbers, number];
    history.results = [...history.results, result];

    List<String> parsedNumbers = history.numbers.map((n) => n.toString()).toList();
    List<String> parsedResults = history.results.map((r) => r.toString()).toList();

    await preferences.setStringList("history_numbers", parsedNumbers);
    await preferences.setStringList("history_results", parsedResults);

    notifyListeners();
  }
}
