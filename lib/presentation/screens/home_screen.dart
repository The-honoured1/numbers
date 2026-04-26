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

  String get _formattedDate {
    final now = DateTime.now();
    final months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    final days = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    return "${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}";
  }

  int get _completedDailies {
    return _games.where((g) => _storage.isDailyCompleted(g.id)).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NumbersColors.backgroundOffWhite,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.blur_on, color: NumbersColors.textBody, size: 28),
                        Text(
                          'numbers',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 38, letterSpacing: -1),
                        ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                        GestureDetector(
                          onTap: _showStats,
                          child: const Icon(Icons.bar_chart_rounded, color: NumbersColors.textBody, size: 28),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: NumbersColors.border, thickness: 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formattedDate,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${_storage.currentStreak}',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    if (_completedDailies > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TODAY\'S PROGRESS', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: NumbersColors.textFaint)),
                                Text('$_completedDailies/${_games.length}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: _completedDailies / _games.length,
                                minHeight: 4,
                                backgroundColor: NumbersColors.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(NumbersColors.textBody),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => _dailyGame.screen!),
                      ).then((_) => setState(() {})),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: NumbersColors.border, width: 2),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 15)),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 140,
                              width: double.infinity,
                              color: _dailyGame.accentColor.withOpacity(0.1),
                              child: Center(
                                child: Icon(_dailyGame.icon, size: 64, color: _dailyGame.accentColor.withOpacity(0.5)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: _dailyGame.accentColor, borderRadius: BorderRadius.circular(20)),
                                        child: Text('DAILY PUZZLE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                                      ),
                                      const Spacer(),
                                      if (_storage.isDailyCompleted(_dailyGame.id))
                                        const Icon(Icons.check_circle_rounded, color: NumbersColors.crossCorrect, size: 24),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(_dailyGame.title.toUpperCase(), style: GoogleFonts.lora(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1)),
                                  const SizedBox(height: 4),
                                  Text(_dailyGame.description.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: NumbersColors.textFaint, letterSpacing: 1)),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {}, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: NumbersColors.textBody,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                      child: Text(
                                        _storage.isDailyCompleted(_dailyGame.id) ? 'REPLAY CHALLENGE' : 'START PUZZLE',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).moveY(begin: 30, end: 0, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Text('BROWSE ALL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: NumbersColors.textFaint)),
                      const Spacer(),
                      const Icon(Icons.sort, size: 16, color: NumbersColors.textFaint),
                    ],
                  ),
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
                  childAspectRatio: 0.82,
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
                    ).animate().fadeIn(delay: (index * 50 + 600).ms, duration: 400.ms);
                  },
                  childCount: _games.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
