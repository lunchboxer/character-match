import 'package:flutter/material.dart';
import 'package:character_match/screens/game_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _selectedHskLevel = 4;
  int _selectedCharacterCount = 9;

  final List<String> _hskLevelLabels = [
    'HSK 1',
    'HSK 2',
    'HSK 3',
    'HSK 4',
    'HSK 5',
    'HSK 6',
    'Advanced',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Welcome to Character Match!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Read characters from a grid of cards. Find 2 with matching pronunciation (ignoring tones).',
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Level',
              style: TextStyle(fontSize: 24.0),
            ),
            DropdownButton<int>(
              value: _selectedHskLevel,
              onChanged: (value) {
                setState(() {
                  _selectedHskLevel = value!;
                });
              },
              items: List.generate(
                _hskLevelLabels.length,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text(_hskLevelLabels[index]),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Number of Characters',
              style: TextStyle(fontSize: 24.0),
            ),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 6, label: Text('6')),
                ButtonSegment(value: 9, label: Text('9')),
                ButtonSegment(value: 12, label: Text('12')),
              ],
              selected: <int>{_selectedCharacterCount},
              onSelectionChanged: (values) {
                setState(() {
                  _selectedCharacterCount = values.single;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      hskLevel: _selectedHskLevel,
                      characterCount: _selectedCharacterCount,
                    ),
                  ),
                );
              },
              child: const Text('Start the game'),
            ),
          ],
        ),
      ),
    );
  }
}
