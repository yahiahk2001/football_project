import 'package:flutter/material.dart';
import 'package:football_project/game/games_page.dart';
import 'package:football_project/pages/edit_profile.dart';
import 'package:football_project/pages/football_page.dart';
import 'package:football_project/pages/new_user_dialog.dart';
import 'package:football_project/pages/posts_page.dart';
import 'package:football_project/pages/settings_page.dart';
import 'package:football_project/pages/stores_page.dart';
import 'package:football_project/widgets/advance_appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {

    super.initState();
    _tabController = TabController(length: 5, vsync: this);
      WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNewUser();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _checkIfNewUser() async {
    // احصل على معرف المستخدم الحالي من نظام المصادقة الخاص بك
    String currentUserId = Supabase.instance.client.auth.currentUser!.id; // قم بتنفيذ هذه الدالة حسب نظام المصادقة الخاص بك
    
    bool shouldCompleteProfile = await NewUserDialog.showProfileCompletionDialog(context, currentUserId);
    
    if (shouldCompleteProfile) {
      // التنقل إلى صفحة الملف الشخصي
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const UpdateProfilePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(_tabController),
      body: TabBarView(
        controller: _tabController,
        children: [
          const PostsPage(),
          const FootballPage(),
         

          const GamesPage(),
          StoresPage(),
          const SettingsPage(),
          
        ],
      ),
    );
  }
}










