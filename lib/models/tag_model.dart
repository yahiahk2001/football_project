class Tag {
  final String id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: json['tag_id'],
    name: json['tag_name'],
  );

  Map<String, dynamic> toJson() => {
    'tag_id': id,
    'tag_name': name,
  };
}


class PostTag {
  final String postId;
  final String tagId;

  PostTag({
    required this.postId,
    required this.tagId,
  });

  factory PostTag.fromJson(Map<String, dynamic> json) => PostTag(
    postId: json['post_id'],
    tagId: json['tag_id'],
  );

  Map<String, dynamic> toJson() => {
    'post_id': postId,
    'tag_id': tagId,
  };
}
