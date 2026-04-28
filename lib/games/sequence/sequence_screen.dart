import 'package:numbers/presentation/widgets/banner_ad_widget.dart';
import 'package:numbers/presentation/widgets/tutorial_overlay.dart';
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
  int _score = 0;
  int _streak = 0;
  int _revivesUsed = 0;
  final Stopwatch _sessionTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _storage.incrementPlayCount('sequence');
    _question = _logic.generate(_streak);
    _sessionTimer.start();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: 'sequence',
        title: 'Sequence',
        description: 'Analyze the pattern and pick the missing number to keep your streak alive!',
        icon: Icons.trending_up_rounded,
      );
    });
  }

  @override
  void dispose() {
    _sessionTimer.stop();
    _storage.addPlayTime('sequence', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _check(int selectedAnswer) {
    if (selectedAnswer == _question.answer) {
      _storage.markDailyCompleted('sequence');
      setState(() {
        _score += (20 + _streak * 5);
        _streak++;
        
        // Show interstitial ad every 5 streak milestones
        if (_streak > 0 && _streak % 5 == 0) {
          AdService().showInterstitialAd();
        }

        _question = _logic.generate(_streak);
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
          onRevive: _revivesUsed >= 2 ? null : () {
            AdService().showRewardedAd(() {
              Navigator.pop(context);
              setState(() {
                _revivesUsed++;
                _question = _logic.generate(_streak);
              });
            });
          },
          onButtonPressed: () {
            Navigator.pop(context);
            setState(() {
              _streak = 0;
              _score = 0;
              _revivesUsed = 0;
              _question = _logic.generate(_streak);
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('SEQUENCE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  color: context.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: context.border, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadow,
                      offset: const Offset(8, 8),
                    )
                  ],
                ),
                child: Text(
                  _question.text,
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: context.onSurface,
                    letterSpacing: 1,
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2,
                children: _question.options.map((option) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: context.shadow, offset: const Offset(4, 4)),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _check(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.surface,
                        foregroundColor: NumbersColors.purple,
                        side: BorderSide(color: context.onSurface, width: 2.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('$option', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: context.onSurface)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatTile(label: 'SCORE', value: '$_score', color: NumbersColors.purple),
                  const SizedBox(width: 60),
                  _StatTile(label: 'STREAK', value: '$_streak', color: NumbersColors.yellow),
                ],
              ),
              const SizedBox(height: 32),
              const BannerAdWidget(),
              const SizedBox(height: 24),
            ],
          ),
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
        Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
