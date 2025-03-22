import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';

class CustomSocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CustomSocialButton({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle social login
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: lightTextColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
