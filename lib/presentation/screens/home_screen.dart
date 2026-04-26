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


import 'package:numbers/games/slide_15/slide_screen.dart';
import 'package:numbers/games/ascend/ascend_screen.dart';

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
      GameModel(id: 'sudoku', title: 'Number Grid', description: 'Classic Sudoku Challenge', icon: Icons.grid_4x4_rounded, accentColor: NumbersColors.yellow, screen: SudokuScreen(difficulty: 'Medium')),
      GameModel(id: '2048', title: '2048', description: 'Merge Tiles to Win', icon: Icons.dashboard_rounded, accentColor: NumbersColors.blue, screen: Screen2048()),
      GameModel(id: 'math_puzzle', title: 'Math Puzzle', description: 'Quick Mental Math', icon: Icons.calculate_rounded, accentColor: NumbersColors.green, screen: PuzzleScreen()),
      GameModel(id: 'sequence', title: 'Sequence', description: 'Find Missing Patterns', icon: Icons.trending_up_rounded, accentColor: NumbersColors.purple, screen: SequenceScreen()),
      GameModel(id: 'countdown', title: 'Countdown', description: 'Reach the Target Number', icon: Icons.timer_rounded, accentColor: NumbersColors.countdown, screen: CountdownScreen()),

      GameModel(id: 'slide_15', title: 'Slide 15', description: 'Classic 15 Puzzle', icon: Icons.filter_4_rounded, accentColor: NumbersColors.purple, screen: SlideScreen()),
      GameModel(id: 'zen_ascend', title: 'Zen Ascend', description: 'Speed Ascending Tap', icon: Icons.keyboard_double_arrow_up_rounded, accentColor: NumbersColors.green, screen: AscendScreen()),
      GameModel(id: 'crossword', title: 'Math Cross', description: 'Cross-Equation Solver', icon: Icons.grid_goldenratio_rounded, accentColor: NumbersColors.crossword, screen: CrosswordScreen()),
      GameModel(id: 'link', title: 'Number Link', description: 'Connect Matching Dots', icon: Icons.link_rounded, accentColor: NumbersColors.linkNumbers, screen: LinkNumbersScreen()),
      GameModel(id: 'minesweeper', title: 'Minesweeper', description: 'Navigate the Minefield', icon: Icons.brightness_7_rounded, accentColor: NumbersColors.minesweeper, screen: MinesweeperScreen()),
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
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: NumbersColors.purple,
            unselectedItemColor: NumbersColors.textFaint.withOpacity(0.5),
            selectedLabelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.today_rounded, size: 26), label: 'TODAY'),
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded, size: 26), label: 'PLAY'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded, size: 26), label: 'STATS'),
            ],
          ),
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
                const Icon(Icons.blur_on, color: NumbersColors.textBody, size: 32),
                Text('numbers', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                const Icon(Icons.notifications_none_rounded, color: NumbersColors.textBody, size: 28),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      date.toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2, color: NumbersColors.textFaint),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => dailyGame.screen!)),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            dailyGame.accentColor,
                            dailyGame.accentColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: dailyGame.accentColor.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned(
                            right: -50,
                            top: -50,
                            child: Icon(dailyGame.icon, size: 250, color: Colors.white.withOpacity(0.1)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('DAILY PUZZLE', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                                    ),
                                    const Spacer(),
                                    if (storage.isDailyCompleted(dailyGame.id))
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
                                  ],
                                ),
                                const SizedBox(height: 60),
                                Text(
                                  dailyGame.title,
                                  style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900, height: 1.0, color: Colors.white, letterSpacing: -1),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dailyGame.description.toUpperCase(),
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), letterSpacing: 1.5),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    storage.isDailyCompleted(dailyGame.id) ? 'REPLAY CHALLENGE' : 'PLAY NOW',
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: dailyGame.accentColor, letterSpacing: 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
                  const SizedBox(height: 32),
                  _buildStreakCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NumbersColors.backgroundOffWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NumbersColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NumbersColors.yellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: NumbersColors.yellow, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CURRENT STREAK", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: NumbersColors.textFaint)),
                Text("${storage.currentStreak} DAYS", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: NumbersColors.textBody)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: NumbersColors.textFaint),
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
                  Text('The Hub', style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const SizedBox(height: 4),
                  Text('CHOOSE YOUR DAILY BRAIN WORKOUT', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: NumbersColors.textFaint)),
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
                childAspectRatio: 0.82,
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Progress', style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
            ),
            
            // STREAK HERO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NumbersColors.yellow, Color(0xFFFFB319)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: NumbersColors.yellow.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 80)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 1000.ms),
                  const SizedBox(height: 16),
                  Text('${storage.currentStreak}', style: GoogleFonts.outfit(fontSize: 72, fontWeight: FontWeight.w900, height: 1, color: Colors.white)),
                  Text('DAY STREAK', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 32),
                  _buildWeeklyTrack(),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // MILESTONES
            Row(
              children: [
                Expanded(child: _InfoCard(label: 'ALL TIME', value: '${storage.maxStreak}', icon: Icons.emoji_events_rounded, color: NumbersColors.yellow)),
                const SizedBox(width: 16),
                Expanded(child: _InfoCard(label: 'GAMES', value: '${storage.gamesPlayed}', icon: Icons.sports_esports_rounded, color: NumbersColors.blue)),
              ],
            ),
            
            const SizedBox(height: 40),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text('HIGHEST SCORES', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: NumbersColors.textFaint)),
            ),
            const SizedBox(height: 16),
            _buildHighScoreList(),
            
            const SizedBox(height: 40),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text('KEY METRICS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: NumbersColors.textFaint)),
            ),
            const SizedBox(height: 16),
            _buildMetricsTable(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHighScoreList() {
    final games = [
      {'id': 'sudoku', 'name': 'Sudoku', 'color': NumbersColors.yellow},
      {'id': '2048', 'name': '2048', 'color': NumbersColors.blue},
      {'id': 'math_puzzle', 'name': 'Math', 'color': NumbersColors.green},
      {'id': 'sequence', 'name': 'Sequence', 'color': NumbersColors.purple},
      {'id': 'countdown', 'name': 'Count', 'color': NumbersColors.countdown},
      {'id': 'crossword', 'name': 'Cross', 'color': NumbersColors.crossword},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: games.map((game) {
          final score = storage.getHighScore(game['id'] as String);
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: NumbersColors.border, width: 1.5),
            ),
            child: Column(
              children: [
                Text(game['name'] as String, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: NumbersColors.textFaint)),
                const SizedBox(height: 4),
                Text('$score', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: game['color'] as Color)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyTrack() {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.asMap().entries.map((e) {
        final date = e.value;
        final isCompleted = storage.anyDailyCompleted(date);
        final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
        
        return Column(
          children: [
            Text(labels[date.weekday % 7], style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: 12),
            Container(
              width: 32,
              height: 42,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.white : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isToday ? Colors.white : Colors.transparent, width: 2),
                boxShadow: isCompleted ? [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ] : [],
              ),
              child: isCompleted 
                ? Icon(Icons.check_rounded, color: NumbersColors.yellow, size: 20) 
                : Center(child: Text('${date.day}', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.4)))),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMetricsTable() {
    final totalWins = storage.getTotalWins();
    final totalPlays = storage.gamesPlayed;
    final accuracy = totalPlays > 0 ? (totalWins / totalPlays * 100).toStringAsFixed(0) : "0";
    final favorite = storage.getFavoriteGame();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NumbersColors.backgroundOffWhite,
        border: Border.all(color: NumbersColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _metricRow("GAME ACCURACY", "$accuracy%", NumbersColors.green),
          const Divider(height: 32, color: NumbersColors.border),
          _metricRow("FAVORITE GAME", favorite, NumbersColors.blue),
          const Divider(height: 32, color: NumbersColors.border),
          _metricRow("TOTAL WINS", "$totalWins", NumbersColors.coral),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label, 
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: NumbersColors.textFaint),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: NumbersColors.textBody)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NumbersColors.backgroundOffWhite,
        border: Border.all(color: NumbersColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: NumbersColors.textBody)),
          ),
          Text(
            label, 
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: NumbersColors.textFaint),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
