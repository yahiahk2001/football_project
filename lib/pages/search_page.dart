// File: search_page.dart
import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/pages/owen_reporter_profile_page.dart';
import 'package:football_project/pages/owen_user_profile.dart';
import 'package:football_project/pages/reporter_profile.dart';
import 'package:football_project/pages/user_profile.dart';
import 'package:football_project/state_managment/posts_controller.dart';
import 'package:football_project/widgets/post_card.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResultsUsers = [];
  bool isLoadingUsers = false;
  final PostsController postsController = Get.put(PostsController());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResultsUsers = [];
        isLoadingUsers = false;
      });
      return;
    }

    setState(() {
      isLoadingUsers = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('user_id, username, identifier, profile_picture,role,favoriteClub,bio')
          .or('username.ilike.%$query%,identifier.ilike.%$query%')
          .limit(20);

      setState(() {
        searchResultsUsers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في البحث: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      postsController.reporterPosts.value = [];
      return;
    }
    // await postsController.searchReporterPosts(query);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (value == _searchController.text) {
                  searchUsers(value);
                  searchPosts(value);
                }
              });
            },
            decoration: const InputDecoration(
              hintText: 'ابحث عن مستخدم أو منشور...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.yellowAccent,
            tabs: [
              Tab(
                child: Text(
                  "الاشخاص",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Tab(
                child: Text(
                  " منشورات",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersTab(),
            _buildPostsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchResultsUsers.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(child: Text('لا توجد نتائج للمستخدمين.'));
    }
    return ListView.builder(
      itemCount: searchResultsUsers.length,
      itemBuilder: (context, index) {
        final user = searchResultsUsers[index];
        final imageUrl = user['profile_picture'] != null
            ? Supabase.instance.client.storage
                .from('images')
                .getPublicUrl(user['profile_picture'])
            : null;
        return GestureDetector(
          onTap: () async {
            final String myId = Supabase.instance.client.auth.currentUser!.id;
            final String userId = user['user_id'];
            final String role = user['role'] ?? 'User';
            final String? profilePicture = user['profile_picture'];

            String? profileImageUrl;
            if (profilePicture != null) {
              profileImageUrl = Supabase.instance.client.storage
                  .from('images')
                  .getPublicUrl(profilePicture);
            }

            // إنشاء كائن UserModel من البيانات المتاحة
            final UserModel userModel = UserModel(
              id: userId,
              username: user['username'] ?? 'مستخدم',
              identifier: user['identifier'] ?? '',
              role: role,
              favoriteClub: user['favorite_club'] ?? '',
              bio: user['bio'] ?? '',
              profilePicture: profilePicture,
              email: '',
            );

            if (userId == myId) {
              // إذا كان المستخدم هو المستخدم الحالي
              if (role == 'Reporter') {
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
              // إذا كان المستخدم مستخدمًا آخر
              if (role == 'Reporter') {
                try {
                  var journalist = await Supabase.instance.client
                      .from('journalists')
                      .select()
                      .eq('user_id', userId)
                      .single();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReporterProfilePage(
                        reporterId: journalist['journalist_id'].toString(),
                        userId: userId,
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
                      user: userModel,
                      userImageUrl: profileImageUrl,
                    ),
                  ),
                );
              }
            }
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(user['username'] ?? 'مستخدم'),
            subtitle: Text(user['identifier'] ?? ''),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return Obx(() {
      if (postsController.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(
          color: Colors.green,
        ));
      }
      if (postsController.reporterPosts.isEmpty &&
          _searchController.text.isNotEmpty) {
        return const Center(child: Text('لا توجد نتائج للمنشورات.'));
      }
      return ListView.builder(
        itemCount: postsController.reporterPosts.length,
        itemBuilder: (context, index) {
          final post = postsController.reporterPosts[index];
          return NewsCard(post: post);
        },
      );
    });
  }
}
