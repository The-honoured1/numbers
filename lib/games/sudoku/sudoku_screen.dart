import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system.dart';
import 'sudoku_logic.dart';

class SudokuScreen extends StatefulWidget {
  final String difficulty;
  const SudokuScreen({super.key, required this.difficulty});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final SudokuLogic _logic = SudokuLogic();
  late List<List<int>> _initialGrid;
  late List<List<int>> _currentGrid;
  int? _selectedRow;
  int? _selectedCol;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _initialGrid = _logic.generatePuzzle(widget.difficulty);
    _currentGrid = List.generate(9, (i) => List.from(_initialGrid[i]));
    _selectedRow = null;
    _selectedCol = null;
  }

  void _onCellTap(int r, int c) {
    if (_initialGrid[r][c] == 0) {
      setState(() {
        _selectedRow = r;
        _selectedCol = c;
      });
    }
  }

  void _onNumberTap(int num) {
    if (_selectedRow != null && _selectedCol != null) {
      setState(() {
        _currentGrid[_selectedRow!][_selectedCol!] = num;
      });
      if (_logic.isComplete(_currentGrid)) {
        _showWinDialog();
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You solved the puzzle.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.difficulty.toUpperCase()} SUDOKU', 
          style: GoogleFonts.inter(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: NumbersColors.textBody, width: 2),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                  ),
                  itemCount: 81,
                  itemBuilder: (context, index) {
                    int r = index ~/ 9;
                    int c = index % 9;
                    bool isInitial = _initialGrid[r][c] != 0;
                    bool isSelected = _selectedRow == r && _selectedCol == c;
                    
                    return GestureDetector(
                      onTap: () => _onCellTap(r, c),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: (c + 1) % 3 == 0 && c != 8 ? NumbersColors.textBody : Colors.grey.shade300,
                              width: (c + 1) % 3 == 0 && c != 8 ? 2 : 1,
                            ),
                            bottom: BorderSide(
                              color: (r + 1) % 3 == 0 && r != 8 ? NumbersColors.textBody : Colors.grey.shade300,
                              width: (r + 1) % 3 == 0 && r != 8 ? 2 : 1,
                            ),
                          ),
                          color: isSelected ? NumbersColors.sudoku.withOpacity(0.2) : Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _currentGrid[r][c] == 0 ? '' : _currentGrid[r][c].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
                            color: isInitial ? NumbersColors.textBody : NumbersColors.sudoku,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(9, (index) {
                int num = index + 1;
                return InkWell(
                  onTap: () => _onNumberTap(num),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(num.toString(), 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
