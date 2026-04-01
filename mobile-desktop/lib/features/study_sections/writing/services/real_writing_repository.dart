import 'package:flutter/material.dart';
import 'package:mobile_desktop/core/providers/ielts_level_provider.dart';
import '../models/writing_prompt.dart';
import 'writing_api_service.dart';
import 'writing_repository.dart';

class RealWritingRepository implements WritingRepository {
  final WritingApiService _apiService;

  RealWritingRepository(this._apiService);

  @override
  Future<List<WritingPrompt>> fetchPrompts(IeltsBand band) async {
    debugPrint('[RealWritingRepository] fetchPrompts → band=$band');
    
    try {
      final topics = await _apiService.fetchTopics();
      
      // Filter by band and map to WritingPrompt
      final filtered = topics.where((topic) {
        if (topic.difficultyBand == null) return false;
        
        // Map backend band name to enum
        // Backend: BAND_0_4, BAND_5_6, BAND_7_8, BAND_9
        // Flutter: band0_4, band5_6, band7_8, band9
        final backendBand = topic.difficultyBand!.toUpperCase();
        if (backendBand == 'BAND_0_4' && band == IeltsBand.band0_4) return true;
        if (backendBand == 'BAND_5_6' && band == IeltsBand.band5_6) return true;
        if (backendBand == 'BAND_7_8' && band == IeltsBand.band7_8) return true;
        if (backendBand == 'BAND_9' && band == IeltsBand.band9) return true;
        
        return false;
      }).map((topic) {
        return WritingPrompt(
          id: topic.id.toString(),
          taskType: 2, // Default to Task 2 for now as we don't have taskType in backend yet
          title: topic.title,
          promptText: topic.prompt,
          band: band,
        );
      }).toList();
      
      debugPrint('[RealWritingRepository] Returning ${filtered.length} prompts for $band');
      return filtered;
    } catch (e) {
      debugPrint('[RealWritingRepository] Error: $e');
      rethrow;
    }
  }
}
