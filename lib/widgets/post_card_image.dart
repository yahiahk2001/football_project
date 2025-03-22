
import 'package:flutter/material.dart';

class PostCardImage extends StatelessWidget {
  final String imageUrl;

  const PostCardImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: imageUrl == ''
          ? Image.network(
              'https://bitsofco.de/img/Qo5mfYDE5v-350.png')
          : Image.network(imageUrl),
    );
  }
}
