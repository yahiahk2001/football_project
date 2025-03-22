import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/models/user_model.dart';
import 'package:football_project/pages/edit_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwenUserProfilePage extends StatefulWidget {
  const OwenUserProfilePage({super.key});

  @override
  State<OwenUserProfilePage> createState() => _OwenUserProfilePageState();
}

class _OwenUserProfilePageState extends State<OwenUserProfilePage> {
  String? profileImageUrl;
  bool isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
            ? Supabase.instance.client.storage
                .from('images')
                .getPublicUrl('profiles/${_user!.profilePicture!.split('/').last}')
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
Future<void> _refreshPage() async {
    await fetchUserData();
  }
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:primaryColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPage,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF1A1A2E),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdateProfilePage()),
                        );
                    },
                  )
                ],
                expandedHeight: 250,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(profileImageUrl ?? 'https://bitsofco.de/img/Qo5mfYDE5v-350.png'),
                            backgroundColor: Colors.grey[800],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // اسم المستخدم
                        Text(
                          _user?.username  ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        // المعرف
                        Center(
                          child: Text(
                            'ID: --',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
              
                        // معلومات إضافية
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // عدد المتابعين
                            const ProfileInfoCard(
                              title: 'Following',
                              value: '0',
                            ),
                            // النادي المفضل
                            ProfileInfoCard(
                              title: 'Favorite Club',
                              value: _user?.favoriteClub ?? '',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
              
                        // السيرة الذاتية
                        
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16213E),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _user?.bio ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[300],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كلاس بطاقات المعلومات
class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}