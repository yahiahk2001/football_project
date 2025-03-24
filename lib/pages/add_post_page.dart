import 'dart:io';
import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _contentController = TextEditingController();
  String _postType = 'عام';
  File? _postImage;
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _postImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_postImage == null) return null;
    
    try {
      final fileName = '${DateTime.now().toIso8601String()}_${path.basename(_postImage!.path)}';
      await _supabase.storage.from('posts').upload(fileName, _postImage!);
      return _supabase.storage.from('posts').getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _submitPost() async {
   

    setState(() => _isLoading = true);
    
    try {
      // Get journalist ID from journalists table
      final userId = _supabase.auth.currentUser!.id;
      final journalist = await _supabase
          .from('journalists')
          .select('journalist_id')
          .eq('user_id', userId)
          .single();
      
      final journalistId = journalist['journalist_id'];
      String? imageUrl;
      
      if (_postImage != null) {
        imageUrl = await _uploadImage();
      }

      await _supabase.from('posts').insert({
        'journalist_id': journalistId,
        'content': _contentController.text,
        'image_url': imageUrl,
        'privacy': _postType,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'اضافة منشور',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          DropdownButton(
          value: _postType,
            items: 
          const [
            DropdownMenuItem(value: 'عام', child: Text('عام')),
            DropdownMenuItem(value: 'خاص', child: Text('خاص')),
          ], onChanged: (value) {
            setState(() {
              _postType = value.toString();
            });
          })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF95A5A6).withOpacity(0.2),
                hintText: 'محتوى المنشور',
                hintStyle: const TextStyle(
                  color: Color(0xFF95A5A6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_postImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.file(_postImage!),
              ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : pickImage,
              style: ElevatedButton.styleFrom(
                 backgroundColor:accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.image, ),
              label: const Text(
                'اختيار صورة',
                style: TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor:alertColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.greenAccent)
                  : const Text(
                      'نشر',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}