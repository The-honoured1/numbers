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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MINESWEEPER', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
            Text('LEVEL $_currentLevel • $remaining MINES', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(onPressed: _startNewGame, icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Compact Mode Toggle
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: context.border, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCompactModeButton(
                    active: !_flagMode,
                    onTap: () => setState(() => _flagMode = false),
                    icon: Icons.ads_click_rounded,
                    label: 'Reveal',
                    color: NumbersColors.minesweeper,
                  ),
                  _buildCompactModeButton(
                    active: _flagMode,
                    onTap: () => setState(() => _flagMode = true),
                    icon: Icons.flag_rounded,
                    label: 'Flag',
                    color: NumbersColors.coral,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // The Board
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: _levelConfig.cols / _levelConfig.rows,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.border, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: context.shadow,
                          offset: const Offset(6, 6),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _levelConfig.cols,
                        childAspectRatio: 1,
                        mainAxisSpacing: 1.5,
                        crossAxisSpacing: 1.5,
                      ),
                      itemCount: _levelConfig.rows * _levelConfig.cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ _levelConfig.cols;
                        int c = index % _levelConfig.cols;
                        final cell = _game.board[r][c];
                        
                        return _buildCell(r, c, cell);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCompactModeButton({required bool active, required VoidCallback onTap, required IconData icon, required String label, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : context.onSurface.withOpacity(0.4), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: active ? Colors.white : context.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int r, int c, MineCell cell) {
    final bool isRevealed = cell.state == CellState.revealed;
    final bool isFlagged = cell.state == CellState.flagged;
    
    // NYT Style Checkered hidden board or clean grid
    final bool isAlt = (r + c) % 2 == 0;
    
    Color cellColor;
    if (isRevealed) {
      if (cell.isMine) {
        cellColor = NumbersColors.coral;
      } else {
        cellColor = context.surface;
      }
    } else {
      // Hidden cells - Stylish Indigo tints
      cellColor = isAlt ? const Color(0xFFEEF2FF) : const Color(0xFFE0E7FF);
      if (Theme.of(context).brightness == Brightness.dark) {
        cellColor = isAlt ? const Color(0xFF2E1065) : const Color(0xFF1E1B4B);
      }
    }

    return GestureDetector(
      onTap: () => _handleCellTap(r, c),
      child: Container(
        color: cellColor,
        child: Center(
          child: _buildCellContent(cell),
        ),
      ).animate(target: isRevealed ? 1 : 0),
    );
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
      style: GoogleFonts.playfairDisplay(
        color: _getNumberColor(cell.neighborMines),
        fontWeight: FontWeight.w900,
        fontSize: 22,
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }
}
