import 'package:flutter/material.dart';
import 'writing_repository.dart';
import '../models/writing_prompt.dart';
import '../../../../core/providers/ielts_level_provider.dart';

const List<WritingPrompt> _kAllPrompts = [
  
  WritingPrompt(
    id: 'w1',
    taskType: 1,
    title: 'A Letter to a Friend',
    promptText: 'Write a letter to a friend inviting them to your house.',
    band: IeltsBand.band0_4,
  ),
  WritingPrompt(
    id: 'w2',
    taskType: 2,
    title: 'Hobby',
    promptText: 'Do you agree that having a hobby is important? Give your reasons.',
    band: IeltsBand.band0_4,
  ),
  
  
  WritingPrompt(
    id: 'w3',
    taskType: 1,
    title: 'Formal Letter of Complaint',
    promptText: 'Write a letter of complaint to a restaurant manager about poor service.',
    band: IeltsBand.band5_6,
  ),
  WritingPrompt(
    id: 'w4',
    taskType: 2,
    title: 'Technology and Environment',
    promptText: 'Some people think technology is harming the environment. Discuss both views.',
    band: IeltsBand.band5_6,
  ),

  
  WritingPrompt(
    id: 'w5',
    taskType: 1,
    title: 'Line Graph Analysis',
    promptText: 'Summarise the information by selecting and reporting the main features of the line graph showing internet usage.',
    band: IeltsBand.band7_8,
  ),
  WritingPrompt(
    id: 'w6',
    taskType: 2,
    title: 'Education vs Experience',
    promptText: 'Is university education more important than practical experience? To what extent do you agree?',
    band: IeltsBand.band7_8,
  ),

  
  WritingPrompt(
    id: 'w7',
    taskType: 1,
    title: 'Process Diagram',
    promptText: 'The diagram shows how electricity is generated in a hydroelectric power station. Summarise the information.',
    band: IeltsBand.band9,
  ),
  WritingPrompt(
    id: 'w8',
    taskType: 2,
    title: 'Globalization and Culture',
    promptText: 'Globalization is leading to the loss of cultural identity. To what extent do you agree with this statement?',
    band: IeltsBand.band9,
  ),
];

class MockWritingRepository implements WritingRepository {
  @override
  Future<List<WritingPrompt>> fetchPrompts(IeltsBand band) async {
    debugPrint('[MockWritingRepository] fetchPrompts → band=$band');
    await Future.delayed(const Duration(milliseconds: 400));
    final filtered = _kAllPrompts.where((p) => p.band == band).toList();
    debugPrint('[MockWritingRepository] Returning ${filtered.length} prompts for $band');
    return filtered;
  }
}