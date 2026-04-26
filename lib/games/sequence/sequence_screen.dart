import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
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
    _question = _logic.generate();
  }

  void _check() {
    if (_controller.text == _question.answer.toString()) {
      _storage.markDailyCompleted('sequence');
      setState(() {
        _score += (20 + _streak * 5);
        _streak++;
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('SEQUENCE')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            Text(
              _question.typeName.toUpperCase(),
              style: GoogleFonts.inter(
                letterSpacing: 2,
                color: NumbersColors.textFaint,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              _question.text,
              style: GoogleFonts.lora(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: NumbersColors.textBody,
              ),
            ),
            const SizedBox(height: 60),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '?',
                hintStyle: const TextStyle(color: NumbersColors.border),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: NumbersColors.border)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: NumbersColors.textBody, width: 2)),
              ),
              onSubmitted: (_) => _check(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatTile(label: 'SCORE', value: '$_score'),
                const SizedBox(width: 40),
                _StatTile(label: 'STREAK', value: '$_streak'),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('CHECK SEQUENCE'),
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
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: NumbersColors.textFaint, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: NumbersColors.textBody)),
      ],
    );
  }
}
