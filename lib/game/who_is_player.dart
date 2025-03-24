// player_model.dart
import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:football_project/game/GamesData/who_is_player_data.dart';
import 'package:football_project/game/games_page.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

