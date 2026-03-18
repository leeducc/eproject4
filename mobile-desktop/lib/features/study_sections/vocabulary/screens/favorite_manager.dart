import 'package:flutter/material.dart';

class FavoriteManager extends ChangeNotifier {

  static final FavoriteManager _instance = FavoriteManager._internal();

  factory FavoriteManager() {
    return _instance;
  }

  FavoriteManager._internal();

  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  bool isFavorite(String word) {
    return _favorites.any((e) => e["word"] == word);
  }

  void toggleFavorite(Map<String, dynamic> vocab) {

    if (isFavorite(vocab["word"])) {
      _favorites.removeWhere((e) => e["word"] == vocab["word"]);
    } else {
      _favorites.add(vocab);
    }

    notifyListeners();
  }
}