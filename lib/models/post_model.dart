import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReporterPost {
  final String postId;
  final String content;
  final String? image;
  final String createdAt;
  final String likesCount;
  late final String comments_count;
  final String privacy;
  final String userId;
  final String journalistId;
  final String journalistName;
  final String journalistIdentifier;
  final String journalistProfilePicture;

  ReporterPost( {
    required this.postId,
    required this.content,
    this.image,
    required this.createdAt,
    required this.likesCount,
    required this.comments_count,
    required this.userId,
    required this.privacy,
    required this.journalistId,
    required this.journalistName,
    required this.journalistIdentifier,
    required this.journalistProfilePicture,
  });

  factory ReporterPost.fromJson(Map<String, dynamic> json) {
    final journalist = json['journalists'] ?? {};
    final user = journalist['users'] ?? {};
    final profilePicturePath = user['profile_picture'];
    final profilePictureUrl = profilePicturePath != null
        ? Supabase.instance.client.storage
            .from('images')
            .getPublicUrl('profiles/${profilePicturePath.split('/').last}')
        : 'https://bitsofco.de/img/Qo5mfYDE5v-350.png';
    final createdAt =
        DateTime.parse(json['created_at']).subtract(const Duration(hours: -3));
    final timeAgo = timeago.format(createdAt);

    return ReporterPost(
      userId: user['user_id'].toString(),
      postId: json['post_id'].toString(),
      content: json['content'] ?? ' ',
      image: json['image_url'],
      createdAt: timeAgo,
      journalistId: json['journalist_id'].toString(),
      journalistName: user['username'] ?? 'Unknown',
      journalistIdentifier: user['identifier'] ?? '--',
      journalistProfilePicture: profilePictureUrl,
      likesCount: json['likes_count'].toString(),
      comments_count: json['comments_count'].toString(),
       privacy: 'privacy',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'post_id': postId,
        'content': content,
        'image_url': image,
        'created_at': createdAt,
        'privacy': privacy,
        'likes_count': likesCount,
        'comments_count':comments_count,
        'journalist_id': journalistId,
        'journalist_name': journalistName,
        'journalist_identifier': journalistIdentifier,
        'journalist_profile_picture': journalistProfilePicture,
      };
}
