import 'package:flutter/material.dart';
import '../services/vocabulary_api_service.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  final VocabularyApiService _apiService = VocabularyApiService();

  factory FavoriteManager() {
    return _instance;
  }

  FavoriteManager._internal() {
    syncWithBackend();
  }

  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  Future<void> syncWithBackend() async {
    try {
      final List<dynamic> backendFavorites = await _apiService.fetchFavorites();
      _favorites.clear();
      _favorites.addAll(backendFavorites.map((v) => v.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing favorites: $e');
    }
  }

  bool isFavorite(String word) {
    return _favorites.any((e) => e["word"] == word);
  }

  Future<void> toggleFavorite(Map<String, dynamic> vocab) async {
    final int? id = vocab['id'];
    if (id == null) return;

    final String word = vocab['word'] ?? '';
    final bool currentlyFavorite = isFavorite(word);

    // Optimistic update
    if (currentlyFavorite) {
      _favorites.removeWhere((e) => e["word"] == word);
    } else {
      _favorites.add(vocab);
    }
    notifyListeners();

    try {
      final bool result = await _apiService.toggleFavorite(id);
      // Ensure local state matches server result
      final bool isNowFavorite = _favorites.any((e) => e["word"] == word);
      if (isNowFavorite != result) {
        if (result) {
          if (!isNowFavorite) _favorites.add(vocab);
        } else {
          _favorites.removeWhere((e) => e["word"] == word);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling favorite on backend: $e');
      // Rollback optimistic update on error if needed, but for now we trust the next sync
    }
  }
}