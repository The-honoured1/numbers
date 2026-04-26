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
        color: NumbersColors.green,
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
        title: Text('MATH PUZZLE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: _timeLeft / 10,
                backgroundColor: NumbersColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timeLeft < 4 ? NumbersColors.coral : NumbersColors.green),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatDisplay(label: 'LEVEL', value: '$_level', color: NumbersColors.textFaint),
                _StatDisplay(label: 'SCORE', value: '$_score', color: NumbersColors.green),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              decoration: BoxDecoration(
                color: NumbersColors.backgroundOffWhite,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: NumbersColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: NumbersColors.cardShadow.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  _currentQuestion.text,
                  style: GoogleFonts.outfit(fontSize: 56, fontWeight: FontWeight.w900, color: NumbersColors.textBody),
                ).animate(key: ValueKey(_currentQuestion.text)).fadeIn().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
              ),
            ),
            const Spacer(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: _currentQuestion.options.map((opt) {
                return ElevatedButton(
                  onPressed: () => _checkAnswer(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: NumbersColors.textBody,
                    side: const BorderSide(color: NumbersColors.border, width: 1.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('$opt', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800)),
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

class _StatDisplay extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatDisplay({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: NumbersColors.textFaint, letterSpacing: 1.5)),
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
