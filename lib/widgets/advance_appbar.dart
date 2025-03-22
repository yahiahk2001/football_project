import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/pages/search_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController _tabController;
  const MyAppBar(this._tabController, {super.key});

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}

class _MyAppBarState extends State<MyAppBar> {
  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Football Arena',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _navigateToSearch,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: TabBar(
          controller: widget._tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(LucideIcons.home, color: Colors.white, size: 18)),
            Tab(icon: Icon(Icons.sports, color: Colors.white, size: 18)),
            Tab(icon: Icon(LucideIcons.gamepad, color: Colors.white, size: 18)),
            Tab(icon: Icon(LucideIcons.store, color: Colors.white, size: 18)),
            Tab(icon: Icon(LucideIcons.menu, color: Colors.white, size: 18)),
          ],
        ),
      ),
    );
  }
}