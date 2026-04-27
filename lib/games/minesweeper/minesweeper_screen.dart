import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'minesweeper_logic.dart';
import 'package:numbers/presentation/widgets/tutorial_overlay.dart';

/// Level config: returns (rows, cols, mines) for a given level 1–500
class MinesweeperLevel {
  final int rows;
  final int cols;
  final int mines;
  const MinesweeperLevel(this.rows, this.cols, this.mines);

  static MinesweeperLevel forLevel(int level) {
    // Levels 1–50:     Beginner    6x6, 3–8 mines
    // Levels 51–150:   Easy        8x8, 8–15 mines
    // Levels 151–300:  Medium      10x8, 12–25 mines
    // Levels 301–450:  Hard        12x10, 20–40 mines
    // Levels 451–500:  Expert      14x10, 35–55 mines

    if (level <= 50) {
      int mines = 3 + ((level - 1) * 5 ~/ 49); // 3..8
      return MinesweeperLevel(6, 6, mines.clamp(3, 8));
    } else if (level <= 150) {
      int mines = 8 + ((level - 51) * 7 ~/ 99); // 8..15
      return MinesweeperLevel(8, 8, mines.clamp(8, 15));
    } else if (level <= 300) {
      int mines = 12 + ((level - 151) * 13 ~/ 149); // 12..25
      return MinesweeperLevel(10, 8, mines.clamp(12, 25));
    } else if (level <= 450) {
      int mines = 20 + ((level - 301) * 20 ~/ 149); // 20..40
      return MinesweeperLevel(12, 10, mines.clamp(20, 40));
    } else {
      int mines = 35 + ((level - 451) * 20 ~/ 49); // 35..55
      return MinesweeperLevel(14, 10, mines.clamp(35, 55));
    }
  }

  String get difficulty {
    if (rows <= 6) return 'BEGINNER';
    if (rows <= 8) return 'EASY';
    if (rows <= 10) return 'MEDIUM';
    if (rows <= 12) return 'HARD';
    return 'EXPERT';
  }

  Color get difficultyColor {
    if (rows <= 6) return NumbersColors.green;
    if (rows <= 8) return NumbersColors.blue;
    if (rows <= 10) return NumbersColors.yellow;
    if (rows <= 12) return NumbersColors.coral;
    return NumbersColors.purple;
  }
}


class MinesweeperScreen extends StatefulWidget {
  final int initialLevel;
  const MinesweeperScreen({super.key, this.initialLevel = 1});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreenState();
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  late MinesweeperGame _game;
  bool _flagMode = false;
  int _currentLevel = 1;
  late MinesweeperLevel _levelConfig;
  final Stopwatch _sessionTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevel;
    if (_currentLevel < 1) _currentLevel = 1;
    _sessionTimer.start();
    _startNewGame();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialDialog.checkAndShow(
        context: context,
        gameId: 'minesweeper',
        title: 'Minesweeper',
        description: 'Clear the board without hitting any hidden mines! The numbers reveal how many mines are hiding in the adjacent eight squares. Tap FLAG to mark suspected mines.',
        icon: Icons.brightness_7_rounded,
      );
    });
  }

  @override
  void dispose() {
    _sessionTimer.stop();
    StorageService().addPlayTime('minesweeper', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _startNewGame() {
    StorageService().incrementPlayCount('minesweeper');
    _levelConfig = MinesweeperLevel.forLevel(_currentLevel);
    setState(() {
      _game = MinesweeperGame(
        rows: _levelConfig.rows, 
        cols: _levelConfig.cols, 
        mineCount: _levelConfig.mines,
      );
      _flagMode = false;
    });
  }

  void _handleCellTap(int r, int c) {
    setState(() {
      if (_flagMode) {
        _game.toggleFlag(r, c);
      } else {
        _game.reveal(r, c);
      }
    });

    if (_game.gameWon) {
      StorageService().markDailyCompleted('minesweeper');
      StorageService().incrementWins('minesweeper');
      _showResult(true);
    }
    if (_game.gameOver) _showResult(false, r: r, c: c);
  }

  void _showResult(bool won, {int? r, int? c}) {
    if (won) AdService().showInterstitialAd();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: won ? 'Level $_currentLevel Cleared!' : 'Kaboom!',
        message: won 
            ? 'You cleared a ${_levelConfig.difficulty} minefield. Onward to level ${_currentLevel + 1}!' 
            : 'You hit a mine on level $_currentLevel. Try again!',
        buttonText: won ? 'NEXT LEVEL' : 'RETRY LEVEL',
        color: won ? NumbersColors.crossCorrect : NumbersColors.countdown,
        icon: won ? Icons.shield_outlined : Icons.brightness_7_outlined,
        onRevive: won ? null : () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            if (r != null && c != null) {
              setState(() {
                _game.revive(r, c);
              });
            }
          });
        },
        onButtonPressed: () {
          Navigator.pop(context);
          if (won) {
            _currentLevel++;
            if (_currentLevel > 500) _currentLevel = 500;
            // Save progress
            StorageService().saveHighScore('minesweeper_level', _currentLevel);
          }
          _startNewGame();
        },
      ),
    );
  }

  Color _getNumberColor(int n) {
    switch (n) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.purple;
      case 5: return Colors.orange;
      default: return context.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flagCount = _game.board.expand((r) => r).where((c) => c.state == CellState.flagged).length;
    final remaining = _levelConfig.mines - flagCount;

    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('MINESWEEPER', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
        actions: [
          IconButton(onPressed: _startNewGame, icon: Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEVEL', style: GoogleFonts.outfit(letterSpacing: 1, fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint)),
                    Text('$_currentLevel / 500', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _levelConfig.difficultyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _levelConfig.difficulty,
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: _levelConfig.difficultyColor, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.brightness_7, color: NumbersColors.coral, size: 18),
                    const SizedBox(width: 6),
                    Text('$remaining', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900)),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _flagMode = !_flagMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _flagMode ? context.onSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.onSurface, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: _flagMode ? Colors.white : context.onSurface, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'FLAG',
                          style: GoogleFonts.outfit(
                            color: _flagMode ? Colors.white : context.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: _levelConfig.cols / _levelConfig.rows,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: context.border, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _levelConfig.cols,
                      ),
                      itemCount: _levelConfig.rows * _levelConfig.cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ _levelConfig.cols;
                        int c = index % _levelConfig.cols;
                        final cell = _game.board[r][c];
                        
                        return GestureDetector(
                          onTap: () => _handleCellTap(r, c),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cell.state == CellState.revealed 
                                  ? (cell.isMine ? NumbersColors.coral : context.surface)
                                  : context.textFaint.withOpacity(0.1),
                              border: Border.all(color: context.border, width: 2.5),
                            ),
                            alignment: Alignment.center,
                            child: _buildCellContent(cell),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCellContent(MineCell cell) {
    if (cell.state == CellState.flagged) {
      return Icon(Icons.flag, color: NumbersColors.countdown, size: 16)
          .animate().scale(duration: 200.ms, curve: Curves.easeOutBack);
    }
    
    if (cell.state == CellState.revealed) {
      if (cell.isMine) {
        return Icon(Icons.brightness_7_outlined, color: Colors.orange, size: 18);
      }
      if (cell.neighborMines > 0) {
        return Text(
          '${cell.neighborMines}',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: _getNumberColor(cell.neighborMines),
          ),
        );
      }
    }
    
    return const SizedBox.shrink();
  }
}
