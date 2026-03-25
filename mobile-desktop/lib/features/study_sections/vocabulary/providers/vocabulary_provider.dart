import 'package:flutter/material.dart';
import '../../../../core/providers/ielts_level_provider.dart';
import '../models/vocabulary.dart';
import '../repositories/vocabulary_repository.dart';

class VocabularyProvider extends ChangeNotifier {
  final VocabularyRepository repository;

  VocabularyProvider(this.repository);

  List<Vocabulary> _vocabularies = [];
  bool _isLoading = false;
  String? _error;

  List<Vocabulary> get vocabularies => _vocabularies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _mapBandToLevelGroup(IeltsBand band) {
    switch (band) {
      case IeltsBand.band0_4:
        return '0-4';
      case IeltsBand.band5_6:
        return '5-6';
      case IeltsBand.band7_8:
        return '7-8';
      case IeltsBand.band9:
        return '9';
    }
  }

  Future<void> loadForBand(IeltsBand band) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final levelGroup = _mapBandToLevelGroup(band);
      _vocabularies = await repository.getVocabularyForLevel(levelGroup);
    } catch (e) {
      _error = 'Failed to load vocabulary: $e';
      _vocabularies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
