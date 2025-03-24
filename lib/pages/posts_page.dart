import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/pages/add_post_page.dart';
import 'package:football_project/state_managment/posts_controller.dart';
import 'package:football_project/widgets/post_card.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with SingleTickerProviderStateMixin {
  final PostsController controller = Get.put(PostsController());
  final ScrollController _reporterScrollController = ScrollController();
  final ScrollController _followingScrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initial data loading
    controller.fetchReporterPosts();
    controller.fetchFollowingJournalistsPosts(
        Supabase.instance.client.auth.currentUser!.id);

    // Add scroll listeners for lazy loading
    _reporterScrollController.addListener(_scrollReporterListener);
    _followingScrollController.addListener(_scrollFollowingListener);

    // Add tab listener to ensure data is loaded when switching tabs
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 1 &&
        controller.followingJournalistsPosts.isEmpty) {
      // If switching to following tab and it's empty, try loading data again
      controller.fetchFollowingJournalistsPosts(
          Supabase.instance.client.auth.currentUser!.id);
    }
  }

  void _scrollReporterListener() {
    if (_reporterScrollController.hasClients &&
        _reporterScrollController.position.pixels >=
            _reporterScrollController.position.maxScrollExtent - 200 &&
        !controller.isLoadingMore.value &&
        !controller.reachedEndReporter.value) {
      controller.loadMoreReporterPosts();
    }
  }

  void _scrollFollowingListener() {
    if (_followingScrollController.hasClients &&
        _followingScrollController.position.pixels >=
            _followingScrollController.position.maxScrollExtent - 200 &&
        !controller.isLoadingMore.value &&
        !controller.reachedEndFollowing.value) {
      controller.loadMoreFollowingPosts(
          Supabase.instance.client.auth.currentUser!.id);
    }
  }

  Future<bool> isReporter() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final userData = await supabase
          .from('users')
          .select('role')
          .eq('user_id', userId)
          .single();

      return userData['role'] == 'Reporter';
    } catch (e) {
      print('Error checking reporter status: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _reporterScrollController.removeListener(_scrollReporterListener);
    _followingScrollController.removeListener(_scrollFollowingListener);
    _reporterScrollController.dispose();
    _followingScrollController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FutureBuilder<bool>(
        future: isReporter(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPostPage()),
                );
                controller.resetAndRefreshReporterPosts();
              },
              child: const Icon(Icons.add),
            );
          }
          return Container();
        },
      ),
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 4,
          indicatorColor: Colors.yellowAccent,
          tabs: const [
            Tab(
              child: Text("كل الصحفيين",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            Tab(
              child: Text("أتابعه",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReporterTab(),
          _buildFollowingTab(),
        ],
      ),
    );
  }

  Widget _buildReporterTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.reporterPosts.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: accentColor));
      }

      if (controller.reporterPosts.isEmpty) {
        return const Center(child: Text("لا توجد أخبار"));
      }

      return RefreshIndicator(
        onRefresh: () => controller.resetAndRefreshReporterPosts(),
        child: ListView.builder(
          controller: _reporterScrollController,
          itemCount: controller.reporterPosts.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.reporterPosts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: accentColor),
                ),
              );
            }

            final post = controller.reporterPosts[index];
            return Builder(
              builder: (context) => NewsCard(post: post),
            );
          },
        ),
      );
    });
  }

  Widget _buildFollowingTab() {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.followingJournalistsPosts.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: accentColor));
      }

      if (controller.followingJournalistsPosts.isEmpty &&
          !controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You are not following any journalists."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchFollowingJournalistsPosts(
                    Supabase.instance.client.auth.currentUser!.id),
                child: const Text("Refresh"),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.resetAndRefreshFollowingPosts(
            Supabase.instance.client.auth.currentUser!.id),
        child: ListView.builder(
          controller: _followingScrollController,
          itemCount: controller.followingJournalistsPosts.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.followingJournalistsPosts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: accentColor),
                ),
              );
            }

            final post = controller.followingJournalistsPosts[index];
            return Builder(
              builder: (context) => NewsCard(post: post),
            );
          },
        ),
      );
    });
  }
}
