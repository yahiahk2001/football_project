import 'package:flutter/material.dart';
import 'package:football_project/admins/dashboard.dart';
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
  String _languageSelected = 'English';

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
              const SectionTitle('General'),
              SettingsOption(
                icon: LucideIcons.bell,
                title: 'Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              SettingsOption(
                icon: LucideIcons.moon,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              SettingsOption(
                icon: LucideIcons.globe,
                title: 'Language',
                trailing: DropdownButton<String>(
                  value: _languageSelected,
                  items: ['English', 'العربية']
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
              const SectionTitle('Account'),
              SettingsOption(
                icon: LucideIcons.user,
                title: 'My Profile',
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
                title: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage()),
                  );
                },
              ),
              const Divider(),
              const SectionTitle('Admin'),
              SettingsOption(
                icon: LucideIcons.users,
                title: 'Admin dashboard',
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
                    if (userRole == 'moderator'|| userRole == 'Moderator') {
                     Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ModerationDashboardPage()),
                );
                    }  else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('لا تمتلك الصلاحية')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching user role: $e')),
                    );
                  }
                },
              
              ),
              const Divider(),
              const SectionTitle('App'),
              SettingsOption(
                icon: LucideIcons.info,
                title: 'Share App',
                onTap: () {},
              ),
              SettingsOption(
                icon: LucideIcons.info,
                title: 'About',
                onTap: () {
                  // Navigate to about page
                },
              ),
              SettingsOption(
                icon: LucideIcons.logOut,
                title: 'Logout',
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
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
