import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'minesweeper_logic.dart';
import 'package:numbers/presentation/widgets/tutorial_overlay.dart';
import 'package:numbers/presentation/widgets/full_screen_result.dart';

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
      await TutorialScreen.checkAndShow(
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

  void _handleCellTap(int r, int c, {bool isLongPress = false}) {
    setState(() {
      if (isLongPress) {
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

  void _handleChord(int r, int c) {
    setState(() {
      _game.chord(r, c);
    });
    if (_game.gameWon) {
      StorageService().markDailyCompleted('minesweeper');
      StorageService().incrementWins('minesweeper');
      _showResult(true);
    }
    if (_game.gameOver) _showResult(false, r: r, c: c);
  }

  void _showResult(bool won, {int? r, int? c}) {
    if (won && (_currentLevel + 1) % 3 == 0) AdService().showInterstitialAd();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenResult(
          won: won,
          gameId: 'minesweeper',
          title: won ? 'Victory!' : 'Kaboom!',
          score: 'LVL $_currentLevel',
          message: won 
              ? 'You mastered a ${_levelConfig.difficulty} minefield. Your precision is unmatched.' 
              : 'You hit a mine on level $_currentLevel. The field remains dangerous.',
          actionLabel: won ? 'NEXT LEVEL' : 'RETRY LEVEL',
          onAction: () {
            Navigator.pop(context);
            if (won) {
              _currentLevel++;
              if (_currentLevel > 500) _currentLevel = 500;
              StorageService().saveHighScore('minesweeper_level', _currentLevel);
            }
            _startNewGame();
          },
        ),
      ),
    );
  }

  Color _getNumberColor(int n) {
    switch (n) {
      case 1: return const Color(0xFF0EA5E9); // Blue
      case 2: return const Color(0xFF10B981); // Emerald
      case 3: return const Color(0xFFF43F5E); // Rose
      case 4: return const Color(0xFF8B5CF6); // Violet
      case 5: return const Color(0xFFD97706); // Amber
      case 6: return const Color(0xFF0891B2); // Cyan
      case 7: return NumbersColors.textBody;
      case 8: return NumbersColors.textFaint;
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
        centerTitle: false,
        backgroundColor: NumbersColors.minesweeper,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MINESWEEPER', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 0.5, color: Colors.white)),
            Text('LVL $_currentLevel • $remaining MINES', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.8), letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Long-press to FLAG • Tap to REVEAL', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  backgroundColor: NumbersColors.minesweeper,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
          ),
          IconButton(onPressed: _startNewGame, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: _levelConfig.cols / _levelConfig.rows,
                  child: Container(
                    decoration: BoxDecoration(
                      color: NumbersColors.minesweeper.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NumbersColors.minesweeper, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: NumbersColors.minesweeper.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _levelConfig.cols,
                        childAspectRatio: 1,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      itemCount: _levelConfig.rows * _levelConfig.cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ _levelConfig.cols;
                        int c = index % _levelConfig.cols;
                        final cell = _game.board[r][c];
                        
                        return GestureDetector(
                          onTap: () => _handleCellTap(r, c, isLongPress: false),
                          onLongPress: () {
                             Feedback.forLongPress(context);
                             _handleCellTap(r, c, isLongPress: true);
                          },
                          onDoubleTap: () => _handleChord(r, c),
                          child: _buildCell(r, c, cell),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }


  Widget _buildCell(int r, int c, MineCell cell) {
    final bool isRevealed = cell.state == CellState.revealed;
    final bool isFlagged = cell.state == CellState.flagged;
    final bool isAlt = (r + c) % 2 == 0;
    
    Color cellColor;
    if (isRevealed) {
      cellColor = cell.isMine ? NumbersColors.coral : context.surface;
    } else {
      // Hidden cells - Soft Indigo checkered
      cellColor = isAlt ? const Color(0xFFEEF2FF) : const Color(0xFFE0E7FF);
      if (Theme.of(context).brightness == Brightness.dark) {
        cellColor = isAlt ? const Color(0xFF312E81) : const Color(0xFF1E1B4B);
      }
    }

    return Container(
      color: cellColor,
      child: Center(
        child: _buildCellContent(cell),
      ),
    ).animate(target: isRevealed ? 1 : 0);
  }

  Widget _buildCellContent(MineCell cell) {
    if (cell.state == CellState.flagged) {
      return Icon(
        Icons.flag_rounded, 
        color: NumbersColors.coral, 
        size: 20,
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack).shake(hz: 4);
    }
    
    if (cell.state == CellState.hidden) {
      return const SizedBox.shrink();
    }

    if (cell.isMine) {
      return const Icon(
        Icons.brightness_7_rounded, 
        color: Colors.white, 
        size: 20,
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut);
    }

    if (cell.neighborMines == 0) return const SizedBox.shrink();

    return Text(
      '${cell.neighborMines}',
      style: GoogleFonts.outfit(
        color: _getNumberColor(cell.neighborMines),
        fontWeight: FontWeight.w900,
        fontSize: 22,
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }
}
