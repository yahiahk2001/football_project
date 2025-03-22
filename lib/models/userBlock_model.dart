class UserBlock {
  final String blockerId;
  final String blockedId;
  final DateTime createdAt;

  UserBlock({
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
  });

  factory UserBlock.fromJson(Map<String, dynamic> json) => UserBlock(
    blockerId: json['blocker_id'],
    blockedId: json['blocked_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'blocker_id': blockerId,
    'blocked_id': blockedId,
    'created_at': createdAt.toIso8601String(),
  };
}
