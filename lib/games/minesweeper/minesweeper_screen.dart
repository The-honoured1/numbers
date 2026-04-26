import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'minesweeper_logic.dart';

class MinesweeperScreen extends StatefulWidget {
  const MinesweeperScreen({super.key});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreenState();
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  late MinesweeperGame _game;
  bool _flagMode = false;
  final int _rows = 10;
  final int _cols = 8;
  final int _mines = 10;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    StorageService().incrementPlayCount('minesweeper');
    setState(() {
      _game = MinesweeperGame(rows: _rows, cols: _cols, mineCount: _mines);
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
        title: won ? 'Board Cleared!' : 'Kaboom!',
        message: won 
            ? 'You avoided all mines with precision. Masterful work!' 
            : 'You hit a mine. The grid was a little too hot today.',
        buttonText: won ? 'NEXT PUZZLE' : 'TRY AGAIN',
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
                    Text('$_mines', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900)),
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
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: _cols / _rows,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: NumbersColors.border, width: 2),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _cols,
                      ),
                      itemCount: _rows * _cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ _cols;
                        int c = index % _cols;
                        final cell = _game.board[r][c];
                        
                        return GestureDetector(
                          onTap: () => _handleCellTap(r, c),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cell.state == CellState.revealed 
                                  ? (cell.isMine ? Colors.red.withOpacity(0.1) : Colors.grey.shade100)
                                  : Colors.white,
                              border: Border.all(color: NumbersColors.border, width: 0.5),
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
