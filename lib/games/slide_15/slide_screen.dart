import 'package:numbers/presentation/widgets/tutorial_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'slide_logic.dart';

class SlideScreen extends StatefulWidget {
  const SlideScreen({super.key});

  @override
  State<SlideScreen> createState() => _SlideScreenState();
}

class _SlideScreenState extends State<SlideScreen> {
  final SlideLogic _logic = SlideLogic();
  late List<int> _grid;
  int _moves = 0;
  final Stopwatch _sessionTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _grid = _logic.generate();
    _sessionTimer.start();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: 'slide_15',
        title: 'Slide 15',
        description: 'Slide the tiles into the empty space to arrange them in numerical order from 1 to 15.',
        icon: Icons.filter_4_rounded,
      );
    });
  }

  @override
  void dispose() {
    _sessionTimer.stop();
    StorageService().addPlayTime('slide_15', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _startNewGame() {
    StorageService().incrementPlayCount('slide_15');
    setState(() {
      _grid = _logic.generate();
      _moves = 0;
    });
  }

  void _moveTile(int index) {
    if (_logic.canMove(index, _grid)) {
      setState(() {
        int emptyIdx = _grid.indexOf(0);
        _grid[emptyIdx] = _grid[index];
        _grid[index] = 0;
        _moves++;
      });
      
      if (_logic.isWin(_grid)) {
        _showWinDialog();
      }
    }
  }

  void _showWinDialog() {
    StorageService().saveHighScore('slide_15', _moves);
    StorageService().markDailyCompleted('slide_15');
    AdService().showInterstitialAd();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Perfect Alignment!',
        message: 'You solved the 15-puzzle in $_moves moves.',
        buttonText: 'NEW PUZZLE',
        color: NumbersColors.purple,
        icon: Icons.grid_view_rounded,
        onButtonPressed: () {
          Navigator.pop(context);
          _startNewGame();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('SLIDE 15', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(label: 'MOVES', value: '$_moves', color: NumbersColors.purple),
                _StatItem(label: 'BEST', value: '${StorageService().getHighScore('slide_15')}', color: context.textFaint),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.border.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    final val = _grid[index];
                    if (val == 0) return const SizedBox.shrink();
                    
                    return GestureDetector(
                      onTap: () => _moveTile(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.border, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: context.shadow,
                              offset: const Offset(3, 3),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$val',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: context.onSurface,
                          ),
                        ),
                      ).animate(key: ValueKey('tile_$val')).fadeIn().scale(),
                    );
                  },
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: TextButton(
              onPressed: _startNewGame, 
              child: Text('RESET GRID', style: GoogleFonts.outfit(color: NumbersColors.purple, fontWeight: FontWeight.w800, letterSpacing: 1.5))
            ),
          ),
        ],
      ),
    ),
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
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
