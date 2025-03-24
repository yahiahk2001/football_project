import 'package:flutter/material.dart';
import 'package:football_project/admins/dashboard.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/pages/change_password_page.dart';
import 'package:football_project/pages/login_page.dart';
import 'package:football_project/pages/owen_reporter_profile_page.dart';
import 'package:football_project/pages/owen_user_profile.dart';
import 'package:football_project/theme_provider.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _languageSelected = 'العربية';
  String? userRole; // لتخزين دور المستخدم
  bool isLoading = true; // للتحكم في تحميل البيانات

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "تأكيد تسجيل الخروج",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          "هل أنت متأكد أنك تريد تسجيل الخروج؟",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "إلغاء",
              style: TextStyle(color: goldColor, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}
  Future<void> fetchUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('user_id', userId)
          .single();

      if (response.containsKey('role')) {
        setState(() {
          userRole = response['role'];
          isLoading = false;
        });
      }
      print('User role: $userRole');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('عام'),
              SettingsOption(
                icon: LucideIcons.bell,
                title: 'الإشعارات',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                       ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ميزة الإشعارات ستكون متاحة قريباً'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              SettingsOption(
                icon: LucideIcons.moon,
                title: 'الوضع المظلم',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              SettingsOption(
                icon: LucideIcons.globe,
                title: 'اللغة',
                trailing: DropdownButton<String>(
                  value: _languageSelected,
                  items: ['العربية', 'English']
                      .map((language) => DropdownMenuItem<String>(
                            value: language,
                            child: Text(language),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _languageSelected = value!;
                    });
                  },
                ),
              ),
              const Divider(),
              const SectionTitle('الحساب'),
              SettingsOption(
                icon: LucideIcons.user,
                title: 'الملف الشخصي',
                onTap: () async {
                  try {
                    // احصل على معرف المستخدم الحالي
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;

                    if (userId == null) {
                      // في حالة عدم وجود مستخدم مسجل دخول
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    // استعلام للحصول على دور المستخدم
                    final response = await Supabase.instance.client
                        .from('users')
                        .select('role')
                        .eq('user_id', userId)
                        .single();
                    print(response);

                    if (!response.containsKey('role')) {
                      throw Exception('Role not found');
                    }

                    final userRole = response['role'];
                    print(userRole);

                    // توجيه المستخدم بناءً على الدور
                    if (userRole == 'Reporter') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const OwenReporterProfilePage()),
                      );
                    } else if (userRole == 'Visitor') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OwenUserProfilePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid user role')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching user role: $e')),
                    );
                  }
                },
              ),
              SettingsOption(
                icon: LucideIcons.lock,
                title: 'تغيير كلمة المرور',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage()),
                  );
                },
              ),
             (userRole == 'moderator'|| userRole == 'Moderator') ?const Divider():SizedBox(), 
             (userRole == 'moderator'|| userRole == 'Moderator') ? const SectionTitle('Admin'):SizedBox(),
              (userRole == 'moderator'|| userRole == 'Moderator') ? SettingsOption(
                icon: LucideIcons.users,
                title: 'Admin dashboard',
                onTap: () async {
                  try {

                    
                     Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ModerationDashboardPage()),
                );
                    
                   
                    
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching user role: $e')),
                    );
                  }
                },
              
              ):SizedBox(),
              const Divider(),
              const SectionTitle('المزيد'),
              SettingsOption(
                icon: LucideIcons.share,
                title: 'مشاركة التطبيق',
                onTap: () {},
              ),
              SettingsOption(
                icon: LucideIcons.info,
                title: 'عن التطبيق',
                onTap: () {
                  
                },
              ),
              SettingsOption(
                icon: LucideIcons.logOut,
                title: 'تسجيل الخروج',
                onTap: () => _showLogoutDialog(context),

              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 24.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
