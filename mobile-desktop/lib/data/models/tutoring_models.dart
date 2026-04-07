class TeacherSlot {
  final int id;
  final int teacherId;
  final int? studentId;
  final String startTime;
  final String endTime;
  final String status;

  TeacherSlot({
    required this.id,
    required this.teacherId,
    this.studentId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory TeacherSlot.fromJson(Map<String, dynamic> json) {
    return TeacherSlot(
      id: json['id'],
      teacherId: json['teacherId'],
      studentId: json['studentId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'studentId': studentId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
    };
  }
}

class TeacherSchedule {
  final int teacherId;
  final String fullName;
  final String bio;
  final String avatar;
  final double averageRating;
  final List<TeacherSlot> availableSlots;

  TeacherSchedule({
    required this.teacherId,
    required this.fullName,
    required this.bio,
    required this.avatar,
    required this.averageRating,
    required this.availableSlots,
  });

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      teacherId: json['teacherId'],
      fullName: json['fullName'] ?? '',
      bio: json['bio'] ?? '',
      avatar: json['avatar'] ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      availableSlots: (json['availableSlots'] as List)
          .map((slot) => TeacherSlot.fromJson(slot))
          .toList(),
    );
  }
}
