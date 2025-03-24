// New Leaderboard Screen
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final supabase = Supabase.instance.client;
  List<LeaderboardEntry> leaderboardEntries = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  Future<void> fetchLeaderboardData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Fetch top 10 scores from leaderboard, joining with users table to get usernames and profile pictures
      final response = await supabase
          .from('leaderboard')
          .select('score, created_at, users(username, profile_picture)')
          .order('score', ascending: false)
          .limit(10);

      // ignore: unnecessary_null_comparison
      if (response != null) {
        final List<LeaderboardEntry> entries = [];
        
        for (final item in response) {
          final username = item['users'] != null && item['users']['username'] != null
              ? item['users']['username']
              : 'Anonymous';
          final profilePicture = item['users'] != null ? item['users']['profile_picture'] : null;
              
          entries.add(LeaderboardEntry(
            username: username,
            score: item['score'],
            createdAt: DateTime.parse(item['created_at']),
            profilePicture: profilePicture,
          ));
        }

        setState(() {
          leaderboardEntries = entries;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
      print('Error fetching leaderboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'أفضل 10 نتائج',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: fetchLeaderboardData,
                    ),
                  ],
                ),
              ),

              // Leaderboard Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : hasError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'حدث خطأ في تحميل البيانات: $errorMessage',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: fetchLeaderboardData,
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            )
                          : leaderboardEntries.isEmpty
                              ? const Center(
                                  child: Text(
                                    'لا توجد نتائج حتى الآن',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: leaderboardEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = leaderboardEntries[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? Colors.amber.withOpacity(0.2)
                                            : index == 1
                                                ? Colors.grey.shade300
                                                : index == 2
                                                    ? Colors.brown.shade200
                                                    : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: index == 0
                                              ? Colors.amber
                                              : index == 1
                                                  ? Colors.grey
                                                  : index == 2
                                                      ? Colors.brown
                                                      : Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: index < 3
                                                  ? [
                                                      Colors.amber,
                                                      Colors.grey.shade400,
                                                      Colors.brown.shade300
                                                    ][index]
                                                  : Colors.blue.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          
                                          // Profile Image
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade200,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: entry.profilePicture != null
                                                  ? Image.network(
                                                      supabase.storage.from('images').getPublicUrl(entry.profilePicture!),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                                        Icons.person,
                                                        size: 24,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.person,
                                                      size: 24,
                                                      color: Colors.grey,
                                                    ),
                                            ),
                                          ),
                                          
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              entry.username,
                                              style: const TextStyle(
                                                color: Colors.lightBlue,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${entry.score}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Text(
                                                'نقطة',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaderboardEntry {
  final String username;
  final int score;
  final DateTime createdAt;
  final String? profilePicture; // Add this field

  LeaderboardEntry({
    required this.username,
    required this.score,
    required this.createdAt,
    this.profilePicture, // Make it optional
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'] ?? 'Anonymous',
      score: json['score'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      profilePicture: json['profilePicture'],
    );
  }
}