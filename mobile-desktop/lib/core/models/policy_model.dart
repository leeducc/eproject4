import 'package:flutter/material.dart';

class PolicyModel {
  final int id;
  final String type;
  final String titleEn;
  final String titleVi;
  final String titleZh;
  final String contentEn;
  final String contentVi;
  final String contentZh;
  final DateTime updatedAt;

  PolicyModel({
    required this.id,
    required this.type,
    required this.titleEn,
    required this.titleVi,
    required this.titleZh,
    required this.contentEn,
    required this.contentVi,
    required this.contentZh,
    required this.updatedAt,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is String) return DateTime.parse(date);
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
      return DateTime.now();
    }

    return PolicyModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleVi: json['titleVi'] ?? '',
      titleZh: json['titleZh'] ?? '',
      contentEn: json['contentEn'] ?? '',
      contentVi: json['contentVi'] ?? '',
      contentZh: json['contentZh'] ?? '',
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'titleEn': titleEn,
      'titleVi': titleVi,
      'titleZh': titleZh,
      'contentEn': contentEn,
      'contentVi': contentVi,
      'contentZh': contentZh,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getLocalizedTitle(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    if (locale.languageCode == 'vi') return titleVi;
    if (locale.languageCode == 'zh') return titleZh;
    return titleEn;
  }

  String getLocalizedContent(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    if (locale.languageCode == 'vi') return contentVi;
    if (locale.languageCode == 'zh') return contentZh;
    return contentEn;
  }
}