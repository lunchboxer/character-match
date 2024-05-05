import 'package:flutter/material.dart';
import 'package:character_match/screens/setup_screen.dart';
import 'package:character_match/screens/game_screen.dart';

class ScoreboardScreen extends StatelessWidget {
  final int score;
  final int characterCount;
  final int hskLevel;

  const ScoreboardScreen({
    super.key,
    required this.score,
    required this.characterCount,
    required this.hskLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Score',
              style: TextStyle(fontSize: 32),
            ),
            Text(
              score.toString(),
              style: const TextStyle(fontSize: 86),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SetupScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            hskLevel: hskLevel,
                            characterCount: characterCount,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
