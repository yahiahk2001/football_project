class Reply {
  final String id;
  final String commentId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Reply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    id: json['reply_id'],
    commentId: json['comment_id'],
    userId: json['user_id'],
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'reply_id': id,
    'comment_id': commentId,
    'user_id': userId,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };
}
