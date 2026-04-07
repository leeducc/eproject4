class AppSectionModel {
  final int id;
  final String skill;
  final String sectionName;
  final String difficultyBand;
  final int displayOrder;
  final List<dynamic>? tags;
  final String? guideContent;
  final int? questionCount;
  final double? mastery;
  final bool isPremium;

  AppSectionModel({
    required this.id,
    required this.skill,
    required this.sectionName,
    required this.difficultyBand,
    required this.displayOrder,
    this.tags,
    this.guideContent,
    this.questionCount,
    this.mastery,
    this.isPremium = false,
  });

  factory AppSectionModel.fromJson(Map<String, dynamic> json) {
    return AppSectionModel(
      id: json['id'],
      skill: json['skill'],
      sectionName: json['sectionName'],
      difficultyBand: json['difficultyBand'],
      displayOrder: json['displayOrder'],
      tags: json['tags'] != null ? List.from(json['tags']) : null,
      guideContent: json['guideContent'],
      questionCount: json['questionCount'],
      mastery: json['mastery'] != null ? (json['mastery'] as num).toDouble() : null,
      isPremium: json['isPremium'] ?? false,
    );
  }
}