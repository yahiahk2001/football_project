
import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleObscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.icon,
    required this.label,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleObscureText,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      style: const TextStyle(color: textColor),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: lightTextColor),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: goldColor,
                ),
                onPressed: toggleObscureText,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightTextColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightTextColor),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}