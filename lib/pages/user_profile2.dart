import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserProfilePage({
    super.key,
    required this.userData,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? fullUserData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? _getImageUrl(String? imagePath) {
    if (imagePath == null) return null;
    try {
      return Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(imagePath);
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', widget.userData['user_id'])
          .single();

      if (mounted) {
        setState(() {
          fullUserData = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      // نقل إظهار الرسالة إلى بعد اكتمال التهيئة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ في تحميل البيانات: $e')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl(widget.userData['profile_picture']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('الملف الشخصي'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.primary,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.userData['username'] ?? 'مستخدم',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${widget.userData['identifier'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  if (fullUserData != null) ...[
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.sports_soccer),
                      title: const Text('النادي المفضل'),
                      subtitle: Text(
                        fullUserData!['favorite_club'] ?? 'غير محدد',
                      ),
                    ),
                    if (fullUserData!['bio'] != null &&
                        fullUserData!['bio'].toString().isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('نبذة'),
                        subtitle: Text(fullUserData!['bio']),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
