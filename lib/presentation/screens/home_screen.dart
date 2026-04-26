import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/core/game_model.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/presentation/widgets/game_card.dart';
import 'package:numbers/presentation/widgets/decorations.dart';
import 'package:numbers/games/sudoku/sudoku_screen.dart';
import 'package:numbers/games/game_2048/screen_2048.dart';
import 'package:numbers/games/math_puzzle/puzzle_screen.dart';
import 'package:numbers/games/sequence/sequence_screen.dart';
import 'package:numbers/games/countdown/countdown_screen.dart';
import 'package:numbers/games/crossword/crossword_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  
  late List<GameModel> _games;

  @override
  void initState() {
    super.initState();
    _games = [
      GameModel(
        id: 'sudoku',
        title: 'Number Grid',
        description: 'Classic 9x9 Sudoku puzzles.',
        icon: Icons.grid_4x4,
        accentColor: NumbersColors.sudoku,
        screen: const SudokuScreen(difficulty: 'Medium'),
      ),
      GameModel(
        id: '2048',
        title: '2048',
        description: 'Slide tiles to reach 2048.',
        icon: Icons.apps,
        accentColor: NumbersColors.game2048,
        screen: const Screen2048(),
      ),
      GameModel(
        id: 'math_puzzle',
        title: 'Math Puzzle',
        description: 'Quick math equations.',
        icon: Icons.calculate,
        accentColor: NumbersColors.mathPuzzle,
        screen: const PuzzleScreen(),
      ),
      GameModel(
        id: 'sequence',
        title: 'Sequence',
        description: 'Find the missing number.',
        icon: Icons.trending_up,
        accentColor: NumbersColors.sequence,
        screen: const SequenceScreen(),
      ),
      GameModel(
        id: 'countdown',
        title: 'Countdown',
        description: 'Reach the target number.',
        icon: Icons.timer,
        accentColor: NumbersColors.countdown,
        screen: const CountdownScreen(),
      ),
      GameModel(
        id: 'crossword',
        title: 'Math Cross',
        description: '2D equation challenge.',
        icon: Icons.grid_on,
        accentColor: NumbersColors.crossword,
        screen: const CrosswordScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Decorations
          Positioned.fill(
            child: CustomPaint(
              painter: DottedPathPainter(),
            ),
          ),
          const FloatingShape(color: NumbersColors.sudoku, size: 40, top: 100, left: -20, rotation: 0.5),
          const FloatingShape(color: NumbersColors.crossword, size: 30, top: 400, left: 350, rotation: -0.2),
          const FloatingShape(color: NumbersColors.game2048, size: 20, top: 600, left: 50, rotation: 0.8),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'numbers',
                          style: GoogleFonts.lora(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                            color: NumbersColors.textBody,
                          ),
                        ).animate().fadeIn(duration: 800.ms).moveY(begin: -20, end: 0, curve: Curves.easeOut),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                            color: NumbersColors.textBody,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ).animate().scaleX(delay: 400.ms, begin: 0, end: 1, curve: Curves.elasticOut),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_storage.getStreak()} DAY STREAK',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.orange.shade800,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(delay: 600.ms, curve: Curves.easeOutBack),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final game = _games[index];
                        return GameCard(
                          game: game,
                          isDailyDone: _storage.isDailyDone(game.id),
                          onTap: () {
                            if (game.screen != null) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => game.screen!,
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    var begin = const Offset(0.0, 0.05);
                                    var end = Offset.zero;
                                    var curve = Curves.easeOut;
                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(position: animation.drive(tween), child: child),
                                    );
                                  },
                                ),
                              ).then((_) => setState(() {}));
                            }
                          },
                        ).animate().fadeIn(delay: (index * 100 + 400).ms, duration: 600.ms).moveY(begin: 30, end: 0, curve: Curves.easeOutQuad);
                      },
                      childCount: _games.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
