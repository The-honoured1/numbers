import 'package:flutter/material.dart';
import '../../core/design_system.dart';
import 'sequence_logic.dart';

class SequenceScreen extends StatefulWidget {
  const SequenceScreen({super.key});

  @override
  State<SequenceScreen> createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen> {
  final SequenceLogic _logic = SequenceLogic();
  late SequenceQuestion _question;
  final TextEditingController _controller = TextEditingController();
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _question = _logic.generate();
  }

  void _check() {
    if (_controller.text == _question.answer.toString()) {
      setState(() {
        _score += 20;
        _question = _logic.generate();
        _controller.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correct!'), backgroundColor: Colors.green, duration: Duration(milliseconds: 500)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wrong! It was ${_question.answer}'), backgroundColor: Colors.red),
      );
      setState(() {
        _question = _logic.generate();
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Sequence')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_question.typeName, style: const TextStyle(letterSpacing: 2, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(_question.text, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(
                hintText: 'Enter missing number',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _check(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _check,
              style: ElevatedButton.styleFrom(
                backgroundColor: NumeriaColors.sequence,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('CHECK ANSWER'),
            ),
            const SizedBox(height: 40),
            Text('SCORE: $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
