class Share {
  final String id;
  final String userId;
  final String postId;
  final DateTime createdAt;

  Share({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory Share.fromJson(Map<String, dynamic> json) => Share(
    id: json['share_id'],
    userId: json['user_id'],
    postId: json['post_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'share_id': id,
    'user_id': userId,
    'post_id': postId,
    'created_at': createdAt.toIso8601String(),
  };
}