class Media {
  final String id;
  final String postId;
  final String type;
  final String url;
  final DateTime createdAt;

  Media({
    required this.id,
    required this.postId,
    required this.type,
    required this.url,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json['media_id'],
    postId: json['post_id'],
    type: json['media_type'],
    url: json['media_url'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'media_id': id,
    'post_id': postId,
    'media_type': type,
    'media_url': url,
    'created_at': createdAt.toIso8601String(),
  };
}
