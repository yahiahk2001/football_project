class Notification {
  final String id;
  final String userId;
  final String type;
  final String? targetId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    this.targetId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json['notification_id'],
    userId: json['user_id'],
    type: json['type'],
    targetId: json['target_id'],
    message: json['message'],
    isRead: json['is_read'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'notification_id': id,
    'user_id': userId,
    'type': type,
    'target_id': targetId,
    'message': message,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };
}