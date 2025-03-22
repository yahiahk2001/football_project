import 'dart:io';
import 'package:flutter/material.dart';
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
      print('Error picking image: $e');
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
     
      // رفع الصورة الجديدة
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
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
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
      appBar: AppBar(title: const Text("Update Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null 
                      ? FileImage(_profileImage!)
                      : (_user?.getProfileImageUrl() != null 
                          ? NetworkImage(_user!.getProfileImageUrl()!) as ImageProvider
                          : null),
                  child: (_profileImage == null && _user?.profilePicture == null)
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _identifierController,
                decoration: const InputDecoration(labelText: 'identifier'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              TextField(
                controller: _favoriteClubController,
                decoration: const InputDecoration(labelText: 'Favorite Club'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUpdating ? null : updateProfile,
                child: _isUpdating
                    ? const CircularProgressIndicator()
                    : const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}