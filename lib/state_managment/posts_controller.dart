import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:football_project/models/post_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class PostsController extends GetxController {
  var reporterPosts = <dynamic>[].obs;
  var generalPosts = <dynamic>[].obs;
  var followingJournalistsPosts = <dynamic>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var reachedEndReporter = false.obs;
  var reachedEndFollowing = false.obs;
  late final RealtimeChannel _postsSubscription;
  
  // Pagination parameters
  final int _limit = 10;
  int _reporterOffset = 0;
  int _followingOffset = 0;

  @override
  void onInit() {
    super.onInit();
    _initRealtimeSubscription();
    
    // تأخير استدعاء الطرق لضمان اكتمال دورة البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchReporterPosts();
      fetchFollowingJournalistsPosts(Supabase.instance.client.auth.currentUser!.id);
    });
  }

  void _initRealtimeSubscription() {
    final supabase = Supabase.instance.client;
    _postsSubscription = supabase.realtime.channel('public:posts');

    _postsSubscription
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            if (payload.eventType == 'INSERT') {
              _handleNewPost(payload.newRecord);
            } else if (payload.eventType == 'DELETE') {
              _handleDeletedPost(payload.oldRecord);
            } else if (payload.eventType == 'UPDATE') {
              _handleUpdatedPost(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  void _handleNewPost(Map<String, dynamic> newPost) {
    try {
      final post = ReporterPost.fromJson(newPost);
      reporterPosts.insert(0, post);
    } catch (e) {
      print('Error handling new post: $e');
    }
  }

  void _handleDeletedPost(Map<String, dynamic> deletedPost) {
    try {
      reporterPosts.removeWhere((post) => post.postId == deletedPost['post_id']);
      followingJournalistsPosts.removeWhere((post) => post.postId == deletedPost['post_id']);
    } catch (e) {
      print('Error handling deleted post: $e');
    }
  }

  void _handleUpdatedPost(Map<String, dynamic> updatedPost) {
    try {
      final postId = updatedPost['post_id'];
      
      // Update in reporterPosts
      final reporterIndex = reporterPosts.indexWhere((post) => post.postId == postId);
      if (reporterIndex != -1) {
        reporterPosts[reporterIndex] = ReporterPost.fromJson(updatedPost);
      }
      
      // Update in followingJournalistsPosts
      final followingIndex = followingJournalistsPosts.indexWhere((post) => post.postId == postId);
      if (followingIndex != -1) {
        followingJournalistsPosts[followingIndex] = ReporterPost.fromJson(updatedPost);
      }
    } catch (e) {
      print('Error handling updated post: $e');
    }
  }

  final String apiKey = 'd87e200a0189479daad664888bd8b557';
  Future<void> fetchGeneralPosts() async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      DateTime now = DateTime.now();
      DateTime fiveDaysAgo = now.subtract(const Duration(days: 10));
      String formattedDate = DateFormat('yyyy-MM-dd').format(fiveDaysAgo);

      final url = Uri.parse(
          'https://newsapi.org/v2/everything?sortBy=published&q=برشلونة OR ريال مدريد OR ميسي OR الدوري&from=$formattedDate&apiKey=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List).map((article) {
          return {
            "title": article['description'] ?? 'No title',
            "image": article['urlToImage'] ??
                'https://bitsofco.de/img/Qo5mfYDE5v-350.png',
            "author": article['source']['name'] ?? 'Unknown',
            "timeAgo": timeago.format(DateTime.parse(article['publishedAt'])),
          };
        }).toList();
        
        generalPosts.assignAll(articles.reversed.toList());
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      // استخدام Get.engine.addPostFrameCallback لتأخير تحديث isLoading
      Get.engine.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchReporterPosts() async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      final supabase = Supabase.instance.client;
      final postsData = await supabase
          .from('posts')
          .select(
              'post_id, content, image_url, privacy, created_at, likes_count, comments_count, journalist_id, journalists(journalist_id, user_id, journalist_code, created_at, users(user_id, username, identifier, role, bio, favoriteClub, profile_picture))')
          .eq('is_hidden', false)
          .order('created_at', ascending: false)
          .limit(_limit);

      _reporterOffset = postsData.length;
      final posts = (postsData as List)
          .map((post) => ReporterPost.fromJson(post))
          .toList();
          
      reporterPosts.assignAll(posts);
      reachedEndReporter.value = postsData.length < _limit;
    } catch (e) {
      print('Error fetching reporter posts: $e');
    } finally {
      // استخدام Get.engine.addPostFrameCallback لتأخير تحديث isLoading
      Get.engine.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  Future<void> loadMoreReporterPosts() async {
    if (isLoadingMore.value || reachedEndReporter.value) return;
    
    try {
      isLoadingMore.value = true;
      
      final supabase = Supabase.instance.client;
      final postsData = await supabase
          .from('posts')
          .select(
              'post_id, content, image_url, privacy, created_at, likes_count, comments_count, journalist_id, journalists(journalist_id, user_id, journalist_code, created_at, users(user_id, username, identifier, role, bio, favoriteClub, profile_picture))')
          .eq('is_hidden', false)
          .order('created_at', ascending: false)
          .range(_reporterOffset, _reporterOffset + _limit - 1);

      final newPosts = (postsData as List)
          .map((post) => ReporterPost.fromJson(post))
          .toList();
          
      if (newPosts.isNotEmpty) {
        reporterPosts.addAll(newPosts);
        _reporterOffset += newPosts.length;
      }
      
      reachedEndReporter.value = postsData.length < _limit;
    } catch (e) {
      print('Error loading more reporter posts: $e');
    } finally {
      // استخدام Get.engine.addPostFrameCallback لتأخير تحديث isLoadingMore
      Get.engine.addPostFrameCallback((_) {
        isLoadingMore.value = false;
      });
    }
  }

  Future<void> fetchFollowingJournalistsPosts(String userId) async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      // يجب مسح البيانات السابقة باستخدام clear() بدلاً من تعيين قيمة جديدة
      followingJournalistsPosts.clear();
      _followingOffset = 0;
      
      final supabase = Supabase.instance.client;

      // جلب قائمة الصحفيين الذين يتابعهم المستخدم
      final followingJournalists = await supabase
          .from('journalist_followers')
          .select('journalist_id')
          .eq('follower_id', userId);

      if (followingJournalists.isEmpty) {
        print('No following journalists');
        reachedEndFollowing.value = true;
        return;
      }

      final journalistIds = followingJournalists.map((e) => e['journalist_id'] as int).toList();
      print('Following journalists: $journalistIds');

      final postsData = await supabase
          .from('posts')
          .select(
              'post_id, content, image_url, privacy, created_at, likes_count, comments_count, journalist_id, journalists(journalist_id, user_id, journalist_code, created_at, users(user_id, username, identifier, role, bio, favoriteClub, profile_picture))')
          .inFilter('journalist_id', journalistIds)
          .eq('is_hidden', false)
          .order('created_at', ascending: false)
          .limit(_limit);

      _followingOffset = postsData.length;
      final posts = (postsData as List)
          .map((post) => ReporterPost.fromJson(post))
          .toList();
      
      followingJournalistsPosts.assignAll(posts);
      
      print('Fetched following journalists posts: ${followingJournalistsPosts.length}');
      
      reachedEndFollowing.value = postsData.length < _limit;
    } catch (e) {
      print('Error fetching following journalists posts: $e');
      followingJournalistsPosts.clear();  // Clear on error to avoid showing incorrect data
    } finally {
      // استخدام Get.engine.addPostFrameCallback لتأخير تحديث isLoading
      Get.engine.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  Future<void> loadMoreFollowingPosts(String userId) async {
    if (isLoadingMore.value || reachedEndFollowing.value) return;
    
    try {
      isLoadingMore.value = true;
      
      final supabase = Supabase.instance.client;

      final followingJournalists = await supabase
          .from('journalist_followers')
          .select('journalist_id')
          .eq('follower_id', userId);

      if (followingJournalists.isEmpty) {
        reachedEndFollowing.value = true;
        return;
      }

      final journalistIds = followingJournalists.map((e) => e['journalist_id'] as int).toList();

      final postsData = await supabase
          .from('posts')
          .select(
              'post_id, content, image_url, privacy, created_at, likes_count, comments_count, journalist_id, journalists(journalist_id, user_id, journalist_code, created_at, users(user_id, username, identifier, role, bio, favoriteClub, profile_picture))')
          .inFilter('journalist_id', journalistIds)
          .eq('is_hidden', false)
          .order('created_at', ascending: false)
          .range(_followingOffset, _followingOffset + _limit - 1);

      final newPosts = (postsData as List)
          .map((post) => ReporterPost.fromJson(post))
          .toList();
      
      print('Loaded more following posts: ${newPosts.length}');
      
      if (newPosts.isNotEmpty) {
        followingJournalistsPosts.addAll(newPosts);
        _followingOffset += newPosts.length;
      }
      
      reachedEndFollowing.value = postsData.length < _limit;
    } catch (e) {
      print('Error loading more following posts: $e');
    } finally {
      // استخدام Get.engine.addPostFrameCallback لتأخير تحديث isLoadingMore
      Get.engine.addPostFrameCallback((_) {
        isLoadingMore.value = false;
      });
    }
  }

  // Reset and refresh methods for pull-to-refresh functionality
  Future<void> resetAndRefreshReporterPosts() async {
    reporterPosts.clear();
    _reporterOffset = 0;
    reachedEndReporter.value = false;
    await fetchReporterPosts();
  }

  Future<void> resetAndRefreshFollowingPosts(String userId) async {
    followingJournalistsPosts.clear();
    _followingOffset = 0;
    reachedEndFollowing.value = false;
    await fetchFollowingJournalistsPosts(userId);
  }

  @override
  void onClose() {
    _postsSubscription.unsubscribe();
    super.onClose();
  }
}