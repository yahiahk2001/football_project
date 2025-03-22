import 'package:flutter/material.dart';

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
