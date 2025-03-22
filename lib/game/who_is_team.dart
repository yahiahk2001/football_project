import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:football_project/game/GamesData/who_is_team_data.dart';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final TextEditingController _answerController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  final FocusNode _focusNode = FocusNode();
  
  // Game state variables
  late List<Team> selectedTeams;
  int currentRound = 0;
  int wrongGuesses = 0;
  int totalScore = 0;
  int currentRoundScore = 0;
  late Timer _timer;
  int remainingSeconds = 120; // Reduced time to make it more challenging
  bool showHint = false;
  String? currentHint;
  
  // New variables for game statistics
  int totalCorrectGuesses = 0;
  int totalWrongGuesses = 0;
  bool isPaused = false;
  
 
  @override
  void initState() {
    super.initState();
    initializeGame();
    startTimer();
    _initAudio();
    
    // Initialize shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Create a shaking animation
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: ShakeCurve()))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });
  }

int calculateLevenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<List<int>> matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((curr, next) => curr < next ? curr : next);
      }
    }

    return matrix[a.length][b.length];
  }


  Future<void> _initAudio() async {
    try {
      await audioPlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void initializeGame() {
    selectedTeams = List.from(Game3Data.teams)..shuffle();
    selectedTeams = selectedTeams.take(3).toList(); // Limit to 3 rounds
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            endRound();
          }
        });
      }
    });
  }

 

  bool isRoundComplete() {
    return selectedTeams[currentRound].players.every((player) => player.isGuessed);
  }

 void checkAnswer() {
    final answer = _answerController.text.trim().toLowerCase();
    if (answer.isEmpty) return;

    setState(() {
      bool correctGuess = false;
      for (var player in selectedTeams[currentRound].players) {
        if (!player.isGuessed) {
          bool isCloseMatch = false;
          
          for (var acceptableAnswer in player.acceptableAnswers) {
            final distance = calculateLevenshteinDistance(
              answer,
              acceptableAnswer.toLowerCase()
            );
            
            final maxLength = acceptableAnswer.length > answer.length 
                ? acceptableAnswer.length 
                : answer.length;
            final similarityPercentage = (1 - (distance / maxLength)) * 100;

            if (similarityPercentage >= 60) {
              isCloseMatch = true;
              break;
            }
          }

          if (isCloseMatch || 
              player.acceptableAnswers
                  .map((a) => a.toLowerCase())
                  .contains(answer)) {
            player.isGuessed = true;
            currentRoundScore += 10;
            totalScore += 10;
            totalCorrectGuesses++;
            correctGuess = true;
            _playSound('sounds/correct.mp3');
            
            if (isRoundComplete()) {
              int timeBonus = (remainingSeconds ~/ 10);
              totalScore += timeBonus;
              currentRoundScore += timeBonus;
              endRound();
            }
            break;
          }
        }
      }
      if (!correctGuess) {
        wrongGuesses++;
        totalWrongGuesses++;
        _playSound('sounds/wrong-answer.mp3');
        _shakeController.forward(from: 0.0);
        HapticFeedback.mediumImpact(); // Add haptic feedback
        if (wrongGuesses >= 4) {
          endRound();
        }
      }
    });

    _answerController.clear();
    _focusNode.requestFocus();
  }


  void provideHint() {
    if (showHint) return;
    
    setState(() {
      showHint = true;
      final unguessedPlayer = selectedTeams[currentRound].players
          .firstWhere((player) => !player.isGuessed);
      currentHint = "تلميح: ${unguessedPlayer.name[0]}...";
      totalScore -= 5; // Deduct points from total score for using hint
      currentRoundScore -= 5;
    });
  }

   void endRound() {
    _timer.cancel();
    
    // Get unguessed players for the current round
    final unguessedPlayers = selectedTeams[currentRound].players
        .where((player) => !player.isGuessed)
        .toList();

    if (currentRound < 2) { // Changed to < 2 since we're using 3 rounds (0-2)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false, // Prevent dialog dismissal with back button
          child: AlertDialog(
            title: Text('انتهت الجولة ${currentRound + 1}!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('نقاط الجولة: $currentRoundScore'),
                const SizedBox(height: 10),
                Text('مجموع النقاط: $totalScore'),
                const SizedBox(height: 10),
                Text('إجابات صحيحة: $totalCorrectGuesses'),
                Text('أخطاء: $totalWrongGuesses'),
                if (unguessedPlayers.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('اللاعبون الذين لم يتم تخمينهم:'),
                  ...unguessedPlayers.map((player) => Text(
                    player.name,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                    ),
                  )),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  startNextRound();
                },
                child: const Text('الجولة التالية'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Get unguessed players for the final round
      showGameOverDialog(unguessedPlayers);
    }
  }

  void startNextRound() {
    setState(() {
      currentRound++;
      wrongGuesses = 0;
      currentRoundScore = 0;
      remainingSeconds = 120;
      showHint = false;
      currentHint = null;
      startTimer();
    });
  }

 void showGameOverDialog(List<Player> finalUnguessedPlayers) {
    int accuracyBonus = (totalCorrectGuesses / (totalCorrectGuesses + totalWrongGuesses) * 50).round();
    totalScore += accuracyBonus;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent dialog dismissal with back button
        child: AlertDialog(
          title: const Text('انتهت اللعبة!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('مجموع النقاط النهائي: $totalScore'),
              const SizedBox(height: 10),
              Text('مكافأة الدقة: $accuracyBonus'),
              const SizedBox(height: 10),
              Text('إجمالي الإجابات الصحيحة: $totalCorrectGuesses'),
              Text('إجمالي الأخطاء: $totalWrongGuesses'),
              if (finalUnguessedPlayers.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('اللاعبون الذين لم يتم تخمينهم في الجولة الأخيرة:'),
                ...finalUnguessedPlayers.map((player) => Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                )),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainMenu()),
                    (route) => false,
                  );
                },
                child: const Text('العودة للصفحة الرئيسية'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: const Text('العب مرة أخرى'),
              ),
            ],
          ),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final currentTeam = selectedTeams[currentRound];
  final timerProgress = remainingSeconds / 120;

  return WillPopScope(
    onWillPop: () async => false,
    child: Scaffold(
      appBar: AppBar(
  title: Text('${currentRound + 1}/3'),
  automaticallyImplyLeading: false,
  actions: [
    Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('من في الصورة', style: TextStyle(fontSize: 18)),
    ),
    IconButton(
      icon: const Icon(Icons.exit_to_app),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("تأكيد الخروج"),
            content: const Text("هل أنت متأكد أنك تريد الخروج من اللعبة؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("خروج"),
              ),
            ],
          ),
        );
      },
    ),
  ],
),

      body: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: SafeArea(
              child: Column(
                children: [
                  // Timer Progress Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: timerProgress,
                            minHeight: 10,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              timerProgress > 0.3 
                                  ? Colors.blue 
                                  : (timerProgress > 0.15 
                                      ? Colors.orange 
                                      : Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: timerProgress > 0.3 
                                ? Colors.blue 
                                : (timerProgress > 0.15 
                                    ? Colors.orange 
                                    : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('نقاط الجولة: $currentRoundScore', 
                                style: const TextStyle(fontSize: 16)),
                            Text('المجموع: $totalScore',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('أخطاء: $wrongGuesses/4', 
                                style: const TextStyle(fontSize: 16)),
                            IconButton(
                              onPressed: provideHint,
                              icon: const Icon(Icons.lightbulb_outline),
                              tooltip: 'احصل على تلميح (-5 نقاط)',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (showHint && currentHint != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        currentHint!,
                        style: const TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    ),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          currentTeam.teamImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: currentTeam.players.length,
                      itemBuilder: (context, index) {
                        final player = currentTeam.players[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: player.isGuessed ? Colors.green : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                player.isGuessed ? player.name : '?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: player.isGuessed ? Colors.white : Colors.black54,
                                  fontSize: 12,
                                  fontWeight: player.isGuessed ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: 'اكتب اسم اللاعب...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white24,
                            ),
                            onSubmitted: (_) {
                              if (!isPaused) {
                                checkAnswer();
                              }
                              _focusNode.requestFocus();
                            },
                            enabled: !isPaused,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isPaused ? null : () {
                            checkAnswer();
                            _focusNode.requestFocus();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('تحقق'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
  @override
  void dispose() {
    _timer.cancel();
    _answerController.dispose();
    _focusNode.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('من في الصورة')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
              child: const Text('ابدأ اللعب'),
            ),
          ],
        ),
      ),
    );
  }
}

 class ShakeCurve extends Curve {
    @override
    double transform(double t) {
      return sin(t * 3 * pi) * 0.5;
    }
  }