import 'package:flutter/material.dart';
import 'writing_repository.dart';
import '../models/writing_prompt.dart';
import '../../../../core/providers/ielts_level_provider.dart';

enum LoadState { idle, loading, success, error }

class WritingProvider extends ChangeNotifier {
  final WritingRepository _repo;

  WritingProvider(this._repo) {
    debugPrint('[WritingProvider] created');
  }

  LoadState _state = LoadState.idle;
  List<WritingPrompt> _items = [];
  String? _errorMessage;
  IeltsBand? _currentBand;

  LoadState get state => _state;
  List<WritingPrompt> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  IeltsBand? get currentBand => _currentBand;

  Future<void> loadForBand(IeltsBand band) async {
    if (band == _currentBand && _state == LoadState.success) {
      debugPrint('[WritingProvider] band unchanged ($band) — skipping fetch');
      return;
    }

    debugPrint('[WritingProvider] loadForBand → $band');
    _currentBand = band;
    _state = LoadState.loading;
    _items = [];
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repo.fetchPrompts(band);
      _state = LoadState.success;
      debugPrint('[WritingProvider] ✓ loaded ${_items.length} items for $band');
    } catch (e, st) {
      _state = LoadState.error;
      _errorMessage = e.toString();
      debugPrint('[WritingProvider] ✗ error: $_errorMessage\n$st');
    }

    notifyListeners();
  }
}
