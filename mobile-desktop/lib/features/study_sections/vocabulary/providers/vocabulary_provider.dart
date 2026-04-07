import 'package:flutter/material.dart';
import '../../../../core/providers/ielts_level_provider.dart';
import '../models/vocabulary.dart';
import '../repositories/vocabulary_repository.dart';

class VocabularyProvider extends ChangeNotifier {
  final VocabularyRepository repository;

  VocabularyProvider(this.repository);

  IeltsBand? _currentBand;
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
    if (band == _currentBand && _vocabularies.isNotEmpty) {
      return;
    }
    
    _currentBand = band;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final levelGroup = _mapBandToLevelGroup(band);
      final list = await repository.getVocabularyForLevel(levelGroup);
      
      
      list.sort((a, b) {
        if (a.isPremium == b.isPremium) return 0;
        return a.isPremium ? 1 : -1;
      });
      
      _vocabularies = list;
    } catch (e) {
      _error = 'Failed to load vocabulary: $e';
      _vocabularies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}