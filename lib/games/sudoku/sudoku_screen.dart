import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/win_dialog.dart';
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
      barrierDismissible: false,
      builder: (context) => WinDialog(
        title: 'Perfectly Solved!',
        message: 'Your logic is sharp. The grid is complete.',
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onNext: () {
          Navigator.pop(context);
          setState(() => _startNewGame());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SUDOKU', 
          style: GoogleFonts.inter(letterSpacing: 4, fontSize: 16, fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: NumbersColors.sudoku.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.difficulty.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: NumbersColors.sudoku,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: NumbersColors.textBody, width: 2.5),
                  borderRadius: BorderRadius.circular(4),
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
                              width: (c + 1) % 3 == 0 && c != 8 ? 2 : 0.5,
                            ),
                            bottom: BorderSide(
                              color: (r + 1) % 3 == 0 && r != 8 ? NumbersColors.textBody : Colors.grey.shade300,
                              width: (r + 1) % 3 == 0 && r != 8 ? 2 : 0.5,
                            ),
                          ),
                          color: isSelected ? NumbersColors.sudoku.withOpacity(0.15) : Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _currentGrid[r][c] == 0 ? '' : _currentGrid[r][c].toString(),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: isInitial ? FontWeight.w800 : FontWeight.w500,
                            color: isInitial ? NumbersColors.textBody : NumbersColors.sudoku,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95)),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(9, (index) {
                int num = index + 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _onNumberTap(num),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(num.toString(), 
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
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
