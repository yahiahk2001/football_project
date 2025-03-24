import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/models/post_model.dart';
import 'package:football_project/models/user_model.dart';
import 'package:football_project/pages/comments_page.dart';
import 'package:football_project/pages/owen_reporter_profile_page.dart';
import 'package:football_project/widgets/profile_posts.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReporterProfilePage extends StatefulWidget {
  const ReporterProfilePage(
      {super.key, required this.reporterId, required this.userId});
  final String reporterId;
  final String userId;

  @override
  State<ReporterProfilePage> createState() => _ReporterProfilePageState();
}

class _ReporterProfilePageState extends State<ReporterProfilePage> {
  String? profileImageUrl;
  UserModel? _user;
  List<Map<String, dynamic>> posts = []; // لتخزين المنشورات
  bool isUserLoading = true; // مؤشر تحميل المستخدم
  bool isPostsLoading = true; // مؤشر تحميل المنشورات
  bool isFollowing = false; // لمعرفة هل المستخدم يتابع الصحفي أم لا
bool isLoadingFollow = false; // لمعرفة هل هناك عملية جارية

  @override
  void initState() {
    super.initState();
    _loadData();
    checkIfFollowing(); // التحقق من حالة المتابعة عند تحميل الصفحة
  }
Future<void> toggleFollow() async {
  if (isLoadingFollow) return; // منع تنفيذ العملية أثناء التحميل

  setState(() {
    isLoadingFollow = true;
  });

  final supabase = Supabase.instance.client;

  if (isFollowing) {
    // إلغاء المتابعة
    await supabase
        .from('journalist_followers')
        .delete()
        .match({'follower_id': Supabase.instance.client.auth.currentUser!.id, 'journalist_id': widget.reporterId});

    setState(() {
      isFollowing = false;
      isLoadingFollow = false;
    });
  } else {
    // متابعة الصحفي
    await supabase.from('journalist_followers').insert({
      'follower_id': Supabase.instance.client.auth.currentUser!.id,
      'journalist_id': widget.reporterId,
    });

    setState(() {
      isFollowing = true;
      isLoadingFollow = false;
    });
  }
}


Future<void> checkIfFollowing() async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('journalist_followers')
      .select()
      .eq('follower_id', Supabase.instance.client.auth.currentUser!.id)
      .eq('journalist_id', widget.reporterId)
      .maybeSingle(); // يستخدم `maybeSingle()` بدلاً من `single()` لتجنب الأخطاء في حالة عدم وجود بيانات

  setState(() {
    isFollowing = response != null; // إذا كان هناك صف، فهذا يعني أن المستخدم يتابع الصحفي
  });
}

  Future<void> _loadData() async {
    setState(() {
      isUserLoading = true;
      isPostsLoading = true;
    });
    await Future.wait([fetchUserData(), _fetchJournalistPosts()]);
  }

  Future<void> _fetchJournalistPosts() async {
    try {
      final supabase = Supabase.instance.client;
      // جلب المنشورات
      final postsData = await supabase
          .from('posts')
          .select()
          .eq('journalist_id', widget.reporterId)
          .order('created_at', ascending: false);

      setState(() {
        posts = List<Map<String, dynamic>>.from(postsData);
        isPostsLoading = false;
      });
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() {
        isPostsLoading = false;
      });
    }
  }

  Future<void> fetchUserData() async {
    print('Fetching user data${widget.userId}');
    try {
      final userId = widget.userId;
      print('User ID: $userId');
      final userData = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      setState(() {
        _user = UserModel.fromJson(userData);
        profileImageUrl = _user!.profilePicture != null
            ? Supabase.instance.client.storage.from('images').getPublicUrl(
                'profiles/${_user!.profilePicture!.split('/').last}')
            : null;
        isUserLoading = false;
      });
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        isUserLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ملف الصحفي',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: isUserLoading
                        ? null
                        : profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : const AssetImage('assets/image.png')
                                as ImageProvider,
                  ),
                  if (isUserLoading)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: isUserLoading
                  ? const CircularProgressIndicator()
                  : UserNameAndIdentifier(
                      name: _user?.username ?? '',
                      identifier: _user?.identifier ?? '-',
                    ),
            ),
            const SizedBox(height: 16.0),
            
            const SizedBox(height: 12.0),
            Center(
              child:   (_user!.bio != null && _user!.bio!.isNotEmpty)?
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF16213E),
                        const Color(0xFF16213E).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.blue,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'الوصف',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _user!.bio!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[300],
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ):Container(),
              
              
            ),
            const SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ميزة مشاركة الملف الشخصي ستكون متوفرة قريبا'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'مشاركة الملف الشخصي',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
  onPressed: isLoadingFollow ? null : toggleFollow, // تعطيل الزر أثناء التنفيذ
  style: ElevatedButton.styleFrom(
    backgroundColor: isFollowing ? Colors.red : Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: primaryColor,
      ),
    ),
  ),
  child: isLoadingFollow
      ? const CircularProgressIndicator(color: Colors.white)
      : Text(
          isFollowing ? 'الغاء المتابعة' : 'متابعة',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isFollowing ? Colors.white : primaryColor,
          ),
        ),
),
],
            ),
            const SizedBox(height: 18.0),
            Text(
              'المنشورات',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            isPostsLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    children: posts.map((post) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CommentsPage(
                                post: ReporterPost(
                                    postId: post['post_id'],
                                    content: post['content'],
                                    createdAt: post['created_at'],
                                    likesCount: post['likes_count'].toString(),
                                    comments_count:
                                        post['comments_count'].toString(),
                                    image: post['image_url'],
                                    userId: _user!.id,
                                    privacy: post['privacy'],
                                    journalistId:
                                        post['journalist_id'].toString(),
                                    journalistName: _user!.username,
                                    journalistIdentifier:
                                        _user?.identifier ?? '--',
                                    journalistProfilePicture:
                                        profileImageUrl ?? ''));
                          }));
                        },
                        child: ProfilePosts(
                          image: post['image_url'] ?? '',
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  
}
