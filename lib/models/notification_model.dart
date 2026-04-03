class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'join_request', 'room_request', 'maintenance_update', 'general'
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'general',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
    );
  }
}
