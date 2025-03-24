import 'package:flutter/material.dart';
import 'package:football_project/game/games_instrutions/who_is_team_instruction.dart';
import 'package:football_project/game/leaderboard_screen.dart';

import 'package:football_project/game/quizGame.dart';
import 'package:football_project/game/who_is_player.dart';
import 'package:football_project/game/who_is_team.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<GameButton> buttons = [
      GameButton(
        imageAsset: 'assets/games/who_is_player.jpg',
        buttonText: 'Who is the player?',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WhoIsPlayer()),
          );
        },
      ),
      GameButton(
        imageAsset: 'assets/games/queiz.jpg',
        buttonText: 'The Quiz Game',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizGameScreen()),
          );
        },
      ),
      GameButton(
        imageAsset: 'assets/games/who_is_team.jpg',
        buttonText: 'Who is the Team?',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
        },
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.45,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: buttons.length,
          itemBuilder: (context, index) {
            return ButtonWidget(
              imageAsset: buttons[index].imageAsset,
              buttonText: buttons[index].buttonText,
              onTap: buttons[index].onTap,
            );
          },
        ),
      ),
    );
  }
}

class GameButton {
  final String imageAsset;
  final String buttonText;
  final VoidCallback onTap;

  GameButton({
    required this.imageAsset,
    required this.buttonText,
    required this.onTap,
  });
}

class ButtonWidget extends StatelessWidget {
  final String imageAsset;
  final String buttonText;
  final void Function() onTap;

  const ButtonWidget({
    super.key,
    required this.imageAsset,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.transparent],
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2A3A),
              Color(0xFF4CAF50)
            ], // استخدام اللون الأساسي
          ),
        ),
        child: Stack(
          children: [
            // خلفية الصورة مع التأثير المعتم
            Opacity(
              opacity: 0.4, // تعتيم الصورة
              child: Image.asset(
                'assets/games/who_is_team.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // اللون الأخضر فوق الصورة
            Container(
              color: Color.fromARGB(255, 24, 3, 72)
                  .withOpacity(0.5), // اللون الأخضر مع بعض الشفافية
            ),
            // المحتوى العادي
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'من هذا الفريق ؟',
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
                          builder: (context) => const GameScreen(),
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
                          builder: (context) => InstructionsScreen(),
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
                ],
              ),
            ),
          ],
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