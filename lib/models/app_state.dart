import 'package:flutter/material.dart';

import '../screens/home.dart';

class CountryHistoryItem {
  final Country country;
  final DateTime timestamp;

  CountryHistoryItem({required this.country, required this.timestamp});
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final List<Country> _favorites = [];
  final List<CountryHistoryItem> _history = [];

  List<Country> get favorites => List.unmodifiable(_favorites);
  List<CountryHistoryItem> get history => List.unmodifiable(_history);

  bool isFavorite(Country country) {
    return _favorites.any((c) => c.name == country.name);
  }

  void toggleFavorite(Country country) {
    if (isFavorite(country)) {
      _favorites.removeWhere((c) => c.name == country.name);
    } else {
      _favorites.add(country);
    }
    notifyListeners();
  }

  void addToHistory(Country country) {
    if (_history.isNotEmpty && _history.first.country.name == country.name) {
      return;
    }
    _history.insert(
      0,
      CountryHistoryItem(country: country, timestamp: DateTime.now()),
    );
    notifyListeners();
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      notifyListeners();
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
