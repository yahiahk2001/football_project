// competitions_standings_page.dart
import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:football_project/widgets/upcomming_matches_card.dart';
import 'package:football_project/widgets/previous_results_card.dart';

class FootballApi {
  final String apiKey = '485a87aafb3c4b8f91bb8b34ac58fb65';
  final String baseUrl = 'https://api.football-data.org/v4';
  final MatchDataCache cache = MatchDataCache();

  // دالة لجلب جميع المباريات من API مرة واحدة وتخزينها في الكاش
  Future<List<Match>> getAllMatches(List<String> teamIds, String season) async {
    // التحقق من وجود بيانات محفوظة في الكاش
    if (cache.allMatches != null && !cache.needsRefresh()) {
      return cache.allMatches!;
    }
    
    // التحقق من أنه لا يوجد طلب جاري بالفعل
    if (cache.isLoading) {
      // انتظار حتى تكتمل عملية التحميل
      while (cache.isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // إذا تم تحميل البيانات بالفعل، إرجاعها
      if (cache.allMatches != null) {
        return cache.allMatches!;
      }
    }
    
    cache.isLoading = true;
    List<Match> allMatches = [];
    
    // إضافة تأخير بين الطلبات لتجنب تجاوز حد الاستخدام
    for (int i = 0; i < teamIds.length; i++) {
      String teamId = teamIds[i];
      try {
        // إضافة تأخير 1.5 ثانية بين كل طلب للـ API
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 1500));
        }
        
        final url = Uri.parse('$baseUrl/teams/$teamId/matches?season=$season');
        final headers = {
          'X-Auth-Token': apiKey,
        };

        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          allMatches.addAll(
            (data['matches'] as List)
                .map((match) => Match.fromJson(match))
                .toList(),
          );
        } else if (response.statusCode == 429) {
          // إذا كان الخطأ هو تجاوز حد الاستخدام، ننتظر وقتًا أطول
          print('تجاوز حد الاستخدام للـ API، انتظار لمدة 5 ثواني للفريق $teamId');
          await Future.delayed(const Duration(seconds: 5));
          i--; // إعادة المحاولة لهذا الفريق
          continue;
        } else {
          print('فشل في تحميل مباريات الفريق $teamId: ${response.statusCode}');
          continue;
        }
      } catch (e) {
        print('خطأ في تحميل مباريات الفريق $teamId: $e');
        continue;
      }
    }
    
    // إزالة التكرارات
    List<Match> uniqueMatches = [];
    Set<String> matchIds = {};
    
    for (var match in allMatches) {
      String matchId = '${match.teamA}_${match.teamB}_${match.utcDate.toIso8601String()}';
      if (!matchIds.contains(matchId)) {
        matchIds.add(matchId);
        uniqueMatches.add(match);
      }
    }
    
    // تحديث الكاش
    cache.allMatches = uniqueMatches;
    cache.isLoading = false;
    cache.isInitialized = true;
    cache.lastUpdated = DateTime.now();
    
    return uniqueMatches;
  }
  
  // دالة للحصول على المباريات القادمة مرتبة من الأقرب إلى الأبعد
  Future<List<Match>> getUpcomingMatches(
      List<String> teamIds, String season, int page, int pageSize) async {
    // جلب جميع المباريات باستخدام الكاش
    final allMatches = await getAllMatches(teamIds, season);
    
    // الحصول على التاريخ الحالي
    final now = DateTime.now();
    
    // تصفية المباريات القادمة فقط
    final upcomingMatches = allMatches
        .where((match) => match.utcDate.isAfter(now))
        .toList();
    
    // ترتيب المباريات القادمة من الأقرب إلى الأبعد
    upcomingMatches.sort((a, b) => a.utcDate.compareTo(b.utcDate));
    
    // تقسيم النتائج حسب الصفحة
    int startIndex = page * pageSize;
    if (startIndex >= upcomingMatches.length) {
      return [];
    }
    
    int endIndex = startIndex + pageSize;
    if (endIndex > upcomingMatches.length) {
      endIndex = upcomingMatches.length;
    }
    
    return upcomingMatches.sublist(startIndex, endIndex);
  }
  
  // دالة للحصول على المباريات السابقة مرتبة من الأحدث إلى الأقدم
  Future<List<Match>> getPreviousMatches(
      List<String> teamIds, String season, int page, int pageSize) async {
    // جلب جميع المباريات باستخدام الكاش
    final allMatches = await getAllMatches(teamIds, season);
    
    // الحصول على التاريخ الحالي
    final now = DateTime.now();
    
    // تصفية المباريات السابقة فقط
    final previousMatches = allMatches
        .where((match) => match.utcDate.isBefore(now))
        .toList();
    
    // ترتيب المباريات السابقة من الأحدث إلى الأقدم
    previousMatches.sort((a, b) => b.utcDate.compareTo(a.utcDate));
    
    // تقسيم النتائج حسب الصفحة
    int startIndex = page * pageSize;
    if (startIndex >= previousMatches.length) {
      return [];
    }
    
    int endIndex = startIndex + pageSize;
    if (endIndex > previousMatches.length) {
      endIndex = previousMatches.length;
    }
    
    return previousMatches.sublist(startIndex, endIndex);
  }
}
class Match {
  final String teamA;
  final String teamALogo;
  final String teamB;
  final String teamBLogo;
  final String stadium;
  final DateTime utcDate;
  final String competition;
  final int? scoreA;
  final int? scoreB;

  Match({
    required this.teamA,
    required this.teamALogo,
    required this.teamB,
    required this.teamBLogo,
    required this.stadium,
    required this.utcDate,
    required this.competition,
    this.scoreA,
    this.scoreB,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      teamA: json['homeTeam']['name'],
      teamALogo: json['homeTeam']['crest'],
      teamB: json['awayTeam']['name'],
      teamBLogo: json['awayTeam']['crest'],
      stadium: json['venue'] ?? 'غير معروف',
      utcDate: DateTime.parse(json['utcDate']),
      competition: json['competition']['name'],
      scoreA: json['score']['fullTime']['home'],
      scoreB: json['score']['fullTime']['away'],
    );
  }
}




class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          toolbarHeight: 0,
          bottom: const TabBar(
            indicatorWeight: 4,
            indicatorColor: Colors.yellowAccent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upcoming,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "\u0627\u0644\u0645\u0628\u0627\u0631\u064a\u0627\u062a \u0627\u0644\u0642\u0627\u062f\u0645\u0629",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "\u0627\u0644\u0646\u062a\u0627\u0626\u062c \u0627\u0644\u0633\u0627\u0628\u0642\u0629",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UpcomingMatchesTab(),
            PreviousResultsTab(),
          ],
        ),
      ),
    );
  }
}


class UpcomingMatchesTab extends StatefulWidget {
  const UpcomingMatchesTab({super.key});

  @override
  _UpcomingMatchesTabState createState() => _UpcomingMatchesTabState();
}

class _UpcomingMatchesTabState extends State<UpcomingMatchesTab> {
  final FootballApi footballApi = FootballApi();
  final List<Match> displayedMatches = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  static const int itemsPerPage = 10;
  int currentPage = 0;
  bool hasMoreData = true;
  final List<String> teamIds = ['81', '86', '65', '66', '57', '61'];

  @override
  void initState() {
    super.initState();
    fetchUpcomingMatches();
  }

  Future<void> fetchUpcomingMatches() async {
    if (!hasMoreData || isLoadingMore) return;
    
    setState(() {
      isLoadingMore = true;
    });

    try {
      // استخدام الدالة المعدلة للحصول على المباريات القادمة مرتبة من الأقرب إلى الأبعد
      final upcoming = await footballApi.getUpcomingMatches(
        teamIds,
        '2024',
        currentPage,
        itemsPerPage,
      );

      if (mounted) {
        setState(() {
          displayedMatches.addAll(upcoming);
          isLoading = false;
          isLoadingMore = false;
          // تحديث ما إذا كان هناك المزيد من البيانات
          hasMoreData = upcoming.length == itemsPerPage;
          currentPage++;
        });
      }
    } catch (e) {
      print('Error fetching upcoming matches: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accentColor),
            SizedBox(height: 16),
            Text(
              'جاري تحميل المباريات القادمة...',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'يرجى الانتظار قليلاً',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (displayedMatches.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد مباريات قادمة',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 80,
      ),
      itemCount: displayedMatches.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayedMatches.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isLoadingMore
                  ? null
                  : () {
                      fetchUpcomingMatches();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoadingMore
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: accentColor,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'المزيد',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          );
        }

        final match = displayedMatches[index];
        return UpcomingMatchCard(
          teamA: match.teamA,
          teamALogo: match.teamALogo,
          teamB: match.teamB,
          teamBLogo: match.teamBLogo,
          stadium: match.stadium,
          time: match.utcDate.toIso8601String(),
          competition: match.competition,
          date: match.utcDate.toIso8601String(),
        );
      },
    );
  }
}

class PreviousResultsTab extends StatefulWidget {
  const PreviousResultsTab({super.key});

  @override
  _PreviousResultsTabState createState() => _PreviousResultsTabState();
}

class _PreviousResultsTabState extends State<PreviousResultsTab> {
  final FootballApi footballApi = FootballApi();
  final List<Match> displayedResults = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  static const int itemsPerPage = 10;
  int currentPage = 0;
  bool hasMoreData = true;
  final List<String> teamIds = ['81', '86', '65', '66', '57', '61'];

  @override
  void initState() {
    super.initState();
    fetchPreviousResults();
  }

  Future<void> fetchPreviousResults() async {
    if (!hasMoreData || isLoadingMore) return;
    
    setState(() {
      isLoadingMore = true;
    });

    try {
      // استخدام الدالة المعدلة للحصول على المباريات السابقة مرتبة من الأحدث إلى الأقدم
      final previous = await footballApi.getPreviousMatches(
        teamIds,
        '2024',
        currentPage,
        itemsPerPage,
      );

      if (mounted) {
        setState(() {
          displayedResults.addAll(previous);
          isLoading = false;
          isLoadingMore = false;
          // تحديث ما إذا كان هناك المزيد من البيانات
          hasMoreData = previous.length == itemsPerPage;
          currentPage++;
        });
      }
    } catch (e) {
      print('Error fetching previous results: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accentColor),
            SizedBox(height: 16),
            Text(
              'جاري تحميل النتائج السابقة...',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'قد يستغرق هذا بعض الوقت بسبب قيود API',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (displayedResults.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد نتائج سابقة',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 80,
      ),
      itemCount: displayedResults.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayedResults.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isLoadingMore
                  ? null
                  : () {
                      fetchPreviousResults();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoadingMore
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: accentColor,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'المزيد',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          );
        }

        final result = displayedResults[index];
        return PreviousResultsCard(
          teamA: result.teamA,
          teamALogo: result.teamALogo,
          scoreA: result.scoreA?.toString() ?? '-',
          teamB: result.teamB,
          teamBLogo: result.teamBLogo,
          scoreB: result.scoreB?.toString() ?? '-',
          competition: result.competition,
          date: result.utcDate.toIso8601String(),
        );
      },
    );
  }
}
class MatchDataCache {
  static final MatchDataCache _instance = MatchDataCache._internal();
  
  factory MatchDataCache() {
    return _instance;
  }
  
  MatchDataCache._internal();
  
  // كاش للمباريات
  List<Match>? allMatches;
  
  // حالة تحميل البيانات
  bool isLoading = false;
  
  // للتأكد من عدم تكرار الطلب
  bool isInitialized = false;
  
  // وقت آخر تحديث للبيانات (للتحديث الدوري)
  DateTime? lastUpdated;
  
  // دالة للتحقق من الحاجة للتحديث (كل ساعة مثلاً)
  bool needsRefresh() {
    if (lastUpdated == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    
    // تحديث البيانات كل ساعة
    return difference.inHours >= 1;
  }
  
  // تفريغ الكاش عند الحاجة
  void clearCache() {
    allMatches = null;
    isInitialized = false;
    lastUpdated = null;
  }
}


