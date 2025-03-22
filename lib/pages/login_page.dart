import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/pages/forget_password_page.dart';
import 'package:football_project/pages/home_page.dart';
import 'package:football_project/pages/register_page.dart';
import 'package:football_project/widgets/customSocialButton.dart';
import 'package:football_project/widgets/customTextField.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (response.user != null) {
          // تسجيل الدخول ناجح
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          
          image: DecorationImage(
            
            image: AssetImage('assets/gp.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 200),
                    //   child: Center(
                    //     child: Image.asset(
                    //      'assets/logo1.png',
                    //       width: 164,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 80,
                    
                    ),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue.',
                      style: TextStyle(fontSize: 16, color: lightTextColor),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      icon: Icons.email,
                      label: 'Email',
                      controller: _emailController,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      icon: Icons.lock,
                      label: 'Password',
                      isPassword: true,
                      obscureText: _obscureText,
                      controller: _passwordController,
                      toggleObscureText: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: accentColor,
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()),
                            );
                          },
                          child: const Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: lightTextColor)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(child: Divider(color: textColor)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSocialButton(
                          icon: Icons.email,
                          color: Colors.red,
                        ),
                        SizedBox(width: 16),
                        CustomSocialButton(
                          icon: Icons.facebook,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 16),
                        CustomSocialButton(
                          icon: Icons.apple,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
