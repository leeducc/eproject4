class FeedbackModel {
  final int id;
  final String title;
  final String textContent;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.title,
    required this.textContent,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      title: json['title'],
      textContent: json['textContent'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class FeedbackMessageModel {
  final int id;
  final int senderId;
  final bool isAdmin;
  final String textContent;
  final DateTime createdAt;

  FeedbackMessageModel({
    required this.id,
    required this.senderId,
    required this.isAdmin,
    required this.textContent,
    required this.createdAt,
  });

  factory FeedbackMessageModel.fromJson(Map<String, dynamic> json) {
    return FeedbackMessageModel(
      id: json['id'],
      senderId: json['senderId'],
      isAdmin: json['isAdmin'] ?? json['admin'] ?? false,
      textContent: json['textContent'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class FeedbackDetailModel {
  final FeedbackModel feedback;
  final List<FeedbackMessageModel> messages;

  FeedbackDetailModel({
    required this.feedback,
    required this.messages,
  });

  factory FeedbackDetailModel.fromJson(Map<String, dynamic> json) {
    return FeedbackDetailModel(
      feedback: FeedbackModel.fromJson(json['feedback']),
      messages: (json['messages'] as List)
          .map((m) => FeedbackMessageModel.fromJson(m))
          .toList(),
    );
  }
}
