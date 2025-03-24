import 'dart:io';
import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:football_project/models/user_model.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  File? _profileImage;
  bool _isUpdating = false;
  UserModel? _user;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _favoriteClubController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = supabase.Supabase.instance.client.auth.currentUser?.id;
      final userData = await supabase.Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', userId!)
          .single();
      
      _user = UserModel.fromJson(userData);
      _usernameController.text = _user!.username;
      _identifierController.text = _user!.identifier ?? '';
      _bioController.text = _user!.bio ?? '';
      _favoriteClubController.text = _user!.favoriteClub ?? '';
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  Future<void> pickImage() async {
    try {
      if (Platform.isAndroid) {
        await requestPermission();
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> updateProfile() async {
    setState(() => _isUpdating = true);

    try {
      String? imagePath;
      if (_profileImage != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        imagePath = 'profiles/$fileName';

        await supabase.Supabase.instance.client.storage
            .from('images')
            .upload(imagePath, _profileImage!);
      }

      final updatedUser = _user!.copyWith(
        username: _usernameController.text,
        identifier: _identifierController.text,
        bio: _bioController.text,
        favoriteClub: _favoriteClubController.text,
        profilePicture: imagePath ?? _user!.profilePicture,
      );

      await supabase.Supabase.instance.client
          .from('users')
          .update(updatedUser.toJson())
          .eq('user_id', _user!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح! 🎉')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التحديث: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isDenied ||
          await Permission.photos.isPermanentlyDenied) {
        await Permission.photos.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحديث الملف الشخصي"),
        centerTitle: true,
        backgroundColor: Color(0xFF1A2A3A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_user?.getProfileImageUrl() != null
                              ? NetworkImage(_user!.getProfileImageUrl()!)
                              : null) as ImageProvider?,
                      child: (_profileImage == null && _user?.profilePicture == null)
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("اسم المستخدم", _usernameController, Icons.person),
              _buildTextField("المعرف", _identifierController, Icons.badge),
              _buildTextField("السيرة الذاتية", _bioController, Icons.info),
              _buildTextField("النادي المفضل", _favoriteClubController, Icons.sports_soccer),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تحديث الملف الشخصي', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF4CAF50)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70), // لون الإطار عند عدم التحديد
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color:accentColor, width: 2), // لون الإطار عند التحديد
        ),
      ),
    ),
  );
}

}
