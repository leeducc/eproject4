class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String? mediaUrl;
  final String? mediaType;
  final bool isEdited;
  final bool isMe;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    required this.isEdited,
    required this.isMe,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
      isEdited: json['isEdited'] ?? false,
      isMe: json['isMe'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class EditHistory {
  final int id;
  final String oldContent;
  final DateTime editedAt;

  EditHistory({
    required this.id,
    required this.oldContent,
    required this.editedAt,
  });

  factory EditHistory.fromJson(Map<String, dynamic> json) {
    return EditHistory(
      id: json['id'],
      oldContent: json['oldContent'],
      editedAt: DateTime.parse(json['editedAt']),
    );
  }
}