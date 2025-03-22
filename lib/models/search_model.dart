class Search {
  final String id;
  final String userId;
  final String query;
  final String? results;
  final DateTime createdAt;

  Search({
    required this.id,
    required this.userId,
    required this.query,
    this.results,
    required this.createdAt,
  });

  factory Search.fromJson(Map<String, dynamic> json) => Search(
    id: json['search_id'],
    userId: json['user_id'],
    query: json['search_query'],
    results: json['search_results'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'search_id': id,
    'user_id': userId,
    'search_query': query,
    'search_results': results,
    'created_at': createdAt.toIso8601String(),
  };
}