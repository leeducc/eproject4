import 'package:flutter/material.dart';

/// Represents one of the 4 IELTS band levels supported in the app.
class IeltsLevel {
  final String label;       // e.g. "Band 0-4"
  final String range;       // e.g. "0-4"
  final String description; // short description shown on the picker
  final Color primaryColor;
  final Color accentColor;
  final int barHeight;      // relative height for the bar chart (1-4)

  const IeltsLevel({
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
    label: 'Band 0–4',
    range: '0-4',
    description:
        'Beginner to Elementary level. Build foundational vocabulary, basic listening comprehension, and simple sentence writing.',
    primaryColor: Color(0xFF4FC3F7),
    accentColor: Color(0xFF0288D1),
    barHeight: 1,
  ),
  IeltsLevel(
    label: 'Band 5–6',
    range: '5-6',
    description:
        'Pre-Intermediate to Intermediate. Strengthen reading skills, practise listening for detail, and write structured paragraphs.',
    primaryColor: Color(0xFF81C784),
    accentColor: Color(0xFF388E3C),
    barHeight: 2,
  ),
  IeltsLevel(
    label: 'Band 7–8',
    range: '7-8',
    description:
        'Upper-Intermediate to Advanced. Master complex texts, academic vocabulary, and coherent essay writing.',
    primaryColor: Color(0xFFFFB74D),
    accentColor: Color(0xFFF57C00),
    barHeight: 3,
  ),
  IeltsLevel(
    label: 'Band 9',
    range: '9',
    description:
        'Expert level. Tackle the most demanding IELTS materials and produce sophisticated, nuanced responses.',
    primaryColor: Color(0xFFE57373),
    accentColor: Color(0xFFC62828),
    barHeight: 4,
  ),
];

class IeltsLevelProvider extends ChangeNotifier {
  IeltsLevel _selectedLevel = kIeltsLevels[1]; // default Band 5-6

  IeltsLevel get selectedLevel => _selectedLevel;

  void setLevel(IeltsLevel level) {
    debugPrint('[IeltsLevelProvider] Level changed: ${level.label}');
    _selectedLevel = level;
    notifyListeners();
  }
}
