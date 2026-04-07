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
      
      
      final filtered = topics.where((topic) {
        if (topic.difficultyBand == null) {
          debugPrint('[RealWritingRepository] Topic ID ${topic.id} has NULL difficultyBand');
          return false;
        }
        
        final backendBand = topic.difficultyBand!.toUpperCase();
        bool match = false;
        if (backendBand == 'BAND_0_4' && band == IeltsBand.band0_4) match = true;
        if (backendBand == 'BAND_5_6' && band == IeltsBand.band5_6) match = true;
        if (backendBand == 'BAND_7_8' && band == IeltsBand.band7_8) match = true;
        if (backendBand == 'BAND_9' && band == IeltsBand.band9) match = true;
        
        if (!match) {
          debugPrint('[RealWritingRepository] Topic ID ${topic.id} filtered out. Backend: "$backendBand", Selected: "$band"');
        } else {
          debugPrint('[RealWritingRepository] Topic ID ${topic.id} MATCHED. Backend: "$backendBand", Selected: "$band"');
        }
        
        return match;
      }).map((topic) {
        return WritingPrompt(
          id: topic.id.toString(),
          taskType: 2, 
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