import 'package:flutter/material.dart';


enum IeltsBand { band0_4, band5_6, band7_8, band9 }


class IeltsLevel {
  final IeltsBand band;     
  final String label;       
  final String range;       
  final String description; 
  final Color primaryColor;
  final Color accentColor;
  final int barHeight;      

  const IeltsLevel({
    required this.band,
    required this.label,
    required this.range,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.barHeight,
  });
}

const List<IeltsLevel> kIeltsLevels = [
  IeltsLevel(
    band: IeltsBand.band0_4,
    label: 'Band 0–4',
    range: '0-4.0',
    description:
        'Beginner to Elementary level. Build foundational vocabulary, basic listening comprehension, and simple sentence writing.',
    primaryColor: Color(0xFF4FC3F7),
    accentColor: Color(0xFF0288D1),
    barHeight: 1,
  ),
  IeltsLevel(
    band: IeltsBand.band5_6,
    label: 'Band 5–6',
    range: '5.0-6.0',
    description:
        'Pre-Intermediate to Intermediate. Strengthen reading skills, practise listening for detail, and write structured paragraphs.',
    primaryColor: Color(0xFF81C784),
    accentColor: Color(0xFF388E3C),
    barHeight: 2,
  ),
  IeltsLevel(
    band: IeltsBand.band7_8,
    label: 'Band 7–8',
    range: '7.0-8.0',
    description:
        'Upper-Intermediate to Advanced. Master complex texts, academic vocabulary, and coherent essay writing.',
    primaryColor: Color(0xFFFFB74D),
    accentColor: Color(0xFFF57C00),
    barHeight: 3,
  ),
  IeltsLevel(
    band: IeltsBand.band9,
    label: 'Band 9',
    range: '9.0',
    description:
        'Expert level. Tackle the most demanding IELTS materials and produce sophisticated, nuanced responses.',
    primaryColor: Color(0xFFE57373),
    accentColor: Color(0xFFC62828),
    barHeight: 4,
  ),
];

class IeltsLevelProvider extends ChangeNotifier {
  
  IeltsLevel _selectedLevel = kIeltsLevels[0];

  IeltsLevel get selectedLevel => _selectedLevel;

  void setLevel(IeltsLevel level) {
    debugPrint('[IeltsLevelProvider] Level changed → ${level.label} (band: ${level.band})');
    _selectedLevel = level;
    notifyListeners();
  }
}