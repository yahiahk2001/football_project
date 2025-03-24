import 'package:flutter/material.dart';
import 'package:football_project/models/post_model.dart';
import 'package:football_project/models/user_model.dart';
import 'package:football_project/widgets/comment_item.dart';
import 'package:football_project/widgets/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key, required this.post});
  final ReporterPost post;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> comments = [];
  Map<String, UserModel> commentUsers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommentsAndUsers();
  }

  Future<void> _fetchCommentsAndUsers() async {
    try {
      // Fetch comments with user data in a single query
      final response = await supabase
          .from('comments')
          .select('''
            *,
            users:user_id (*)
          ''')
          .eq('post_id', widget.post.postId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          comments = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching comments and users: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Add new comment
      final newComment = await supabase.from('comments').insert({
        'post_id': widget.post.postId,
        'user_id': userId,
        'content': _commentController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      }).select('*, users:user_id (*)').single();

      // Update comments count
      await supabase.from('posts').update({
        'comments_count': int.parse(widget.post.comments_count) + 1,
      }).eq('post_id', widget.post.postId);

      setState(() {
        comments.add( newComment);
      });
      
      _commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NewsCard(post: widget.post),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment = comments[index];
                        final userData = comment['users'] as Map<String, dynamic>;
                        
                        return CommentWidget(
                          comment: comment,
                          user: UserModel.fromJson(userData),
                        );
                      },
                      childCount: comments.length,
                    ),
                  ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'اضف تعليق....',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

