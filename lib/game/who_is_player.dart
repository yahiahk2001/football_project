// player_model.dart
import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:football_project/game/GamesData/who_is_player_data.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Leaderboard model to represent each entry
// First, update the LeaderboardEntry class to include profilePicture
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
}// game_screen.dart
class WhoIsPlayerGame extends StatefulWidget {
  const WhoIsPlayerGame({super.key});

  @override
  State<WhoIsPlayerGame> createState() => _WhoIsPlayerGameState();
}

class _WhoIsPlayerGameState extends State<WhoIsPlayerGame> {
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final int totalChallenges = 5;
  late List<Player> selectedPlayers;
  int currentChallengeIndex = 0;
  int currentHintIndex = 0;
  int score = 0;
  List<String> shownHints = [];
  bool isGameOver = false;
  bool showError = false;
  bool showSuccess = false;
  bool isSubmittingScore = false;

  Timer? _timer;
  int _remainingSeconds = 30;
  // ignore: unused_field
  bool _isTimerActive = false;

  // Supabase client
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<Player> availablePlayers = List.from(Game2Data.players);
    print('------------------------------');
    print(Game2Data.players.length);
    selectedPlayers = [];
    final random = Random();

    for (int i = 0; i < totalChallenges && availablePlayers.isNotEmpty; i++) {
      int randomIndex = random.nextInt(availablePlayers.length);
      selectedPlayers.add(availablePlayers[randomIndex]);
      availablePlayers.removeAt(randomIndex);
    }

    showNextHint();
  }

  // Submit score to leaderboard
  Future<void> submitScore(String username, int finalScore) async {
    try {
      setState(() {
        isSubmittingScore = true;
      });
      
      // Get current user ID
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        // Insert score to leaderboard table
        await supabase.from('leaderboard').insert({
          'user_id': userId,
          'score': finalScore,
        });
      }
      
      setState(() {
        isSubmittingScore = false;
      });
    } catch (e) {
      setState(() {
        isSubmittingScore = false;
      });
      print('Error submitting score: $e');
    }
  }

  void _showGameOverDialog(bool completed) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // منح الزوايا شكل دائري
      ),
      backgroundColor: Color(0xFF2C3E50), // لون الخلفية الداكنة
      title: Column(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            color: completed ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            completed ? 'أحسنت! 🎉' : 'انتهت اللعبة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // اللون الأبيض للنص
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            completed
                ? 'لقد أكملت جميع التحديات بنجاح!'
                : 'اللاعب الصحيح هو: ${currentPlayer.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70, // نص بلون فاتح مع تأثير التظليل
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'مجموع النقاط: $score',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent, // اللون الأزرق الجميل
            ),
          ),
          const SizedBox(height: 20),
          if (score > 0 && supabase.auth.currentUser != null)
            isSubmittingScore
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber), // تغيير لون التدوير
                  )
                : ElevatedButton(
                    onPressed: () async {
                      await submitScore('Player', score);
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const WhoIsPlayer()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // زر باللون الذهبي الفاخر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // جعل الزر دائري الزوايا
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12,
                      ),
                      elevation: 5, // إضافة ظل للزر
                    ),
                    child: const Text(
                      'حفظ النتيجة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          if (supabase.auth.currentUser == null && score > 0)
            Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل اسمك',
                    hintStyle: TextStyle(color: Colors.white60), // لون النص في الحقل
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white), // اللون الأبيض للنص
                ),
                const SizedBox(height: 10),
                isSubmittingScore
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (_usernameController.text.isNotEmpty) {
                            await submitScore(
                                _usernameController.text, score);
                          }
                          Navigator.of(context).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const WhoIsPlayer()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12,
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'حفظ النتيجة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WhoIsPlayer()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // لون الزر أزرق مميز
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              elevation: 5,
            ),
            child: const Text(
              'العودة للصفحة الرئيسية',
              style: TextStyle(
                color: Colors.white, // لون النص
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  void startTimer() {
    _remainingSeconds = 30;///////////////////////////////////////////////////////////////////////////////////////////////////
    _isTimerActive = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _isTimerActive = false;
        _showTimeUpDialog();
      }
    });
  }

void _showTimeUpDialog() {
  showDialog(
    context: context,
    barrierDismissible: false, // يمنع الإغلاق عند النقر خارج الحوار
    builder: (context) => WillPopScope( // يمنع زر الرجوع من إغلاق الحوار
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Color(0xFF1A2A3A),
        title: Column(
          children: [
            Icon(Icons.timer_off, color: Colors.amber, size: 40),
            const SizedBox(height: 10),
            const Text(
              'انتهى الوقت!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'لم تتمكن من الإجابة في الوقت المحدد',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showNextHint();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                elevation: 5,
              ),
              child: const Text('التلميح التالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

  Player get currentPlayer => selectedPlayers[currentChallengeIndex];

  void showNextHint() {
    if (currentHintIndex < currentPlayer.hints.length) {
      setState(() {
        shownHints.add(currentPlayer.hints[currentHintIndex]);
        currentHintIndex++;
        showError = false;
        // بدء العداد مع كل تلميح جديد
        startTimer();
      });
    } else {
      _timer?.cancel();
      _showGameOverDialog(false);
    }
  }

  void checkAnswer() {
    final answer = _answerController.text.trim().toLowerCase();
    if (answer.isEmpty) return;

    bool isCorrect = currentPlayer.acceptableAnswers.any((correctAnswer) {
      double similarity = correctAnswer.toLowerCase().similarityTo(answer);
      return similarity >= 0.6; // تقبل الإجابة إذا كانت نسبة التشابه 60% أو أكثر
    });

    setState(() {
      if (isCorrect) {
        _timer?.cancel();
        score += (5 - currentHintIndex + 1) * 10;
        showSuccess = true;
        showError = false;

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
           if (currentChallengeIndex < totalChallenges - 1) {
    setState(() {
        currentChallengeIndex++;
        currentHintIndex = 0;
        shownHints = []; // إعادة تعيين القائمة بالكامل
        showSuccess = false;
        _answerController.clear();
    });

    // تأخير بسيط للسماح بإعادة بناء الواجهة
    Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
            setState(() {
                showNextHint(); // عرض التلميح الأول للاعب الجديد
            });
        }
    });
}
 else {
              _timer?.cancel();
              _showGameOverDialog(true);
            }
          }
        });
      } else {
        showError = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              showError = false;
            });
          }
        });
      }
    });
  }
// دالة عرض مربع حوار التأكيد
Future<bool> _showExitConfirmationDialog() async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Color(0xFF1A2A3A),
      title: const Text(
        'هل تريد الخروج؟',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      content: const Text(
        'سيتم فقدان تقدمك إذا خرجت من اللعبة.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('إلغاء', style: TextStyle(fontSize: 18, color: Colors.blueAccent)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('خروج', style: TextStyle(fontSize: 18, color: Colors.redAccent)),
        ),
      ],
    ),
  ) ?? false; // يعيد `false` افتراضيًا إذا تم إغلاق مربع الحوار بطريقة غير متوقعة
}
  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Same build method as before - not changed
    return WillPopScope(
      onWillPop: () async {
      bool exitConfirmed = await _showExitConfirmationDialog();
      return exitConfirmed;
    },
      child: Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A3A), Color(0xFF2A3A4A), Color(0xFF3A4A5A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'نقاطي: $score',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: _remainingSeconds + 1, end: _remainingSeconds),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: value <= 10 
                              ? Colors.red.withOpacity(0.8) 
                              : Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: value <= 10 
                                  ? Colors.red.withOpacity(0.3) 
                                  : Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: value <= 10 ? 20 : 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$value',
                              style: TextStyle(
                                fontSize: value <= 10 ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_soccer, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'الجولة ${currentChallengeIndex + 1}/$totalChallenges',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      
            // Message cloud background
            Expanded(
              child: Stack(
                children: [
                  // Background design elements
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BackgroundPatternPainter(),
                    ),
                  ),
                  
                  // Hints list
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: ListView.builder(
                        key: ValueKey(currentChallengeIndex), // يضمن إعادة بناء القائمة عند تغيير اللاعب

                      itemCount: shownHints.length,
                      itemBuilder: (context, index) {
                        // Return empty container if we're still animating in this hint
                        return AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation: false,
                                      totalRepeatCount: 1,
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          shownHints[index],
                                          textAlign: TextAlign.right,
                                          textStyle: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            height: 1.5,
                                          ),
                                          speed: const Duration(milliseconds: 50),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.lightbulb,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  
                                  SizedBox(height: 66,)],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      
            // Answer Input and Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (showError || showSuccess)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: showSuccess
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: showSuccess ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            showSuccess ? Icons.check_circle : Icons.error,
                            color: showSuccess ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            showSuccess ? 'إجابة صحيحة! 🎉' : 'إجابة خاطئة، حاول مرة أخرى!',
                            style: TextStyle(
                              color: showSuccess ? Colors.green : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _answerController,
                            decoration: InputDecoration(
                              hintText: 'اللاعب هو...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[100],
                              prefixIcon: const Icon(Icons.person, color: Color(0xFF1A2A3A)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                              ),
                            ),
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.black87),
                            onSubmitted: (_) => checkAnswer(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4CAF50).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: checkAnswer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'تأكيد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: currentHintIndex >= 5
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.amber,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  'انتهت التلميحات! حاول التخمين',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TextButton.icon(
                            onPressed: currentHintIndex < 5 ? showNextHint : null,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: const Icon(Icons.lightbulb_outline, color: Colors.blue),
                            label: Text(
                              'عرض التلميح التالي (${currentHintIndex}/5)',
                              style: const TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
}
}

// New Leaderboard Screen
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

class WhoIsPlayer extends StatelessWidget {
  const WhoIsPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A2A3A), Color(0xFF4CAF50)], // استخدام اللون الأساسي
      ),
    ),
    child: Stack(
      children: [
        // خلفية الصورة مع التأثير المعتم
        Opacity(
          opacity: 0.4, // تعتيم الصورة
          child: Image.asset(
            'assets/games/who_is_player.jpg', // استبدل بمسار الصورة الخاصة بك
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // اللون الأخضر فوق الصورة
        Container(
          color: Color(0xFF4CAF50).withOpacity(0.5), // اللون الأخضر مع بعض الشفافية
        ),
        // المحتوى العادي
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                'من هو اللاعب؟',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700), // اللون الذهبي اللامع
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 220),
              // زر "ابدأ اللعب"
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WhoIsPlayerGame(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5F5F5), // اللون النصي كخلفية
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5, // تأثير الظل
                ),
                child: const Text(
                  'ابدأ اللعب',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF1A2A3A), // اللون الأساسي
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // زر "شرح اللعبة"
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InstructionsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5F5F5), // اللون النصي كخلفية
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5, // تأثير الظل
                ),
                child: const Text(
                  'شرح اللعبة',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF1A2A3A), // اللون الأساسي
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // زر "قائمة المتصدرين"
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5F5F5), // اللون النصي كخلفية
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5, // تأثير الظل
                ),
                child: const Text(
                  'قائمة المتصدرين',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF1A2A3A), // اللون الأساسي
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
}
}

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

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
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'تعليمات اللعبة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Instructions Content
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSection(
                          title: 'كيف تلعب؟',
                          content:
                              'في كل جولة، ستواجه 5 تحديات عشوائية. في كل تحدٍ، عليك تخمين اسم لاعب كرة القدم من خلال التلميحات المقدمة.',
                        ),

                        _buildSection(
                          title: 'نظام النقاط',
                          content:
                              '''كلما قل عدد التلميحات التي تحتاجها، زادت النقاط التي تحصل عليها:
• تخمين صحيح من أول تلميح: 50 نقطة
• تخمين صحيح من ثاني تلميح: 40 نقطة
• تخمين صحيح من ثالث تلميح: 30 نقطة
• تخمين صحيح من رابع تلميح: 20 نقطة
• تخمين صحيح من آخر تلميح: 10 نقاط''',
                        ),

                        _buildSection(
                          title: 'التلميحات',
                          content:
                              'لديك 5 تلميحات لكل لاعب. يمكنك طلب تلميح جديد في أي وقت، لكن تذكر أن النقاط تقل مع كل تلميح إضافي.',
                        ),

                        _buildSection(
                          title: 'الإجابات المقبولة',
                          content:
                              'يمكنك كتابة اسم اللاعب بعدة صيغ مقبولة. على سبيل المثال: "ميسي"، "ليو ميسي"، "ليونيل ميسي".',
                        ),

                        _buildSection(
                          title: 'نهاية اللعبة',
                          content:
                              'تنتهي اللعبة في إحدى الحالتين:\n• إكمال جميع التحديات الخمسة بنجاح\n• استنفاد جميع التلميحات في تحدٍ واحد دون تخمين صحيح',
                        ),

                        // Start Game Button
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // رسم بعض الدوائر المزخرفة في الخلفية
    for (int i = 0; i < 10; i++) {
      double x = size.width * (i / 10);
      double y = size.height * 0.2 * (i % 3);
      double radius = 20 + (i * 4);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // رسم خطوط مزخرفة
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      double startY = size.height * (i / 5);
      canvas.drawLine(
        Offset(0, startY),
        Offset(size.width, startY + 100),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}