import 'package:numbers/presentation/widgets/banner_ad_widget.dart';
import 'package:numbers/presentation/widgets/tutorial_overlay.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'countdown_logic.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final CountdownLogic _logic = CountdownLogic();
  final StorageService _storage = StorageService();
  late CountdownGame _game;
  List<int> _availableNumbers = [];
  double _currentValue = 0;
  String _expression = "";
  int _timeLeft = 60;
  int _level = 1;
  int _revivesUsed = 0;
  Timer? _timer;
  final Stopwatch _sessionTimer = Stopwatch();
  String? _pendingOp;
  
  @override
  void initState() {
    super.initState();
    _game = _logic.generate();
    _availableNumbers = List.from(_game.numbers);
    _timeLeft = 60;
    _revivesUsed = 0;
    _sessionTimer.start();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: 'countdown',
        title: 'Countdown',
        description: 'Use the available numbers and mathematical operators provided to exactly calculate the target number before time runs out!',
        icon: Icons.timer_rounded,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTimer.stop();
    _storage.addPlayTime('countdown', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _startNewRound() {
    _storage.incrementPlayCount('countdown');
    _game = _logic.generate();
    _availableNumbers = List.from(_game.numbers);
    _currentValue = 0;
    _expression = "";
    _pendingOp = null;
    _revivesUsed = 0;
    _timeLeft = (60 - (_level * 2)).clamp(20, 60);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _showGameOver("Time's up!");
      }
    });
  }

  void _onNumberTap(int num, int index) {
    setState(() {
      if (_pendingOp == null) {
        _currentValue = num.toDouble();
        _expression = "$num";
      } else {
        switch (_pendingOp) {
          case '+': _currentValue += num; break;
          case '-': _currentValue -= num; break;
          case '×': _currentValue *= num; break;
          case '÷': _currentValue /= num; break;
        }
        _expression = "($_expression $_pendingOp $num)";
        _pendingOp = null;
      }
      _availableNumbers.removeAt(index);
    });

    if (_currentValue == _game.target) {
      _timer?.cancel();
      _storage.incrementWins('countdown');
      _storage.markDailyCompleted('countdown');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GameResultDialog(
          title: 'Target Reached!',
          message: 'Excellent calculation! Level $_level cleared.',
          buttonText: 'NEXT LEVEL',
          icon: Icons.check_circle_rounded,
          color: NumbersColors.green,
          onButtonPressed: () {
            Navigator.pop(context);
            setState(() {
              _level++;
              _startNewRound();
            });
          },
        ),
      );
    }
  }

  void _onOpTap(String op) {
    if (_expression.isNotEmpty) {
      setState(() => _pendingOp = op);
    }
  }

  void _showGameOver(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: msg,
        message: 'Close but no cigar! Target was ${_game.target}. Your value: ${_currentValue.toInt()}',
        buttonText: 'TRY AGAIN',
        color: NumbersColors.countdown,
        icon: Icons.timer_off_outlined,
        onRevive: _revivesUsed >= 2 ? null : () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            setState(() {
              _revivesUsed++;
              _timeLeft = 30; // Give 30 more seconds
              _startTimer();
            });
          });
        },
        onButtonPressed: () => Navigator.pop(context),
      ),
    ).then((_) {
      if (mounted && _timeLeft == 0 && _revivesUsed == 0) {
        // Only pop if user didn't revive and time is zero
        // Navigator.pop(context); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool timeWarning = _timeLeft <= 10;
    
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('COUNTDOWN', style: GoogleFonts.outfit(letterSpacing: 4, fontSize: 18, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            children: [
              // Timer Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                       color: timeWarning ? NumbersColors.coral.withOpacity(0.1) : NumbersColors.countdown.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(20),
                       border: Border.all(color: timeWarning ? NumbersColors.coral : NumbersColors.countdown, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(timeWarning ? Icons.timer_off_rounded : Icons.timer_rounded, 
                             color: timeWarning ? NumbersColors.coral : NumbersColors.countdown, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '00:${_timeLeft.toString().padLeft(2, '0')}',
                          style: GoogleFonts.outfit(
                            fontSize: 16, 
                            fontWeight: FontWeight.w900, 
                            color: timeWarning ? NumbersColors.coral : NumbersColors.countdown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _startNewRound()),
                    icon: Icon(Icons.refresh_rounded, color: context.textFaint, size: 18),
                    label: Text('RESET', style: GoogleFonts.outfit(color: context.textFaint, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Target Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.border, width: 3),
                  boxShadow: [
                    BoxShadow(color: context.shadow, offset: const Offset(8, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Text('TARGET NUMBER', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: context.textFaint, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(
                      '${_game.target}', 
                      style: GoogleFonts.playfairDisplay(fontSize: 72, fontWeight: FontWeight.w900, height: 1, letterSpacing: -2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Current State
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NumbersColors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NumbersColors.yellow, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      _expression.isEmpty ? 'TAP A NUMBER' : _expression, 
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: context.textFaint),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentValue == 0 ? '-' : '=${_currentValue.toInt()}', 
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: NumbersColors.yellow),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Numbers Pad
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _availableNumbers.asMap().entries.map((e) {
                  return GestureDetector(
                    onTap: () => _onNumberTap(e.value, e.key),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 48 - (12 * 3)) / 4,
                      height: 64,
                      decoration: BoxDecoration(
                        color: NumbersColors.countdown,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.border, width: 2),
                        boxShadow: [
                          BoxShadow(color: context.shadow, offset: const Offset(0, 4)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text('${e.value}', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Operators Pad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['+', '-', '×', '÷'].map((op) {
                  bool isSelected = _pendingOp == op;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => _onOpTap(op),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? context.onSurface : context.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.border, width: 2.5),
                          boxShadow: isSelected ? [] : [
                            BoxShadow(color: context.shadow, offset: const Offset(2, 4)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          op, 
                          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: isSelected ? context.surface : context.onSurface, height: 1.1),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const BannerAdWidget(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
