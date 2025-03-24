import 'dart:io';

import 'package:flutter/material.dart';
import 'package:football_project/pages/comments_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:football_project/models/post_model.dart';
import 'package:http/http.dart' as http;

class PostCardFooter extends StatefulWidget {
  const PostCardFooter({super.key, required this.post});
  final ReporterPost post;

  @override
  State<PostCardFooter> createState() => _PostCardFooterState();
}

class _PostCardFooterState extends State<PostCardFooter>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  bool _isLiked = false;
  late int _likesCount;

  // متحكم للانيميشن
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeLikeState();

    // تهيئة التحكم بالانيميشن
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // تهيئة تأثير التكبير
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(PostCardFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث عدد الإعجابات عندما يتغير المنشور
    if (oldWidget.post.likesCount != widget.post.likesCount) {
      setState(() {
        _likesCount = int.parse(widget.post.likesCount);
      });
    }
  }

  void _initializeLikeState() {
    _likesCount = int.parse(widget.post.likesCount);
    _checkIfPostIsLiked();
  }

  Future<void> _checkIfPostIsLiked() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('post_id', widget.post.postId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isLiked = response != null;
        });
      }
    } catch (e) {
      debugPrint('Error checking like status: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newLikeStatus = !_isLiked;
      final newLikesCount = _likesCount + (newLikeStatus ? 1 : -1);

      // تحديث الواجهة أولاً (Optimistic update)
      setState(() {
        _isLiked = newLikeStatus;
        _likesCount = newLikesCount;
      });

      if (newLikeStatus) {
        // إضافة لايك
        await _supabase.from('likes').insert({
          'user_id': userId,
          'post_id': widget.post.postId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // حذف اللايك
        await _supabase
            .from('likes')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', widget.post.postId);
      }

      // تحديث عدد الإعجابات في جدول المنشورات
      await _supabase.from('posts').update({'likes_count': newLikesCount}).eq(
          'post_id', widget.post.postId);
    } catch (e) {
      // في حالة حدوث خطأ، نعيد الحالة كما كانت
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likesCount = int.parse(widget.post.likesCount);
        });
      }
      debugPrint('Error toggling like: $e');
    }
  }

  // دالة لتشغيل الانيميشن
  void _startAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // تنظيف المتحكم عند التخلص من الويدجت
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              Text(
                '$_likesCount',
                style: const TextStyle(color: Colors.red,fontSize: 16),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _toggleLike();
                  _startAnimation(); // تشغيل الانيميشن عند النقر
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red ,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 4),
              Text(
                widget.post.comments_count,
                style: const TextStyle(color: Colors.blue),
              ),
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommentsPage(
                              post: widget.post,
                            )),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.green),
            onPressed: () async {
  try {
    final String postContent = '${widget.post.content}\n\n🔗 شاهد المزيد من اخبار كرة القدم في تطبيق Football Arena !';

    // تحميل الصورة
    if (widget.post.image != null && widget.post.image!.isNotEmpty) {
      final response = await http.get(Uri.parse(widget.post.image!));
      final tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/shared_image.jpg');
      await file.writeAsBytes(response.bodyBytes);

      // مشاركة الصورة مع النص
      await Share.shareXFiles([XFile(file.path)], text: postContent);
    } else {
      // مشاركة النص فقط إذا لم تكن هناك صورة
      await Share.share(postContent);
    }
  } catch (e) {
    debugPrint('Error sharing post: $e');
  }
},
          ),
        ],
      ),
    );
  }
}