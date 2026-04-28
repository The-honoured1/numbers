import 'package:flutter/material.dart';
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
    if (level <= 50) {
      int mines = 3 + ((level - 1) * 5 ~/ 49);
      return MinesweeperLevel(6, 6, mines.clamp(3, 8));
    } else if (level <= 150) {
      int mines = 8 + ((level - 51) * 7 ~/ 99);
      return MinesweeperLevel(8, 8, mines.clamp(8, 15));
    } else if (level <= 300) {
      int mines = 12 + ((level - 151) * 13 ~/ 149);
      return MinesweeperLevel(10, 8, mines.clamp(12, 25));
    } else if (level <= 450) {
      int mines = 20 + ((level - 301) * 20 ~/ 149);
      return MinesweeperLevel(12, 10, mines.clamp(20, 40));
    } else {
      int mines = 35 + ((level - 451) * 20 ~/ 49);
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
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flagCount = _game.board.expand((r) => r).where((c) => c.state == CellState.flagged).length;
    final remaining = _levelConfig.mines - flagCount;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    Text('MINES', style: GoogleFonts.inter(letterSpacing:1, fontSize: 10, fontWeight: FontWeight.w800, color: NumbersColors.textFaint)),
                    Text('$remaining', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900)),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: AspectRatio(
                  aspectRatio: _levelConfig.cols / _levelConfig.rows,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0C0B6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        top: BorderSide(color: Colors.black.withOpacity(0.3), width: 3),
                        left: BorderSide(color: Colors.black.withOpacity(0.3), width: 3),
                        bottom: const BorderSide(color: Colors.white, width: 2),
                        right: const BorderSide(color: Colors.white, width: 2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(4, 4),
                          blurRadius: 4,
                        )
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

                        return GestureDetector(
                          onTap: () => _handleCellTap(r, c),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isRevealed
                                  ? (cell.isMine ? const Color(0xFFF8D7DA) : const Color(0xFFE2E2DF))
                                  : const Color(0xFFEFEFE6),
                              borderRadius: BorderRadius.circular(4),
                              border: isRevealed
                                  ? Border(
                                      top: BorderSide(color: Colors.black.withOpacity(0.1), width: 2),
                                      left: BorderSide(color: Colors.black.withOpacity(0.1), width: 2),
                                      bottom: const BorderSide(color: Colors.white, width: 1),
                                      right: const BorderSide(color: Colors.white, width: 1),
                                    )
                                  : Border(
                                      top: const BorderSide(color: Colors.white, width: 2),
                                      left: const BorderSide(color: Colors.white, width: 2),
                                      bottom: BorderSide(color: Colors.black.withOpacity(0.2), width: 3),
                                      right: BorderSide(color: Colors.black.withOpacity(0.2), width: 3),
                                    ),
                              boxShadow: isRevealed
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(1, 2),
                                        blurRadius: 2,
                                      )
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
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildCellContent(MineCell cell) {
    if (cell.state == CellState.flagged) {
      return const Icon(Icons.flag, color: NumbersColors.countdown, size: 16)
          .animate().scale(duration: 200.ms, curve: Curves.easeOutBack);
    }

    if (cell.state == CellState.revealed) {
      if (cell.isMine) {
        return const Icon(Icons.brightness_7_outlined, color: Colors.orange, size: 18);
      }
      if (cell.neighborMines > 0) {
        return Text(
          '${cell.neighborMines}',
          style: GoogleFonts.inter(
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
