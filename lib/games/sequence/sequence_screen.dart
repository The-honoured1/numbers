import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'sequence_logic.dart';

class SequenceScreen extends StatefulWidget {
  const SequenceScreen({super.key});

  @override
  State<SequenceScreen> createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen> {
  final SequenceLogic _logic = SequenceLogic();
  final StorageService _storage = StorageService();
  late SequenceQuestion _question;
  final TextEditingController _controller = TextEditingController();
  int _score = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _storage.incrementPlayCount('sequence');
    _question = _logic.generate();
  }

  void _check() {
    if (_controller.text == _question.answer.toString()) {
      _storage.markDailyCompleted('sequence');
      setState(() {
        _score += (20 + _streak * 5);
        _streak++;
        
        // Show interstitial ad every 5 streak milestones
        if (_streak > 0 && _streak % 5 == 0) {
          AdService().showInterstitialAd();
        }

        _question = _logic.generate();
        _controller.clear();
      });
      _storage.saveHighScore('sequence', _score);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GameResultDialog(
          title: 'Incorrect',
          message: 'The sequence was: ${_question.text.replaceAll('?', _question.answer.toString())}.\n\nYour streak: $_streak',
          buttonText: 'TRY ANOTHER',
          color: NumbersColors.countdown,
          icon: Icons.close,
          onRevive: () {
            AdService().showRewardedAd(() {
              Navigator.pop(context);
              setState(() {
                // Keep the streak and current score, just generate a new question
                _question = _logic.generate();
                _controller.clear();
              });
            });
          },
          onButtonPressed: () {
            Navigator.pop(context);
            setState(() {
              _streak = 0;
              _question = _logic.generate();
              _controller.clear();
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NumbersColors.background,
      appBar: AppBar(
        title: Text('SEQUENCE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: NumbersColors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _question.typeName.toUpperCase(),
                style: GoogleFonts.outfit(
                  letterSpacing: 2,
                  color: NumbersColors.purple,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
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
              child: Text(
                _question.text,
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: NumbersColors.textBody,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900, color: NumbersColors.purple),
              decoration: InputDecoration(
                hintText: '?',
                hintStyle: const TextStyle(color: NumbersColors.border),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: NumbersColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: NumbersColors.purple, width: 3),
                ),
              ),
              onSubmitted: (_) => _check(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatTile(label: 'SCORE', value: '$_score', color: NumbersColors.purple),
                const SizedBox(width: 60),
                _StatTile(label: 'STREAK', value: '$_streak', color: NumbersColors.yellow),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _check,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NumbersColors.textBody,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('CHECK SEQUENCE', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: NumbersColors.textFaint, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
