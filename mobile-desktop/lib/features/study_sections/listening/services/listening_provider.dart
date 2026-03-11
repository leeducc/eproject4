import 'package:flutter/material.dart';
import 'listening_repository.dart';
import '../models/listening_exercise.dart';
import '../../../../core/providers/ielts_level_provider.dart';

enum LoadState { idle, loading, success, error }

class ListeningProvider extends ChangeNotifier {
  final ListeningRepository _repo;

  ListeningProvider(this._repo) {
    debugPrint('[ListeningProvider] created');
  }

  LoadState _state = LoadState.idle;
  List<ListeningExercise> _items = [];
  String? _errorMessage;
  IeltsBand? _currentBand;

  LoadState get state => _state;
  List<ListeningExercise> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  IeltsBand? get currentBand => _currentBand;

  Future<void> loadForBand(IeltsBand band) async {
    if (band == _currentBand && _state == LoadState.success) {
      debugPrint('[ListeningProvider] band unchanged ($band) — skipping fetch');
      return;
    }

    debugPrint('[ListeningProvider] loadForBand → $band');
    _currentBand = band;
    _state = LoadState.loading;
    _items = [];
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repo.fetchExercises(band);
      _state = LoadState.success;
      debugPrint('[ListeningProvider] ✓ loaded ${_items.length} items for $band');
    } catch (e, st) {
      _state = LoadState.error;
      _errorMessage = e.toString();
      debugPrint('[ListeningProvider] ✗ error: $_errorMessage\n$st');
    }

    notifyListeners();
  }
}
