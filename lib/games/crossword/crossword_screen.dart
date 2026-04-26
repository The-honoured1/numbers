import 'package:flutter/material.dart';
import '../../core/design_system.dart';
import 'crossword_logic.dart';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({super.key});

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  final CrosswordLogic _logic = CrosswordLogic();
  late CrosswordData _data;
  List<int?> _playerValues = [null, null, null, null];
  
  @override
  void initState() {
    super.initState();
    _data = _logic.generate(3);
  }

  Widget _buildCell(String content, {Color? color, bool isInput = false, int? index}) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isInput 
        ? TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (val) {
              setState(() {
                _playerValues[index!] = int.tryParse(val);
              });
              _checkWin();
            },
          )
        : Text(content, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  void _checkWin() {
    if (_playerValues.every((v) => v != null)) {
      bool win = true;
      for (int i = 0; i < 4; i++) {
        if (_playerValues[i] != _data.values[i]) win = false;
      }
      if (win) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(title: Text('Solved!'), content: Text('Everything checks out.')),
        ).then((_) => Navigator.pop(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Math Crossword')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCell('', isInput: true, index: 0),
                  _buildCell(_data.ops[0], color: NumbersColors.crossOperator),
                  _buildCell('', isInput: true, index: 1),
                  _buildCell('=', color: NumbersColors.crossEquals),
                  _buildCell('${_data.results[0]}', color: NumbersColors.crossCorrect),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCell(_data.ops[1], color: NumbersColors.crossOperator),
                  const SizedBox(width: 50 * 1), // skipped col indices
                  _buildCell(_data.ops[2], color: NumbersColors.crossOperator),
                  const SizedBox(width: 50 * 2), // skipped equals/res
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCell('', isInput: true, index: 2),
                  _buildCell(_data.ops[3], color: NumbersColors.crossOperator),
                  _buildCell('', isInput: true, index: 3),
                  _buildCell('=', color: NumbersColors.crossEquals),
                  _buildCell('${_data.results[1]}', color: NumbersColors.crossCorrect),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCell('=', color: NumbersColors.crossEquals),
                  const SizedBox(width: 50 * 1),
                  _buildCell('=', color: NumbersColors.crossEquals),
                  const SizedBox(width: 50 * 2),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCell('${_data.results[2]}', color: NumbersColors.crossCorrect),
                  const SizedBox(width: 50 * 1),
                  _buildCell('${_data.results[3]}', color: NumbersColors.crossCorrect),
                  const SizedBox(width: 50 * 2),
                ],
              ),
              const SizedBox(height: 40),
              const Text('Fill in the blank cells so all equations hold.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
