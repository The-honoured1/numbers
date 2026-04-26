import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/core/game_model.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/presentation/widgets/game_card.dart';
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
  int _selectedIndex = 0;
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
      GameModel(id: 'sudoku', title: 'Number Grid', description: 'Classic Sudoku', icon: Icons.grid_4x4, accentColor: NumbersColors.sudoku, screen: const SudokuScreen(difficulty: 'Medium')),
      GameModel(id: '2048', title: '2048', description: 'Merge Tiles', icon: Icons.apps, accentColor: NumbersColors.game2048, screen: const Screen2048()),
      GameModel(id: 'math_puzzle', title: 'Math Puzzle', description: 'Quick Equations', icon: Icons.calculate, accentColor: NumbersColors.mathPuzzle, screen: const PuzzleScreen()),
      GameModel(id: 'sequence', title: 'Sequence', description: 'Find Patterns', icon: Icons.trending_up, accentColor: NumbersColors.sequence, screen: const SequenceScreen()),
      GameModel(id: 'countdown', title: 'Countdown', description: 'Target Search', icon: Icons.timer, accentColor: NumbersColors.countdown, screen: const CountdownScreen()),
      GameModel(id: 'crossword', title: 'Math Cross', description: '2D Equations', icon: Icons.grid_on, accentColor: NumbersColors.crossword, screen: const CrosswordScreen()),
      GameModel(id: 'link', title: 'Number Link', description: 'Dot Connection', icon: Icons.gesture, accentColor: NumbersColors.linkNumbers, screen: const LinkNumbersScreen()),
      GameModel(id: 'minesweeper', title: 'Minesweeper', description: 'Flag the Gems', icon: Icons.brightness_7_outlined, accentColor: NumbersColors.minesweeper, screen: const MinesweeperScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NumbersColors.backgroundOffWhite,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _TodayView(dailyGame: _dailyGame, storage: _storage),
          _HubView(games: _games, storage: _storage),
          _StatsView(storage: _storage),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: NumbersColors.border))),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: NumbersColors.textBody,
          unselectedItemColor: NumbersColors.textFaint,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.today), label: 'TODAY'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'PLAY'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'STATS'),
          ],
        ),
      ),
    );
  }
}

class _TodayView extends StatelessWidget {
  final GameModel dailyGame;
  final StorageService storage;

  const _TodayView({required this.dailyGame, required this.storage});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.blur_on, color: NumbersColors.textBody, size: 28),
                Text('numbers', style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
                const Icon(Icons.search, color: NumbersColors.textBody, size: 28),
              ],
            ),
          ),
          const Divider(height: 1, color: NumbersColors.border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "SUNDAY, APRIL 26",
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: NumbersColors.textFaint),
                  ),
                  const SizedBox(height: 40),
                  AspectRatio(
                    aspectRatio: 0.9,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => dailyGame.screen!)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: NumbersColors.border, width: 2),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 20))],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                color: dailyGame.accentColor.withOpacity(0.1),
                                child: Icon(dailyGame.icon, size: 100, color: dailyGame.accentColor.withOpacity(0.3)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: dailyGame.accentColor, borderRadius: BorderRadius.circular(20)),
                                        child: Text('DAILY PUZZLE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                                      ),
                                      const Spacer(),
                                      if (storage.isDailyCompleted(dailyGame.id))
                                        const Icon(Icons.check_circle_rounded, color: NumbersColors.crossCorrect, size: 28),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(dailyGame.title.toUpperCase(), style: GoogleFonts.lora(fontSize: 48, fontWeight: FontWeight.w900, height: 0.9)),
                                  const SizedBox(height: 8),
                                  Text(dailyGame.description.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: NumbersColors.textFaint, letterSpacing: 1)),
                                  const SizedBox(height: 48),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: NumbersColors.textBody,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 24),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                      child: Text(storage.isDailyCompleted(dailyGame.id) ? 'REPLAY' : 'PLAY', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms).moveY(begin: 30, end: 0, curve: Curves.easeOut),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubView extends StatelessWidget {
  final List<GameModel> games;
  final StorageService storage;

  const _HubView({required this.games, required this.storage});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              child: Text('THE HUB', style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
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
                  final game = games[index];
                  return GameCard(
                    game: game,
                    isDailyDone: storage.isDailyCompleted(game.id),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => game.screen!)),
                  );
                },
                childCount: games.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  final StorageService storage;
  const _StatsView({required this.storage});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Text('STATISTICS', style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(value: '${storage.gamesPlayed}', label: 'PLAYED'),
                _StatItem(value: '${storage.currentStreak}', label: 'STREAK'),
                _StatItem(value: '${storage.maxStreak}', label: 'MAX'),
              ],
            ),
            const SizedBox(height: 80),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: NumbersColors.border), borderRadius: BorderRadius.circular(4)),
              child: Column(
                children: [
                  Text('DAILY PROGRESS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: NumbersColors.textFaint)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, color: Colors.orange, size: 32),
                      const SizedBox(width: 12),
                      Text('YOU HAVE A ${storage.currentStreak} DAY STREAK', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w200)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: NumbersColors.textFaint, letterSpacing: 1)),
      ],
    );
  }
}
