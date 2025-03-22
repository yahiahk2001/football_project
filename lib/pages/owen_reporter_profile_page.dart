import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/models/post_model.dart';
import 'package:football_project/models/user_model.dart';
import 'package:football_project/pages/add_post_page.dart';
import 'package:football_project/pages/comments_page.dart';
import 'package:football_project/pages/edit_profile.dart';
import 'package:football_project/widgets/profile_posts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwenReporterProfilePage extends StatefulWidget {
  const OwenReporterProfilePage({super.key});

  @override
  State<OwenReporterProfilePage> createState() =>
      _OwenReporterProfilePageState();
}

class _OwenReporterProfilePageState extends State<OwenReporterProfilePage> {
  String? profileImageUrl;
  bool isLoading = true;
  UserModel? _user;
  List<Map<String, dynamic>> posts = []; // لتخزين المنشورات

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _fetchJournalistPosts();
  }

  Future<void> _fetchJournalistPosts() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // جلب journalist_id
      final journalist = await supabase
          .from('journalists')
          .select('journalist_id')
          .eq('user_id', userId)
          .single();

      // جلب المنشورات
      final postsData = await supabase
          .from('posts')
          .select()
          .eq('journalist_id', journalist['journalist_id'])
          .order('created_at', ascending: false);

      setState(() {
        posts = List<Map<String, dynamic>>.from(postsData);
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching posts: $error');
    }
  }

  Future<void> fetchUserData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final userData = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', userId!)
          .single();

      _user = UserModel.fromJson(userData);
      setState(() {
        profileImageUrl = _user!.profilePicture != null
            ? Supabase.instance.client.storage.from('images').getPublicUrl(
                'profiles/${_user!.profilePicture!.split('/').last}')
            : null;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchUserData();
          await _fetchJournalistPosts();
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : const NetworkImage(
                            'https://bitsofco.de/img/Qo5mfYDE5v-350.png'),
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : UserNameAndIdentifier(
                          name: _user?.username ?? 'No Name',
                          identifier: _user?.identifier ?? '--',
                        ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '122',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Followers',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '67',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Following',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '37K',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Likes',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Center(
                  child: SizedBox(
                      width: 280,
                      child: Text(
                        _user?.bio ?? '',
                        textAlign: TextAlign.center,
                      )),
                ),
                const SizedBox(height: 18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdateProfilePage()),
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
                        'Edit profile',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddPostPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: primaryColor,
                          ),
                        ),
                      ),
                      child: Text(
                        'Add new post',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                isLoading
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
                              // أضف هنا التنقل إلى صفحة تفاصيل المنشور
                            },
                            child: GestureDetector(
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
                      )
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserNameAndIdentifier extends StatelessWidget {
  const UserNameAndIdentifier({
    super.key,
    required this.name,
    required this.identifier,
  });
  final String name;
  final String identifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          identifier,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
