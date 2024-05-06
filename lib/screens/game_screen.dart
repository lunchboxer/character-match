import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:character_match/screens/setup_screen.dart';
import 'package:character_match/screens/scoreboard_screen.dart';

class GameScreen extends StatefulWidget {
  final int hskLevel;
  final int characterCount;

  const GameScreen({
    super.key,
    required this.hskLevel,
    required this.characterCount,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> _characters = [];
  List<String> _matches = [];
  List<int> _selectedCards = [];
  final Map<String, String> _pronunciations = {};
  bool _isCorrect = false;
  bool _roundComplete = false;
  int _roundCount = 1;
  int _score = 0;
  final int _maxRounds = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jsonData = await rootBundle
        .loadString('assets/characters-grouped-by-pinyin-and-level.json');
    final data = json.decode(jsonData);

    final allPinyinKeys = data.keys.toList();
    allPinyinKeys.shuffle();

    final selectedPinyinKeys = <String>[];
    final characterList = <String>[];
    final matchingCharacters = <String>[];

    for (int i = 0;
        selectedPinyinKeys.length < (widget.characterCount - 1);
        i++) {
      final pinyinKey = allPinyinKeys[i];
      final pinyinData = data[pinyinKey];
      final validCharacters = <String>[];

      for (final level in pinyinData.keys) {
        if (int.parse(level) <= widget.hskLevel) {
          final characters = pinyinData[level] as List<dynamic>;
          validCharacters.addAll(characters.cast<String>());
        }
      }

      // some characters from the right levels were found
      if (validCharacters.isNotEmpty) {
        // CHECK . if we haven't added the pinyinKey to selectedPinyinKeys then we may be off by one
        int maxSingleCharacter = widget.characterCount - 2;
        // it's now time to pick 2 characters
        if (selectedPinyinKeys.length == maxSingleCharacter) {
          if (validCharacters.length < 2) {
            continue;
          }
          validCharacters.shuffle();
          matchingCharacters
              // am I shuffling at the wrong place? Don't I need to shuffle first, then pick two?
              .addAll(validCharacters.getRange(0, 2).toList());
          characterList.addAll(matchingCharacters);
          selectedPinyinKeys.add(pinyinKey);
          _pronunciations[matchingCharacters[0]] = pinyinKey;
          _pronunciations[matchingCharacters[1]] = pinyinKey;
        } else {
          // add one character from those found to our list
          final newCharacter =
              validCharacters[Random().nextInt(validCharacters.length)];
          characterList.add(newCharacter);
          selectedPinyinKeys.add(pinyinKey);
          _pronunciations[newCharacter] = pinyinKey;
        }
      }
    }
    setState(() {
      _characters = characterList..shuffle();
      _matches = matchingCharacters;
    });
  }

  void _handleCardTap(int index) {
    if (_roundComplete) {
      return;
    }
    if (_selectedCards.length < 2) {
      setState(() {
        _selectedCards.add(index);
      });

      if (_selectedCards.length == 2) {
        final firstIndex = _selectedCards[0];
        final secondIndex = _selectedCards[1];

        // reset selection if play taps selected card
        if (firstIndex == secondIndex) {
          _selectedCards = [];
          return;
        }

        if (_matches.contains(_characters[secondIndex]) &&
            _matches.contains(_characters[firstIndex])) {
          _isCorrect = true;
          setState(() {
            _score++;
          });
          // Disable further selection after a correct match
        } else {
          _isCorrect = false;
          // Disable further selection after an incorrect match
        }
        _roundComplete = true;
      }
    }
  }

  void _nextRound() {
    if (_roundCount == _maxRounds) {
      // Game over
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreboardScreen(
            characterCount: widget.characterCount,
            hskLevel: widget.hskLevel,
            score: _score, // Replace with your scoring logic
          ),
        ),
      );
    } else {
      _loadData();
      setState(() {
        _selectedCards.clear();
        _isCorrect = false;
        _roundComplete = false;
        _roundCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Round: $_roundCount / $_maxRounds',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                ),
                itemCount: _characters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCards.contains(index);
                  Color bgcolor = isSelected
                      ? _roundComplete
                          ? _isCorrect
                              ? Colors.green
                              : Colors.red
                          : Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surfaceVariant;

                  return InkWell(
                    onTap: () => _handleCardTap(index),
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: bgcolor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _characters[index],
                            style: const TextStyle(
                              fontSize: 32.0,
                            ),
                          ),
                          if (_roundComplete)
                            Text(
                              _pronunciations[_characters[index]] ?? '',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            if (_roundComplete)
              Center(
                child: Text(
                  _isCorrect ? 'Correct' : 'Wrong',
                  style: const TextStyle(fontSize: 32.0),
                ),
              ),
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
                    icon: const Icon(Icons.close),
                    label: const Text('End game'),
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
                    onPressed: _nextRound,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                        _roundCount == _maxRounds ? 'Finish' : 'Next Round'),
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
