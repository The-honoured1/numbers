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
  Timer? _timer;
  final Stopwatch _sessionTimer = Stopwatch();
  
  @override
  void initState() {
    super.initState();
    _game = _logic.generate();
    _availableNumbers = List.from(_game.numbers);
    _timeLeft = 60;
    _sessionTimer.start();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialDialog.checkAndShow(
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
      _level++;
      _storage.markDailyCompleted('countdown');
      _showWin();
    }
  }

  void _onOpTap(String op) {
    if (_expression.isNotEmpty) {
      setState(() => _pendingOp = op);
    }
  }

  void _showWin() {
    _storage.markDailyCompleted('countdown');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Target Reached!',
        message: 'Expression: $_expression',
        buttonText: 'COLLECT POINTS',
        onButtonPressed: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  void _showGameOver(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: msg,
        message: 'Close but no cigar! Target was ${_game.target}. Your value: $_currentValue',
        buttonText: 'TRY AGAIN',
        color: NumbersColors.countdown,
        icon: Icons.timer_off_outlined,
        onRevive: () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            setState(() {
              _timeLeft = 30; // Give 30 more seconds
              _startTimer();
            });
          });
        },
        onButtonPressed: () => Navigator.pop(context),
      ),
    ).then((_) {
      if (mounted && _timeLeft == 0) {
        Navigator.pop(context);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('TIME: $_timeLeft', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: _timeLeft < 10 ? NumbersColors.coral : context.onSurface)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: context.onSurface, borderRadius: BorderRadius.circular(12)),
              child: Text('${_game.target}', style: TextStyle(color: context.surface, fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: 8)),
            ),
            const SizedBox(height: 40),
            Text('Current: $_currentValue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_expression, style: TextStyle(color: Colors.grey)),
            const Spacer(),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableNumbers.asMap().entries.map((e) {
                return ElevatedButton(
                  onPressed: () => _onNumberTap(e.value, e.key),
                  style: ElevatedButton.styleFrom(backgroundColor: NumbersColors.countdown, foregroundColor: Colors.white),
                  child: Text('${e.value}', style: TextStyle(fontSize: 20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['+', '-', '×', '÷'].map((op) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filled(
                    onPressed: () => _onOpTap(op),
                    icon: Text(op, style: TextStyle(fontSize: 24, color: context.surface)),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.shade800),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            TextButton(onPressed: () => setState(() => _startNewRound()), child: const Text('RESET ROUND')),
          ],
        ),
      ),
    );
  }
}
