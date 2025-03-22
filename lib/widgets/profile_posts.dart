import 'package:flutter/material.dart';

class ProfilePosts extends StatelessWidget {
  const ProfilePosts({super.key, required this.image});
  final String image;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        image.isEmpty
            ? 'https://img.freepik.com/premium-vector/no-photo-available-vector-icon-default-image-symbol-picture-coming-soon-web-site-mobile-app_87543-18055.jpg'
            : image,
        fit: BoxFit.cover,
      ),
    );
  }
}