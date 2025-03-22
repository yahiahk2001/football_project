import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';

import 'GamesData/quiz_data.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  _QuizGameScreenState createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  late List<Question> currentQuestions;
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswerSelected = false;
  bool hasGameStarted = false;
  Difficulty? selectedDifficulty;

  @override
  void initState() {
    super.initState();
    currentQuestions = [];
  }

  void startGame(Difficulty difficulty) {
    // تحديد الأسئلة حسب المستوى المختار
    final questionsForDifficulty =
        allQuestions.where((q) => q.difficulty == difficulty).toList();

    // خلط الأسئلة عشوائياً
    questionsForDifficulty.shuffle();

    // اختيار 10 أسئلة
    currentQuestions = questionsForDifficulty.take(10).toList();

    setState(() {
      selectedDifficulty = difficulty;
      hasGameStarted = true;
      currentQuestionIndex = 0;
      score = 0;
      isAnswerSelected = false;
    });
  }

  void checkAnswer(int selectedIndex) {
    if (isAnswerSelected) return;

    setState(() {
      isAnswerSelected = true;
      if (selectedIndex ==
          currentQuestions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (currentQuestionIndex < currentQuestions.length - 1) {
          currentQuestionIndex++;
          isAnswerSelected = false;
        } else {
          showFinalResultDialog();
        }
      });
    });
  }

  Color _getScoreColor() {
    final percentage = (score / currentQuestions.length) * 100;
    if (percentage <= 30) return Colors.red.shade400;
    if (percentage <= 60) return Colors.orange.shade400;
    if (percentage <= 80) return Colors.blue.shade400;
    return Colors.green.shade400;
  }

  String _getResultMessage() {
    final percentage = (score / currentQuestions.length) * 100;
    if (percentage <= 30) return 'حاول مرة أخرى! يمكنك التحسن';
    if (percentage <= 60) return 'جيد! واصل التعلم';
    if (percentage <= 80) return 'رائع! أنت متمكن';
    return 'مذهل! أنت خبير كرة قدم حقيقي';
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'سهل';
      case Difficulty.medium:
        return 'متوسط';
      case Difficulty.hard:
        return 'صعب';
      case Difficulty.impossible:
        return 'مستحيل';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.blue;
      case Difficulty.hard:
        return Colors.orange;
      case Difficulty.impossible:
        return Colors.red;
    }
  }

  void showFinalResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'النتيجة النهائية',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: _getScoreColor(),
                  child: Text(
                    '$score/${currentQuestions.length}',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _getResultMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'المستوى: ${_getDifficultyText(selectedDifficulty!)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getDifficultyColor(selectedDifficulty!),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            hasGameStarted = false;
                            selectedDifficulty = null;
                          });
                        },
                        child: const Text(
                          'تغيير المستوى',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          startGame(selectedDifficulty!);
                        },
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'تحدي الكرة ',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: accentColor,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(color: primaryColor),
        child:
            hasGameStarted ? _buildGameContent() : _buildDifficultySelection(),
      ),
    );
  }

  Widget _buildDifficultySelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'اختر مستوى الصعوبة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 30),
          ...Difficulty.values.map((difficulty) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getDifficultyColor(difficulty),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  onPressed: () => startGame(difficulty),
                  child: Text(
                    _getDifficultyText(difficulty),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السؤال: ${currentQuestionIndex + 1}/${currentQuestions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    'المستوى: ${_getDifficultyText(selectedDifficulty!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(selectedDifficulty!),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'النقاط: $score',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 1,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              currentQuestions[currentQuestionIndex].text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ...currentQuestions[currentQuestionIndex]
              .options
              .asMap()
              .entries
              .map((entry) {
            int optionIndex = entry.key;
            String optionText = entry.value;
            bool isCorrect = optionIndex ==
                currentQuestions[currentQuestionIndex].correctAnswerIndex;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => checkAnswer(optionIndex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAnswerSelected
                      ? (isCorrect
                          ? Colors.green.shade100
                          : Colors.red.shade100)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(15),
                ),
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 18,
                    color: isAnswerSelected
                        ? (isCorrect
                            ? Colors.green.shade800
                            : Colors.red.shade800)
                        : primaryColor,
                  ),
                ),
              ),
            );
          }),
          if (isAnswerSelected)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                currentQuestions[currentQuestionIndex].explanation,
                style: const TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
