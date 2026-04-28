import 'package:numbers/presentation/widgets/tutorial_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/ad_service.dart';
import 'package:numbers/services/storage_service.dart';
import 'logic_2048.dart';

class Screen2048 extends StatefulWidget {
  const Screen2048({super.key});

  @override
  State<Screen2048> createState() => _Screen2048State();
}

class _Screen2048State extends State<Screen2048> {
  final Logic2048 _logic = Logic2048();
  final Stopwatch _sessionTimer = Stopwatch();
  int _revivesUsed = 0;
  Offset? _panStart;
  Offset? _panUpdate;

  @override
  void initState() {
    super.initState();
    StorageService().incrementPlayCount('2048');
    _sessionTimer.start();
    _logic.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: '2048',
        title: '2048',
        description: 'Swipe to move the tiles. When two tiles with the same number touch, they merge into one! Reach the 2048 tile to win.',
        icon: Icons.dashboard_rounded,
      );
    });
  }

  @override
  void dispose() {
    _sessionTimer.stop();
    StorageService().addPlayTime('2048', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _handleSwipe(MoveDirection dir) {
    setState(() {
      final moved = _logic.move(dir);
      if (moved) {
        if (_logic.score > StorageService().getHighScore('2048')) {
          StorageService().saveHighScore('2048', _logic.score);
        }
        if (_logic.won) _showResult(true);
        else if (_logic.over) _showResult(false);
      }
    });
  }

  void _showResult(bool won) {
    if (won) AdService().showInterstitialAd();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: won ? 'Legendary!' : 'No More Moves',
        message: won ? 'You merged your way to the 2048 tile!' : 'The grid is locked. Final Score: ${_logic.score}',
        buttonText: won ? 'PLAY AGAIN' : 'TRY AGAIN',
        color: NumbersColors.blue,
        icon: won ? Icons.emoji_events_rounded : Icons.lock_rounded,
        onRevive: won ? null : () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            setState(() {
              _revivesUsed++;
              // Simplified revive for 2048 - clear small tiles
              _logic.tiles = _logic.tiles.where((t) => t.value > 4).toList();
              _logic.over = false;
              _logic.addRandomTile();
            });
          });
        },
        onButtonPressed: () {
          Navigator.pop(context);
          setState(() => _logic.reset());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('2048', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatBox(label: 'SCORE', value: '${_logic.score}', color: NumbersColors.blue),
                  _StatBox(label: 'BEST', value: '${StorageService().getHighScore('2048')}', color: context.textFaint),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    _panStart = details.localPosition;
                  },
                  onPanUpdate: (details) {
                    _panUpdate = details.localPosition;
                  },
                  onPanEnd: (details) {
                    final vel = details.velocity.pixelsPerSecond;
                    
                    // Try displacement-based detection first
                    if (_panStart != null && _panUpdate != null) {
                      final delta = _panUpdate! - _panStart!;
                      if (delta.distance >= 20) {
                        if (delta.dx.abs() > delta.dy.abs()) {
                          if (delta.dx > 0) _handleSwipe(MoveDirection.right);
                          else _handleSwipe(MoveDirection.left);
                        } else {
                          if (delta.dy > 0) _handleSwipe(MoveDirection.down);
                          else _handleSwipe(MoveDirection.up);
                        }
                        _panStart = null;
                        _panUpdate = null;
                        return;
                      }
                    }
                    
                    // Fallback: use velocity for fast flicks
                    if (vel.dx.abs() > 100 || vel.dy.abs() > 100) {
                      if (vel.dx.abs() > vel.dy.abs()) {
                        if (vel.dx > 0) _handleSwipe(MoveDirection.right);
                        else _handleSwipe(MoveDirection.left);
                      } else {
                        if (vel.dy > 0) _handleSwipe(MoveDirection.down);
                        else _handleSwipe(MoveDirection.up);
                      }
                    }
                    
                    _panStart = null;
                    _panUpdate = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.border, width: 3),
                      boxShadow: [
                        BoxShadow(color: context.shadow, offset: const Offset(8, 8)),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cellSize = (constraints.maxWidth - (3 * 12)) / 4;
                        return Stack(
                          children: [
                            // Background Grid
                            for (int i = 0; i < 16; i++)
                              Positioned(
                                left: (i % 4) * (cellSize + 12),
                                top: (i ~/ 4) * (cellSize + 12),
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: context.border.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            // Animated Tiles
                            ..._logic.tiles.map((tile) {
                              return AnimatedPositioned(
                                key: ValueKey(tile.id),
                              duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                left: tile.col * (cellSize + 12),
                                top: tile.row * (cellSize + 12),
                                child: _TileWidget(tile: tile, size: cellSize),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'SWIPE TO MERGE TILES',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.textFaint,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileWidget extends StatelessWidget {
  final Tile2048 tile;
  final double size;

  const _TileWidget({required this.tile, required this.size});

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFFE2E8F0);
      case 4: return const Color(0xFFCBD5E1);
      case 8: return const Color(0xFF94A3B8);
      case 16: return const Color(0xFF64748B);
      case 32: return const Color(0xFF475569);
      case 64: return const Color(0xFF334155);
      case 128: return const Color(0xFF1E293B);
      case 256: return const Color(0xFF0F172A);
      case 512: return const Color(0xFF020617);
      case 1024: return const Color(0xFFEAB308);
      case 2048: return const Color(0xFFFACC15);
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTileColor(tile.value);
    final isDark = tile.value > 8;

    Widget tileWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(2, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            '${tile.value}',
            style: GoogleFonts.outfit(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );

    if (tile.isMerged) {
      return TweenAnimationBuilder<double>(
        key: ValueKey('merge_${tile.id}'),
        tween: Tween(begin: 1.15, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: tileWidget,
      );
    }

    return tileWidget;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 2.5),
        boxShadow: [
          BoxShadow(color: context.shadow, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 1.5)),
          Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
