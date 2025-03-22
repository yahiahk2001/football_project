class Follower {
  final String followerId;
  final String followedId;
  final DateTime createdAt;

  Follower({
    required this.followerId,
    required this.followedId,
    required this.createdAt,
  });

  factory Follower.fromJson(Map<String, dynamic> json) => Follower(
    followerId: json['follower_id'],
    followedId: json['followed_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'follower_id': followerId,
    'followed_id': followedId,
    'created_at': createdAt.toIso8601String(),
  };
}