import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/models/user_model.dart';
import 'package:football_project/pages/edit_comment_page.dart';
import 'package:football_project/pages/owen_reporter_profile_page.dart';
import 'package:football_project/pages/owen_user_profile.dart';
import 'package:football_project/pages/reporter_profile.dart';
import 'package:football_project/pages/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentWidget extends StatefulWidget {
  final Map<String, dynamic> comment;
  final UserModel user;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.user,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final String myId = Supabase.instance.client.auth.currentUser!.id;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _setupProfileImage();
  }

  void _setupProfileImage() {
    if (widget.user.profilePicture != null) {
      profileImageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl('profiles/${widget.user.profilePicture!.split('/').last}');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteComment(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(BuildContext context) async {
    try {
      await Supabase.instance.client
          .from('comments')
          .delete()
          .eq('comment_id', widget.comment['comment_id']);

      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المنشور بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')),
        );
      }
    }
  }

  Future<void> _handleProfileNavigation() async {
    if (widget.user.id == myId) {
      if (widget.user.role == 'Reporter') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OwenReporterProfilePage(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OwenUserProfilePage(),
          ),
        );
      }
    } else {
      if (widget.user.role == 'Reporter') {
        try {
          var journalist = await Supabase.instance.client
              .from('journalists')
              .select()
              .eq('user_id', widget.user.id)
              .single();
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReporterProfilePage(
                reporterId: journalist['journalist_id'].toString(),
                userId: widget.user.id,
              ),
            ),
          );
        } catch (e) {
          print('Error fetching journalist data: $e');
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(
              user: widget.user,
              userImageUrl: profileImageUrl,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _handleProfileNavigation,
            child: CircleAvatar(
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              radius: 20,
              child: widget.user.profilePicture?.isEmpty ?? true
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.values[0],
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.comment['content'],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      getTimeAgo(widget.comment['created_at']),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'تعديل':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCommentPage(
                        comment: widget.comment,
                      ),
                    ),
                  );
                  break;
                case 'حذف':
                  _showDeleteConfirmationDialog(context);
                  break;
                case 'ابلاغ':
                  // Handle report comment
                  break;
              }
            },
            itemBuilder: (BuildContext context) => myId == widget.user.id
                ? <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'تعديل',
                      child: Text('تعديل التعليق'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'حذف',
                      child: Text('حذف التعليق'),
                    ),
                  ]
                : <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'اخفاء',
                      child: Text('اخفاء التعليق'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'ابلاغ',
                      child: Text('ابلاغ عن التعليق'),
                    ),
                  ],
            icon: const Icon(Icons.more_horiz, color: goldColor),
          ),
        ],
      ),
    );
  }

  String getTimeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    return timeago.format(date, locale: 'ar');
  }
}