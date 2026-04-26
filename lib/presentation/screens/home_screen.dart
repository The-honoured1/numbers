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

  String get _formattedDate {
    final now = DateTime.now();
    final months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    final days = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    return "${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NumbersColors.backgroundOffWhite,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _TodayView(dailyGame: _dailyGame, storage: _storage, date: _formattedDate),
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
  final String date;

  const _TodayView({required this.dailyGame, required this.storage, required this.date});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.blur_on, color: NumbersColors.textBody, size: 28),
                Text('numbers', style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
                const SizedBox(width: 28), // Spacer to balance icons
              ],
            ),
          ),
          const Divider(height: 1, color: NumbersColors.border),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Text(
                    date,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: NumbersColors.textFaint),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => dailyGame.screen!)),
                    child: Container(
                      width: double.infinity,
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
                          Container(
                            height: 160,
                            width: double.infinity,
                            color: dailyGame.accentColor.withOpacity(0.05),
                            child: Icon(dailyGame.icon, size: 64, color: dailyGame.accentColor.withOpacity(0.3)),
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
                                      decoration: BoxDecoration(color: dailyGame.accentColor, borderRadius: BorderRadius.circular(2)),
                                      child: Text('DAILY PUZZLE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                                    ),
                                    const Spacer(),
                                    if (storage.isDailyCompleted(dailyGame.id))
                                      const Icon(Icons.check_circle_rounded, color: NumbersColors.crossCorrect, size: 24),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  dailyGame.title.toUpperCase(),
                                  style: GoogleFonts.lora(fontSize: 28, fontWeight: FontWeight.w900, height: 1.0),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dailyGame.description.toUpperCase(),
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: NumbersColors.textFaint, letterSpacing: 1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => dailyGame.screen!)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: NumbersColors.textBody,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Text(storage.isDailyCompleted(dailyGame.id) ? 'REPLAY' : 'START NOW', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 48),
                  _buildMiniProgress(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NumbersColors.backgroundOffWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: NumbersColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.orange, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CURRENT STREAK", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: NumbersColors.textFaint)),
                Text("${storage.currentStreak} DAYS", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
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
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THE HUB', style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Text('EXPLORE THE FULL PUZZLE COLLECTION', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: NumbersColors.textFaint)),
                ],
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
      child: SingleChildScrollView(
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
            const SizedBox(height: 60),
            const Divider(color: NumbersColors.border),
            const SizedBox(height: 40),
            _buildStatList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatList() {
    return Column(
      children: [
        _statRow("DAILY COMPLETIONS", "75%"),
        _statRow("AVERAGE TIME", "4:12"),
        _statRow("PUZZLES SHARED", "12"),
        _statRow("ACCURACY", "92%"),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: NumbersColors.textFaint, letterSpacing: 1)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900)),
        ],
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
        Text(value, style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w200)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: NumbersColors.textFaint, letterSpacing: 1)),
      ],
    );
  }
}
