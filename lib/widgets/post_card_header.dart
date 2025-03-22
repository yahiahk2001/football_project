import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/models/post_model.dart';
import 'package:football_project/pages/edit_post_page.dart';
import 'package:football_project/pages/owen_reporter_profile_page.dart';
import 'package:football_project/pages/reporter_profile.dart';
import 'package:football_project/state_managment/posts_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCardHeader extends StatelessWidget {
  final ReporterPost post;
  final PostsController controller = Get.put(PostsController());

  PostCardHeader({
    super.key,
    required this.post,
  });

  final userId = Supabase.instance.client.auth.currentUser?.id;

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this post?'),
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
                _deletePost(context);
                controller.fetchReporterPosts();
              },
            ),
          ],
        );
      },
    );
  }
// أضف هذه الدالة إلى فئة PostCardHeader
void _showReportDialog(BuildContext context) {
  String reportReason = 'محتوى غير لائق'; // السبب الافتراضي
  TextEditingController customReasonController = TextEditingController();
  bool isCustomReason = false;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('الإبلاغ عن منشور'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('يرجى تحديد سبب الإبلاغ:'),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: reportReason,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        reportReason = newValue;
                        isCustomReason = (newValue == 'أخرى');
                      });
                    }
                  },
                  items: <String>[
                    'محتوى غير لائق',
                    'خطاب كراهية',
                    'معلومات مضللة',
                    'انتهاك حقوق الملكية',
                    'أخرى'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                if (isCustomReason) ...[
                  const SizedBox(height: 15),
                  TextField(
                    controller: customReasonController,
                    decoration: const InputDecoration(
                      labelText: 'اكتب السبب هنا',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('إلغاء'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('إبلاغ'),
                onPressed: () {
                  // استخدم السبب المخصص إذا تم اختيار "أخرى"
                  final finalReason = (isCustomReason && customReasonController.text.isNotEmpty) 
                    ? customReasonController.text 
                    : reportReason;
                  
                  _submitReport(context, finalReason);
                },
              ),
            ],
          );
        }
      );
    },
  );
}

// دالة إرسال الإبلاغ إلى قاعدة البيانات
void _submitReport(BuildContext context, String reason) async {
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
  
  if (currentUserId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يجب تسجيل الدخول للإبلاغ عن منشور')),
    );
    Navigator.of(context).pop();
    return;
  }
  
  try {
    // إدخال بيانات الإبلاغ في جدول التقارير
    await Supabase.instance.client.from('reports').insert({
      'reported_content_id': post.postId,
      'reason': reason,
      'reporter_user_id': currentUserId,
      'reported_user_id': post.userId,
      'reported_content_type': 'post',
      'content': post.content,
      'status': 'pending', // حالة افتراضية: قيد الانتظار
      'action_taken': 'none', // لم يتم اتخاذ إجراء بعد
      'created_at': DateTime.now().toIso8601String(),
    });
    
    Navigator.of(context).pop(); // إغلاق الحوار
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال الإبلاغ بنجاح، شكرًا لمساعدتنا في الحفاظ على مجتمع آمن')),
    );
  } catch (e) {
    Navigator.of(context).pop(); // إغلاق الحوار
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل في إرسال الإبلاغ: $e')),
    );
  }
}
  void _deletePost(BuildContext context) async {
    try {
      await Supabase.instance.client
          .from('posts')
          .delete()
          .eq('post_id', post.postId);

      // إذا وصلنا إلى هنا، العملية نجحت
      Navigator.of(context).pop(); // إغلاق الحوار
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المنشور بنجاح')),
      );
    } catch (e) {
      // إذا حدث استثناء، العملية فشلت
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () {
                userId == post.userId
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OwenReporterProfilePage(),
                        ),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReporterProfilePage(
                            reporterId: post.journalistId,
                            userId: post.userId,
                          ),
                        ),
                      );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.network(
                  post.journalistProfilePicture,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  userId == post.userId
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const OwenReporterProfilePage(),
                          ),
                        )
                      : print('reporterId: ${post.journalistId}');
                  print('userId: ${post.userId}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReporterProfilePage(
                        reporterId: post.journalistId,
                        userId: post.userId,
                      ),
                    ),
                  );
                },
                child: Text(post.journalistName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Text(post.createdAt, style: const TextStyle(fontSize: 8)),
            ],
          ),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPostPage(post: post),
                    ),
                  );
                  break;
                case 'delete':
                  _showDeleteConfirmationDialog(context);

                  break;
                case 'hide':
                  // Handle hide post
                  break;
                case 'report':
                _showReportDialog(context); 
                  break;
              }
            },
            itemBuilder: (BuildContext context) => userId == post.userId
                ? <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit Post'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete Post'),
                    ),
                  ]
                : <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'hide',
                      child: Text('Hide Post'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'report',
                      child: Text('Report Post'),
                    ),
                  ],
            icon: const Icon(Icons.more_horiz, color: goldColor),
          ),
        ],
      ),
    );
  }
}
