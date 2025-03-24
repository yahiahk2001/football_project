import 'dart:io';
import 'package:flutter/material.dart';
import 'package:football_project/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class EditPostPage extends StatefulWidget {
  final ReporterPost post;
  
  const EditPostPage({
    super.key,
    required this.post,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _contentController = TextEditingController();
  String _postType = 'Public';
  File? _postImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // تهيئة القيم الأولية من المنشور الحالي
    _contentController.text = widget.post.content;
    _postType = widget.post.privacy;
    _currentImageUrl = widget.post.image;
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _postImage = File(image.path);
          _currentImageUrl = null; // مسح الصورة القديمة عند اختيار صورة جديدة
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_postImage == null) return _currentImageUrl;
    
    try {
      // حذف الصورة القديمة إذا كانت موجودة
      if (_currentImageUrl != null) {
        final oldFileName = path.basename(_currentImageUrl!);
        await _supabase.storage.from('posts').remove([oldFileName]);
      }

      final fileName = '${DateTime.now().toIso8601String()}_${path.basename(_postImage!.path)}';
      await _supabase.storage.from('posts').upload(fileName, _postImage!);
      return _supabase.storage.from('posts').getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _updatePost() async {
   

    setState(() => _isLoading = true);
    
    try {
      String? imageUrl = await _uploadImage();

      await _supabase.from('posts').update({
        'content': _contentController.text,
        'image_url': imageUrl,
        'privacy': _postType,
      }).eq('post_id', widget.post.postId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث المنشور بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating post: $e')),
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
          'تعديل المنشور',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          // DropdownButton(
          //   value: _postType,
          //   items: const [
          //     DropdownMenuItem(child: Text('Public'), value: 'Public'),
          //     DropdownMenuItem(child: Text('Private'), value: 'Private'),
          //   ],
          //   onChanged: (value) {
          //     setState(() {
          //       _postType = value.toString();
          //     });
          //   },
          // )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                child: Image.file(_postImage!, height: 200),
              )
            else if (_currentImageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(_currentImageUrl!, height: 200),
              ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : pickImage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.image),
              label: const Text(
                'تغيير الصورة',
                style: TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                ? const CircularProgressIndicator(color: Colors.greenAccent)
                : const Text(
                    'تحديث المنشور',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}