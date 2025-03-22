import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/pages/login_page.dart';
import 'package:football_project/widgets/customSocialButton.dart';
import 'package:football_project/widgets/customTextField.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _userType = 'Visitor';
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _codeController.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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

  Future<void> _registerUser(
      String email, String password, String username, String userType) async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      if (userType == 'Reporter') {
        // التحقق من الكود
        final reporterCode = _codeController.text.trim();

        final response = await supabase
            .from('reporter_keys')
            .select('reporter_key')
            .eq('reporter_key', reporterCode)
            .maybeSingle();

        if (response == null) {
          _showError('Invalid reporter code');
          setState(() => _isLoading = false);
          return;
        }
      }

      // تسجيل المستخدم في Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _showError('Registration failed. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      // إضافة المستخدم إلى جدول users
      final insertResponse = await supabase.from('users').insert({
        'user_id': response.user!.id,
        'email': email,
        'username': username,
        'role': userType,
      }).select();
      if (insertResponse.isEmpty) {
        _showError('Failed to save user data');
        setState(() => _isLoading = false);
        return;
      }

      if (userType == 'Reporter') {
        final insertJournalist = await supabase.from('journalists').insert({
          'user_id': response.user!.id,
          'journalist_code': _codeController.text.trim(),
        }).select();

        if (insertJournalist.isEmpty) {
          _showError('Failed to save journalist data');
          setState(() => _isLoading = false);
          return;
        }

        // حذف الكود بعد استخدامه
        await supabase
            .from('reporter_keys')
            .delete()
            .eq('reporter_key', _codeController.text.trim());
      }

      // النجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please verify your email.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration:const BoxDecoration(
          image:DecorationImage(image: AssetImage(
            'assets/m4.jpg'
          ))
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
                   const SizedBox(
                      height: 100,
                    ),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to get started.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      icon: Icons.person,
                      label: 'Name',
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      toggleObscureText: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      icon: Icons.lock,
                      label: 'Confirm Password',
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      controller: _confirmPasswordController,
                      toggleObscureText: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'I am a',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          fillColor: WidgetStateProperty.all(Colors.cyan),
                          activeColor: Colors.cyanAccent,
                          value: 'Reporter',
                          groupValue: _userType,
                          onChanged: (value) {
                            setState(() {
                              _userType = value!;
                            });
                          },
                        ),
                        const Text(
                          'Media Reporter',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Radio<String>(
                          fillColor: WidgetStateProperty.all(Colors.cyan),
                          activeColor: Colors.cyanAccent,
                          value: 'Visitor',
                          groupValue: _userType,
                          onChanged: (value) {
                            setState(() {
                              _userType = value!;
                            });
                          },
                        ),
                        const Text(
                          style: TextStyle(color: Colors.white),
                          'Visitor',
                        ),
                      ],
                    ),
                    if (_userType == 'Reporter') ...[
                      const SizedBox(height: 8),
                      CustomTextField(
                        icon: Icons.code,
                        label: 'Reporter Code',
                        controller: _codeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter reporter code';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await _registerUser(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                  _usernameController.text.trim(),
                                  _userType,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: primaryColor)
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.white,),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 16,
                            ),
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
                            style: TextStyle(color: lightTextColor),
                          ),
                        ),
                        Expanded(child: Divider(color: lightTextColor)),
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
