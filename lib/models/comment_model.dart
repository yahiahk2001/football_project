class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['comment_id'],
    postId: json['post_id'],
    userId: json['user_id'],
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'comment_id': id,
    'post_id': postId,
    'user_id': userId,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };
}