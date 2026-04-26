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
import 'package:numbers/games/link_numbers/link_numbers_screen.dart';
import 'package:numbers/games/minesweeper/minesweeper_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  late List<GameModel> _games;
  late GameModel _dailyGame;

  @override
  void initState() {
    super.initState();
    _games = _getGames();
    _dailyGame = _games[DateTime.now().day % _games.length];
  }

  List<GameModel> _getGames() {
    return [
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
      GameModel(
        id: 'link',
        title: 'Number Link',
        description: 'Connect pairs of numbers.',
        icon: Icons.gesture,
        accentColor: NumbersColors.linkNumbers,
        screen: const LinkNumbersScreen(),
      ),
      GameModel(
        id: 'minesweeper',
        title: 'Minesweeper',
        description: 'Clear the gem grid.',
        icon: Icons.brightness_7_outlined,
        accentColor: NumbersColors.minesweeper,
        screen: const MinesweeperScreen(),
      ),
    ];
  }

  void _showStats() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: NumbersColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('STATISTICS', style: GoogleFonts.inter(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('${_storage.gamesPlayed}', 'PLAYED'),
                  _statItem('${_storage.currentStreak}', 'STREAK'),
                  _statItem('${_storage.maxStreak}', 'MAX STREAK'),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: NumbersColors.textBody,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('BACK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w200)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: NumbersColors.textFaint)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NumbersColors.backgroundOffWhite,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.menu, color: NumbersColors.textBody),
                        Text(
                          'numbers',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                        ).animate().fadeIn(duration: 800.ms),
                        GestureDetector(
                          onTap: _showStats,
                          child: const Icon(Icons.bar_chart, color: NumbersColors.textBody),
                        ),
                      ],
                    ),
                    const Divider(height: 40, color: NumbersColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SUNDAY, APRIL 26',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${_storage.currentStreak}',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // DAILY CHALLENGE HERO
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => _dailyGame.screen!),
                      ).then((_) => setState(() {})),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _dailyGame.accentColor.withOpacity(0.1),
                          border: Border.all(color: _dailyGame.accentColor.withOpacity(0.3), width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: _dailyGame.accentColor, borderRadius: BorderRadius.circular(2)),
                                  child: Text('DAILY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                                ),
                                const SizedBox(width: 8),
                                if (_storage.isDailyCompleted(_dailyGame.id))
                                  const Icon(Icons.check_circle, color: NumbersColors.crossCorrect, size: 16),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(_dailyGame.title, style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w800)),
                            Text(_dailyGame.description, style: GoogleFonts.inter(fontSize: 14, color: NumbersColors.textFaint)),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () {}, // Handled by parent detector
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NumbersColors.textBody,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(_storage.isDailyCompleted(_dailyGame.id) ? 'REPLAY' : 'PLAY', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('MORE PUZZLES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: NumbersColors.textFaint)),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = _games[index];
                    return GameCard(
                      game: game,
                      isDailyDone: _storage.isDailyCompleted(game.id),
                      onTap: () {
                        if (game.screen != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => game.screen!),
                          ).then((_) => setState(() {}));
                        }
                      },
                    ).animate().fadeIn(delay: (index * 50 + 500).ms, duration: 400.ms);
                  },
                  childCount: _games.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }
}
