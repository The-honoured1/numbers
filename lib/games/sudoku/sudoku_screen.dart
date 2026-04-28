import 'package:numbers/presentation/widgets/banner_ad_widget.dart';
import 'package:numbers/presentation/widgets/tutorial_overlay.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
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
  final List<List<Set<int>>> _notes = List.generate(9, (_) => List.generate(9, (_) => {}));
  String _difficulty = 'Medium';
  int? _selectedRow;
  int? _selectedCol;
  bool _notesMode = false;
  bool _autoCheck = true;
  final Stopwatch _sessionTimer = Stopwatch();


  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _startNewGame();
    _sessionTimer.start();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: 'sudoku',
        title: 'Number Grid',
        description: 'Fill the 9×9 grid so that each column, each row, and each of the nine 3×3 subgrids contain all the digits from 1 to 9.',
        icon: Icons.grid_4x4_rounded,
      );
    });
  }

  @override
  void dispose() {
    _sessionTimer.stop();
    StorageService().addPlayTime('sudoku', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _startNewGame() {
    StorageService().incrementPlayCount('sudoku');
    _initialGrid = _logic.generatePuzzle(_difficulty);
    _currentGrid = List.generate(9, (i) => List.from(_initialGrid[i]));
    for (var r in _notes) {
      for (var cell in r) {
        cell.clear();
      }
    }
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
        if (_notesMode) {
          if (_notes[_selectedRow!][_selectedCol!].contains(num)) {
            _notes[_selectedRow!][_selectedCol!].remove(num);
          } else {
            _notes[_selectedRow!][_selectedCol!].add(num);
          }
          _currentGrid[_selectedRow!][_selectedCol!] = 0;
        } else {
          if (_currentGrid[_selectedRow!][_selectedCol!] == num) {
            _currentGrid[_selectedRow!][_selectedCol!] = 0;
          } else {
            _currentGrid[_selectedRow!][_selectedCol!] = num;
          }
        }
      });
      if (!_notesMode && _logic.isComplete(_currentGrid)) {
        StorageService().markDailyCompleted('sudoku');
        _showWinDialog();
      }
    }
  }

  void _showWinDialog() {
    AdService().showInterstitialAd();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Perfectly Solved!',
        message: 'Your logic is sharp. The grid is complete.',
        buttonText: 'NEW PUZZLE',
        color: NumbersColors.sudoku,
        icon: Icons.grid_4x4,
        onButtonPressed: () {
          Navigator.pop(context);
          setState(() => _startNewGame());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hiScore = StorageService().getHighScore('sudoku');

    return Scaffold(
      appBar: AppBar(
        title: Text('SUDOKU', 
          style: GoogleFonts.outfit(letterSpacing: 4, fontSize: 18, fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings_outlined),
            onSelected: (val) {
              if (val == 'toggle_check') {
                setState(() => _autoCheck = !_autoCheck);
                return;
              }
              setState(() {
                _difficulty = val;
                _startNewGame();
              });
            },
            itemBuilder: (context) => [
              ...['Easy', 'Medium', 'Hard', 'Expert'].map((d) => PopupMenuItem(value: d, child: Text(d))),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'toggle_check',
                child: Row(
                  children: [
                    Icon(_autoCheck ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: NumbersColors.yellow),
                    const SizedBox(width: 12),
                    const Text('Auto-Check Errors'),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(label: 'DIFFICULTY', value: _difficulty.toUpperCase(), color: NumbersColors.yellow),
                    _StatItem(label: 'HIGH SCORE', value: '$hiScore', color: context.textFaint),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: context.onSurface, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
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
                        final val = _currentGrid[r][c];
                        
                        bool isError = false;
                        if (_autoCheck && val != 0 && !isInitial) {
                          _currentGrid[r][c] = 0;
                          isError = !_logic.isValid(_currentGrid, r, c, val);
                          _currentGrid[r][c] = val;
                        }

                        return GestureDetector(
                          onTap: () => _onCellTap(r, c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: (c + 1) % 3 == 0 && c != 8 ? context.onSurface : context.gridBorder,
                                  width: (c + 1) % 3 == 0 && c != 8 ? 2 : 0.5,
                                ),
                                bottom: BorderSide(
                                  color: (r + 1) % 3 == 0 && r != 8 ? context.onSurface : context.gridBorder,
                                  width: (r + 1) % 3 == 0 && r != 8 ? 2 : 0.5,
                                ),
                              ),
                              color: isSelected 
                                  ? NumbersColors.yellow.withOpacity(0.3) 
                                  : (isInitial ? (Theme.of(context).brightness == Brightness.dark ? context.surface : const Color(0xFFF8FAFC)) : context.surface),
                            ),
                            alignment: Alignment.center,
                            child: val != 0 
                              ? Text(
                                  val.toString(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: isInitial ? FontWeight.w900 : FontWeight.w600,
                                    color: (isError && !isInitial) 
                                        ? NumbersColors.coral 
                                        : (isInitial ? context.onSurface : NumbersColors.yellow),
                                  ),
                                )
                              : _buildNotes(r, c),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildControls(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(9, (index) {
                    int num = index + 1;
                    return InkWell(
                      onTap: () => _onNumberTap(num),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 80) / 4.5,
                        height: 60,
                        decoration: BoxDecoration(
                          color: context.surface,
                          border: Border.all(color: context.border, width: 2.5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: context.shadow, offset: const Offset(4, 4)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(num.toString(), 
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: context.onSurface)),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              const BannerAdWidget(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotes(int r, int c) {
    if (_notes[r][c].isEmpty) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      children: List.generate(9, (i) {
        final n = i + 1;
        return Center(
          child: Text(
            _notes[r][c].contains(n) ? '$n' : '',
            style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: context.textFaint),
          ),
        );
      }),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ControlBtn(
            icon: Icons.undo_rounded, 
            label: 'UNDO', 
            onTap: () {
               // Simple reset to initial for now or implement stack
               setState(() => _currentGrid[_selectedRow!][_selectedCol!] = 0);
            },
            isActive: _selectedRow != null,
          ),
          _ControlBtn(
            icon: _notesMode ? Icons.edit_rounded : Icons.edit_outlined, 
            label: 'PEN', 
            onTap: () => setState(() => _notesMode = !_notesMode),
            isActive: _notesMode,
            isToggle: true,
          ),
          _ControlBtn(
            icon: Icons.delete_outline_rounded, 
            label: 'CLEAR', 
            onTap: () {
               if (_selectedRow != null) {
                 setState(() {
                   _currentGrid[_selectedRow!][_selectedCol!] = 0;
                   _notes[_selectedRow!][_selectedCol!].clear();
                 });
               }
            },
            isActive: _selectedRow != null,
          ),
        ],
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
        Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isToggle;

  const _ControlBtn({required this.icon, required this.label, required this.onTap, this.isActive = false, this.isToggle = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? NumbersColors.yellow.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? NumbersColors.yellow : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? NumbersColors.yellow : context.textFaint, size: 28),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isActive ? NumbersColors.yellow : context.textFaint, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
