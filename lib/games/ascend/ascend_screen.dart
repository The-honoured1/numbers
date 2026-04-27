import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'ascend_logic.dart';
import 'package:numbers/presentation/widgets/tutorial_overlay.dart';

class AscendScreen extends StatefulWidget {
  const AscendScreen({super.key});

  @override
  State<AscendScreen> createState() => _AscendScreenState();
}


class _AscendScreenState extends State<AscendScreen> {
  final AscendLogic _logic = AscendLogic();
  late List<int> _numbers;
  late List<int> _sorted;
  int _nextIdx = 0;
  int _score = 0;
  int _round = 1;
  int _timeLeft = 15;
  Timer? _timer;
  final Stopwatch _sessionTimer = Stopwatch();
  int _revivesUsed = 0;

  @override
  void initState() {
    super.initState();
    _numbers = _logic.generate(12, 100 * _round)..shuffle();
    _sorted = List.from(_numbers)..sort();
    _sessionTimer.start();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: 'zen_ascend',
        title: 'Zen Ascend',
        description: 'Tap the sequence of numbers in strictly ascending order as fast as you can. Incorrect taps incur a time penalty.',
        icon: Icons.keyboard_double_arrow_up_rounded,
      );
      _startNewRound();
    });
  }

  void _startNewRound() {
    StorageService().incrementPlayCount('ascend');
    setState(() {
      _numbers = _logic.generate(12, 100 * _round)..shuffle();
      _sorted = List.from(_numbers)..sort();
      _nextIdx = 0;
      _timeLeft = 15;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _onTap(int num) {
    if (num == _sorted[_nextIdx]) {
      setState(() {
        _nextIdx++;
        _score += 10;
        _timeLeft += 1; // Bonus time
      });
      StorageService().saveHighScore('ascend', _score);
      if (_nextIdx == _sorted.length) {
        _timer?.cancel();
        _round++;
        
        // Show interstitial ad every 5 rounds
        if (_round > 1 && (_round - 1) % 5 == 0) {
          AdService().showInterstitialAd(onClosed: () {
            if (mounted) _startNewRound();
          });
        } else {
          _startNewRound();
        }
      }
    } else {
      setState(() {
        _timeLeft = (_timeLeft - 2).clamp(0, 99);
      });
    }
  }

  void _endGame() {
    _timer?.cancel();
    StorageService().saveHighScore('ascend', _score);
    StorageService().markDailyCompleted('ascend');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Time Expired',
        message: 'You reached an ascending score of $_score!',
        buttonText: 'TRY AGAIN',
        color: NumbersColors.green,
        icon: Icons.timer_off_rounded,
        onRevive: _revivesUsed < 2 ? () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            setState(() {
              _revivesUsed++;
              _timeLeft = 10; // Give some time back
            });
            _startTimer();
          });
        } : null,
        onButtonPressed: () {
          Navigator.pop(context);
          setState(() {
            _score = 0;
            _round = 1;
            _revivesUsed = 0;
          });
          _startNewRound();
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTimer.stop();
    StorageService().addPlayTime('zen_ascend', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('ZEN ASCEND', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(label: 'TIME', value: '${_timeLeft}s', color: _timeLeft < 4 ? NumbersColors.coral : NumbersColors.green),
                _StatItem(label: 'SCORE', value: '$_score', color: context.onSurface),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'TAP NUMBERS IN ASCENDING ORDER',
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 2),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _numbers.length,
              itemBuilder: (context, index) {
                final num = _numbers[index];
                final isSolved = _sorted.indexOf(num) < _nextIdx;
                
                return GestureDetector(
                  onTap: isSolved ? null : () => _onTap(num),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isSolved ? NumbersColors.green.withOpacity(0.15) : context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSolved ? NumbersColors.green : context.border,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.shadow,
                          offset: const Offset(4, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$num',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isSolved ? NumbersColors.green : context.onSurface,
                      ),
                    ),
                  ).animate(key: ValueKey('tile_$num')).fadeIn().scale(),
                );
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 1.5)),
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
