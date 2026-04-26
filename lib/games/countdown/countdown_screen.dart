import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numbers/core/design_system.dart';
import 'countdown_logic.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final CountdownLogic _logic = CountdownLogic();
  late CountdownGame _game;
  List<int> _availableNumbers = [];
  double _currentValue = 0;
  String _expression = "";
  int _timeLeft = 60;
  Timer? _timer;
  
  String? _pendingOp;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    _game = _logic.generate();
    _availableNumbers = List.from(_game.numbers);
    _currentValue = 0;
    _expression = "";
    _pendingOp = null;
    _timeLeft = 60;
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
      _showWin();
    }
  }

  void _onOpTap(String op) {
    if (_expression.isNotEmpty) {
      setState(() => _pendingOp = op);
    }
  }

  void _showWin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Target Reached!'),
        content: Text('Expression: $_expression'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    ).then((_) => Navigator.pop(context));
  }

  void _showGameOver(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(msg),
        content: Text('Close but no cigar! Target was ${_game.target}. Your value: $_currentValue'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('TIME: $_timeLeft', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _timeLeft < 10 ? Colors.red : Colors.black)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Text('${_game.target}', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: 8)),
            ),
            const SizedBox(height: 40),
            Text('Current: $_currentValue', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_expression, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableNumbers.asMap().entries.map((e) {
                return ElevatedButton(
                  onPressed: () => _onNumberTap(e.value, e.key),
                  style: ElevatedButton.styleFrom(backgroundColor: NumbersColors.countdown, foregroundColor: Colors.white),
                  child: Text('${e.value}', style: const TextStyle(fontSize: 20)),
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
                    icon: Text(op, style: const TextStyle(fontSize: 24, color: Colors.white)),
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
