class Like {
  final String id;
  final String userId;
  final String postId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) => Like(
    id: json['like_id'],
    userId: json['user_id'],
    postId: json['post_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'like_id': id,
    'user_id': userId,
    'post_id': postId,
    'created_at': createdAt.toIso8601String(),
  };
}
