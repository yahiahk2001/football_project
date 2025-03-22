import 'package:flutter/material.dart';
import 'package:football_project/game/games_page.dart';
import 'package:football_project/pages/football_page.dart';
import 'package:football_project/pages/posts_page.dart';
import 'package:football_project/pages/settings_page.dart';
import 'package:football_project/pages/stores_page.dart';
import 'package:football_project/widgets/advance_appbar.dart';


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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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










