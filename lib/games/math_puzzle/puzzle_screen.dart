import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'puzzle_logic.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final MathPuzzleLogic _logic = MathPuzzleLogic();
  late Question _currentQuestion;
  int _score = 0;
  int _level = 1;
  int _timeLeft = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestion = _logic.generateQuestion(_level);
      _timeLeft = 10;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _showGameOver();
        }
      });
    });
  }

  void _checkAnswer(int option) {
    if (option == _currentQuestion.answer) {
      _timer?.cancel();
      setState(() {
        _score += 10 + _timeLeft;
        _level++;

        // Show interstitial ad every 5 level milestones
        if (_level > 1 && (_level - 1) % 5 == 0) {
          AdService().showInterstitialAd();
        }
      });
      StorageService().saveHighScore('math_puzzle', _score);
      _nextQuestion();
    } else {
      StorageService().markDailyCompleted('math_puzzle');
      _timer?.cancel();
      _showGameOver();
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Game Over',
        message: 'Final Score: $_score\nLevel Reached: $_level',
        buttonText: 'RESTART GAME',
        color: NumbersColors.countdown,
        icon: Icons.error_outline,
        onRevive: () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            _nextQuestion(); // Continue from where they left off
          });
        },
        onButtonPressed: () {
          Navigator.pop(context);
          setState(() {
            _score = 0;
            _level = 1;
          });
          _nextQuestion();
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Puzzle'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _timeLeft / 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _timeLeft < 4 ? Colors.red : NumbersColors.mathPuzzle),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LEVEL $_level', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text('SCORE $_score', style: const TextStyle(fontWeight: FontWeight.bold, color: NumbersColors.mathPuzzle)),
              ],
            ),
            const Spacer(),
            Text(
              _currentQuestion.text,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ).animate(key: ValueKey(_currentQuestion.text)).fadeIn().scale(),
            const Spacer(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2,
              children: _currentQuestion.options.map((opt) {
                return ElevatedButton(
                  onPressed: () => _checkAnswer(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: NumbersColors.textBody,
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('$opt', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
