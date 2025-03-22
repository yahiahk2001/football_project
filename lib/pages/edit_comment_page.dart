import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class EditCommentPage extends StatefulWidget {
  final comment;
  
  const EditCommentPage({
    super.key,
    required this.comment,
  });

  @override
  State<EditCommentPage> createState() => _EditCommentPageState();
}

class _EditCommentPageState extends State<EditCommentPage> {
  final _contentController = TextEditingController();

  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // تهيئة القيم الأولية من المنشور الحالي
    _contentController.text = widget.comment['content'];

  }




  Future<void> _updatePost() async {
   

    setState(() => _isLoading = true);
    
    try {

      await _supabase.from('comments').update({
        'content': _contentController.text,

      }).eq('comment_id', widget.comment['comment_id']);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('comment updated successfully')),
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
          'Edit comment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
       
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
                hintText: 'Write your comment here...',
                hintStyle: const TextStyle(
                  color: Color(0xFF95A5A6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
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
                    'Update comment',
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