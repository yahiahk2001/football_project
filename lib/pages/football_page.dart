

import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/pages/matchs_page.dart';
import 'package:football_project/pages/standings_page.dart';
import 'package:football_project/state_managment/posts_controller.dart';
import 'package:football_project/widgets/general_post_card.dart';
import 'package:get/get.dart';

class FootballPage extends StatefulWidget {
  const FootballPage({super.key});

  @override
  _FootballPageState createState() => _FootballPageState();
}
class _FootballPageState extends State<FootballPage> {
   int _selectedIndex = 0;
  late final PostsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostsController());
    
    // تأخير استدعاء جلب البيانات بعد التهيئة الكاملة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchGeneralPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const MatchesPage(),
      const StandingsPage(),
      _GeneralNewsList(controller: controller),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'المباريات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'الترتيب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'اخبار الصخف',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        backgroundColor: primaryColor,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _GeneralNewsList extends StatelessWidget {
  final PostsController controller;

  const _GeneralNewsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.generalPosts.isEmpty) {
        return const Center(child: Text("لا توجد أخبار"));
      }
      
      return ListView.builder(
        itemCount: controller.generalPosts.length,
        itemBuilder: (context, index) {
          final post = controller.generalPosts[index];
          return GeneralNewsCard(
            title: post['content'] ?? post['title'] ?? 'No title',
            image: post['image'] ?? 'https://bitsofco.de/img/Qo5mfYDE5v-350.png',
            author: post['author'] ?? 'Unknown',
            timeAgo: post['createdAt'] ?? post['timeAgo'] ?? 'Unknown',
          );
        },
      );
    });
  }
}