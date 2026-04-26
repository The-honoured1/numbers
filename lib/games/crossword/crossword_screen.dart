import 'package:flutter/material.dart';
import 'package:numbers/core/design_system.dart';
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
  int? _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _data = _logic.generate(3);
  }

  Widget _buildCell(String content, {Color? color, bool isInput = false, int? index}) {
    bool isSelected = _selectedIndex == index && isInput;
    
    return GestureDetector(
      onTap: isInput ? () => setState(() => _selectedIndex = index) : null,
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? NumbersColors.selection.withOpacity(0.3) : (color ?? Colors.white),
          border: Border.all(
            color: isSelected ? NumbersColors.selection : NumbersColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: isInput ? FontWeight.w800 : FontWeight.w500,
            color: isInput ? NumbersColors.textBody : NumbersColors.textFaint,
          ),
        ),
      ),
    );
  }

  void _onKeyPress(int value) {
    if (_selectedIndex != null) {
      setState(() {
        _playerValues[_selectedIndex!] = value;
      });
      _checkWin();
    }
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
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Puzzle Solved!'),
            content: const Text('You filled the grid correctly.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('AWESOME'),
              ),
            ],
          ),
        ).then((_) => Navigator.pop(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MATH CROSS'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCell(_playerValues[0]?.toString() ?? '', isInput: true, index: 0),
                        _buildCell(_data.ops[0], color: NumbersColors.backgroundOffWhite),
                        _buildCell(_playerValues[1]?.toString() ?? '', isInput: true, index: 1),
                        _buildCell('=', color: NumbersColors.backgroundOffWhite),
                        _buildCell('${_data.results[0]}', color: NumbersColors.crossCorrect.withOpacity(0.1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCell(_data.ops[1], color: NumbersColors.backgroundOffWhite),
                        const SizedBox(width: 60 + 8), 
                        _buildCell(_data.ops[2], color: NumbersColors.backgroundOffWhite),
                        const SizedBox(width: (60 + 8) * 2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCell(_playerValues[2]?.toString() ?? '', isInput: true, index: 2),
                        _buildCell(_data.ops[3], color: NumbersColors.backgroundOffWhite),
                        _buildCell(_playerValues[3]?.toString() ?? '', isInput: true, index: 3),
                        _buildCell('=', color: NumbersColors.backgroundOffWhite),
                        _buildCell('${_data.results[1]}', color: NumbersColors.crossCorrect.withOpacity(0.1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCell('=', color: NumbersColors.backgroundOffWhite),
                        const SizedBox(width: 60 + 8),
                        _buildCell('=', color: NumbersColors.backgroundOffWhite),
                        const SizedBox(width: (60 + 8) * 2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCell('${_data.results[2]}', color: NumbersColors.crossCorrect.withOpacity(0.1)),
                        const SizedBox(width: 60 + 8),
                        _buildCell('${_data.results[3]}', color: NumbersColors.crossCorrect.withOpacity(0.1)),
                        const SizedBox(width: (60 + 8) * 2),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            color: NumbersColors.backgroundOffWhite,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(9, (index) {
                int val = index + 1;
                return GestureDetector(
                  onTap: () => _onKeyPress(val),
                  child: Container(
                    width: 60,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: NumbersColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$val',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: NumbersColors.textBody,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
