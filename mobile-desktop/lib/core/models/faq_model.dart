import 'package:flutter/material.dart';

class FAQModel {
  final int id;
  final String questionEn;
  final String questionVi;
  final String questionZh;
  final String answerEn;
  final String answerVi;
  final String answerZh;
  final int displayOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FAQModel({
    required this.id,
    required this.questionEn,
    required this.questionVi,
    required this.questionZh,
    required this.answerEn,
    required this.answerVi,
    required this.answerZh,
    required this.displayOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is String) return DateTime.tryParse(date);
      if (date is List && date.length >= 3) {
        return DateTime(
          date[0],
          date[1],
          date[2],
          date.length > 3 ? date[3] : 0,
          date.length > 4 ? date[4] : 0,
          date.length > 5 ? date[5] : 0,
        );
      }
      return null;
    }

    return FAQModel(
      id: json['id'] ?? 0,
      questionEn: json['questionEn'] ?? '',
      questionVi: json['questionVi'] ?? '',
      questionZh: json['questionZh'] ?? '',
      answerEn: json['answerEn'] ?? '',
      answerVi: json['answerVi'] ?? '',
      answerZh: json['answerZh'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionEn': questionEn,
      'questionVi': questionVi,
      'questionZh': questionZh,
      'answerEn': answerEn,
      'answerVi': answerVi,
      'answerZh': answerZh,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String getLocalizedQuestion(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    if (locale.languageCode == 'vi') return questionVi;
    if (locale.languageCode == 'zh') return questionZh;
    return questionEn;
  }

  String getLocalizedAnswer(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    if (locale.languageCode == 'vi') return answerVi;
    if (locale.languageCode == 'zh') return answerZh;
    return answerEn;
  }
}