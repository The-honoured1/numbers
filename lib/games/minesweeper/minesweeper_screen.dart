import 'package:flutter/material.dart';
import 'package:numbers/presentation/widgets/banner_ad_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'minesweeper_logic.dart';

/// Level config: returns (rows, cols, mines) for a given level 1–500
class MinesweeperLevel {
  final int rows;
  final int cols;
  final int mines;
  const MinesweeperLevel(this.rows, this.cols, this.mines);

  static MinesweeperLevel forLevel(int level) {
    if (level <= 20) {
      // Tutorial: Very small grids
      int mines = 2 + (level ~/ 10);
      return MinesweeperLevel(5, 4, mines.clamp(2, 4));
    } else if (level <= 100) {
      // Easy: 6x5
      int mines = 5 + ((level - 21) * 5 ~/ 79);
      return MinesweeperLevel(6, 5, mines.clamp(5, 10));
    } else if (level <= 250) {
      // Medium: 7x6
      int mines = 10 + ((level - 101) * 10 ~/ 149);
      return MinesweeperLevel(7, 6, mines.clamp(10, 20));
    } else if (level <= 400) {
      // Hard: 8x6
      int mines = 20 + ((level - 251) * 15 ~/ 149);
      return MinesweeperLevel(8, 6, mines.clamp(20, 35));
    } else {
      // Expert: 9x7 or 10x8
      int mines = 35 + ((level - 401) * 20 ~/ 99);
      return MinesweeperLevel(10, 8, mines.clamp(35, 55));
    }
  }

  String get difficulty {
    if (mines <= 4) return 'TUTORIAL';
    if (mines <= 10) return 'EASY';
    if (mines <= 20) return 'MEDIUM';
    if (mines <= 35) return 'HARD';
    return 'EXPERT';
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
  int _revivesUsed = 0;
  late MinesweeperLevel _levelConfig;
  final Stopwatch _sessionTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevel;
    if (_currentLevel < 1) _currentLevel = 1;
    _sessionTimer.start();
    _startNewGame();
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
      _revivesUsed = 0;
    });
  }

  void _handleCellTap(int r, int c) {
    setState(() {
      if (_flagMode) {
        final cell = _game.board[r][c];
        final flagCount = _game.board.expand((r) => r).where((c) => c.state == CellState.flagged).length;
        
        // Allow unflagging always, but only allow flagging if flags are remaining
        if (cell.state == CellState.flagged || flagCount < _levelConfig.mines) {
          _game.toggleFlag(r, c);
        }
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
    if (won && (_currentLevel + 1) % 5 == 0) AdService().showInterstitialAd();

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
        onRevive: (won || _revivesUsed >= 2) ? null : () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            if (r != null && c != null) {
              setState(() {
                _revivesUsed++;
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
            StorageService().saveHighScore('minesweeper_level', _currentLevel);
          }
          _startNewGame();
        },
      ),
    );
  }

  Color _getNumberColor(int n) {
    if (Theme.of(context).brightness == Brightness.dark) {
      switch (n) {
        case 1: return const Color(0xFF60A5FA); // Vibrant Blue
        case 2: return const Color(0xFF4ADE80); // Vibrant Green
        case 3: return const Color(0xFFF87171); // Vibrant Red
        case 4: return const Color(0xFFC084FC); // Vibrant Purple
        case 5: return const Color(0xFFFB923C); // Vibrant Orange
        case 6: return const Color(0xFF2DD4BF); // Vibrant Teal
        default: return Colors.white;
      }
    } else {
      switch (n) {
        case 1: return const Color(0xFF2563EB); // Deep Blue
        case 2: return const Color(0xFF16A34A); // Deep Green
        case 3: return const Color(0xFFDC2626); // Deep Red
        case 4: return const Color(0xFF9333EA); // Deep Purple
        case 5: return const Color(0xFFEA580C); // Deep Orange
        case 6: return const Color(0xFF0D9488); // Deep Teal
        default: return Colors.black;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flagCount = _game.board.expand((r) => r).where((c) => c.state == CellState.flagged).length;
    int remaining = _levelConfig.mines - flagCount;
    if (remaining < 0) remaining = 0;

    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: const Text('MINESWEEPER'),
        actions: [
          IconButton(onPressed: _startNewGame, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MINES', style: GoogleFonts.inter(letterSpacing:1, fontSize: 10, fontWeight: FontWeight.w800, color: context.onSurface)),
                    Text('$remaining', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: context.onSurface)),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _flagMode = !_flagMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _flagMode ? NumbersColors.textBody : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: NumbersColors.textBody, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: _flagMode ? Colors.white : NumbersColors.textBody, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'FLAG MODE',
                          style: GoogleFonts.inter(
                            color: _flagMode ? Colors.white : NumbersColors.textBody,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AspectRatio(
                  aspectRatio: _levelConfig.cols / _levelConfig.rows,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.border, width: 3),
                      boxShadow: [
                        BoxShadow(color: context.shadow, offset: const Offset(8, 8)),
                      ],
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _levelConfig.cols,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: _levelConfig.rows * _levelConfig.cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ _levelConfig.cols;
                        int c = index % _levelConfig.cols;
                        final cell = _game.board[r][c];
                        final isRevealed = cell.state == CellState.revealed;
                        final isFlagged = cell.state == CellState.flagged;

                        Color tileColor;
                        if (isRevealed) {
                          tileColor = cell.isMine
                              ? NumbersColors.coral
                              : (Theme.of(context).brightness == Brightness.dark 
                                  ? const Color(0xFF27272A)
                                  : const Color(0xFFE4E4E7));
                        } else {
                          tileColor = NumbersColors.minesweeper;
                        }

                        return GestureDetector(
                          onTap: () => _handleCellTap(r, c),
                          child: Container(
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isRevealed ? context.border.withOpacity(0.2) : context.border, 
                                width: isRevealed ? 1 : 2
                              ),
                              boxShadow: isRevealed ? [] : [
                                BoxShadow(color: context.shadow, offset: const Offset(0, 3)),
                              ],
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
          const SizedBox(height: 16),
          const BannerAdWidget(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCellContent(MineCell cell) {
    if (cell.state == CellState.flagged) {
      return const Icon(Icons.flag_rounded, color: NumbersColors.coral, size: 20)
          .animate().scale(duration: 200.ms, curve: Curves.easeOutBack);
    }

    if (cell.state == CellState.revealed) {
      if (cell.isMine) {
        return const Icon(Icons.coronavirus_rounded, color: Colors.white, size: 24);
      }
      if (cell.neighborMines > 0) {
        return Text(
          '${cell.neighborMines}',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: _getNumberColor(cell.neighborMines),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}
