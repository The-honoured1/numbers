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


import 'package:numbers/presentation/screens/level_select_screen.dart';
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
    final cw = GameModel(id: 'crossword', title: 'Math Cross', description: 'Cross-Equation Solver', icon: Icons.grid_goldenratio_rounded, accentColor: NumbersColors.crossword);
    final lk = GameModel(id: 'link', title: 'Number Link', description: 'Connect Matching Dots', icon: Icons.link_rounded, accentColor: NumbersColors.linkNumbers);
    final ms = GameModel(id: 'minesweeper', title: 'Minesweeper', description: 'Navigate the Minefield', icon: Icons.brightness_7_rounded, accentColor: NumbersColors.minesweeper);

    return [
      GameModel(id: 'sudoku', title: 'Number Grid', description: 'Classic Sudoku Challenge', icon: Icons.grid_4x4_rounded, accentColor: NumbersColors.yellow, screen: const SudokuScreen(difficulty: 'Medium')),
      GameModel(id: '2048', title: '2048', description: 'Merge Tiles to Win', icon: Icons.dashboard_rounded, accentColor: NumbersColors.blue, screen: const Screen2048()),
      GameModel(id: 'math_puzzle', title: 'Math Puzzle', description: 'Quick Mental Math', icon: Icons.calculate_rounded, accentColor: NumbersColors.green, screen: const PuzzleScreen()),
      GameModel(id: 'sequence', title: 'Sequence', description: 'Find Missing Patterns', icon: Icons.trending_up_rounded, accentColor: NumbersColors.purple, screen: const SequenceScreen()),
      GameModel(id: 'countdown', title: 'Countdown', description: 'Reach the Target Number', icon: Icons.timer_rounded, accentColor: NumbersColors.countdown, screen: const CountdownScreen()),

      GameModel(id: 'slide_15', title: 'Slide 15', description: 'Classic 15 Puzzle', icon: Icons.filter_4_rounded, accentColor: NumbersColors.purple, screen: const SlideScreen()),
      GameModel(id: 'zen_ascend', title: 'Zen Ascend', description: 'Speed Ascending Tap', icon: Icons.keyboard_double_arrow_up_rounded, accentColor: NumbersColors.green, screen: const AscendScreen()),
      
      GameModel(id: cw.id, title: cw.title, description: cw.description, icon: cw.icon, accentColor: cw.accentColor, screen: LevelSelectScreen(
        game: cw, screenBuilder: (l) => CrosswordScreen(initialLevel: l), maxUnlockedResolver: (s) => s.getHighScore('crossword_level'), totalLevels: 100)),
      
      GameModel(id: lk.id, title: lk.title, description: lk.description, icon: lk.icon, accentColor: lk.accentColor, screen: LevelSelectScreen(
        game: lk, screenBuilder: (l) => LinkNumbersScreen(initialLevel: l), maxUnlockedResolver: (s) => s.getHighScore('link_level'), totalLevels: 100)),
      
      GameModel(id: ms.id, title: ms.title, description: ms.description, icon: ms.icon, accentColor: ms.accentColor, screen: LevelSelectScreen(
        game: ms, screenBuilder: (l) => MinesweeperScreen(initialLevel: l + 1), maxUnlockedResolver: (s) => s.getHighScore('minesweeper_level') - 1, totalLevels: 500)),
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
      backgroundColor: context.surface,
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
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: context.shadow,
              blurRadius: 0,
              offset: Offset(4, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: context.surface,
            elevation: 0,
            selectedItemColor: NumbersColors.blue,
            unselectedItemColor: context.textFaint,
            selectedLabelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
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
    return RepaintBoundary(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.blur_on, color: context.onSurface, size: 32),
                  Text('The Numbers Games', style: GoogleFonts.unifrakturMaguntia(fontSize: 26, fontWeight: FontWeight.w700, color: context.onSurface)),
                  IconButton(
                    icon: Icon(
                      StorageService().themeNotifier.value == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: context.onSurface,
                      size: 28,
                    ),
                    onPressed: () {
                      final current = StorageService().themeNotifier.value;
                      if (current == ThemeMode.dark) {
                        StorageService().setThemeMode(ThemeMode.light);
                      } else {
                        StorageService().setThemeMode(ThemeMode.dark);
                      }
                    },
                  ),
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
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2, color: context.textFaint),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => dailyGame.screen!)),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: dailyGame.accentColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.border, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: context.shadow,
                              blurRadius: 0,
                              offset: Offset(8, 8),
                            )
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned(
                              right: -50,
                              top: -50,
                              child: Icon(dailyGame.icon, size: 250, color: context.onSurface.withOpacity(0.1)),
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
                                          color: context.surface,
                                          border: Border.all(color: context.border, width: 2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text('DAILY PUZZLE', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: context.onSurface, letterSpacing: 1.5)),
                                      ),
                                      const Spacer(),

                                    ],
                                  ),
                                  const SizedBox(height: 60),
                                  Text(
                                    dailyGame.title,
                                    style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.w900, height: 1.0, color: context.onSurface, letterSpacing: -1),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dailyGame.description.toUpperCase(),
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: context.onSurface.withOpacity(0.8), letterSpacing: 1.5),
                                  ),
                                  const SizedBox(height: 32),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                      color: context.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: context.border, width: 2.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      storage.isDailyCompleted(dailyGame.id) ? 'REPLAY CHALLENGE' : 'PLAY NOW',
                                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: context.onSurface, letterSpacing: 1),
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
                    _buildStreakCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: context.shadow,
            blurRadius: 0,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NumbersColors.yellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bolt_rounded, color: NumbersColors.yellow, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CURRENT STREAK", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: context.textFaint)),
                Text("${storage.currentStreak} DAYS", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: context.onSurface)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.textFaint),
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
    return RepaintBoundary(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('The Hub', style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1, color: context.onSurface)),
                    const SizedBox(height: 4),
                    Text('CHOOSE YOUR DAILY BRAIN WORKOUT', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: context.onSurface.withOpacity(0.6))),
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
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  final StorageService storage;
  const _StatsView({required this.storage});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('Progress', style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1, color: context.onSurface)),
              ),
              
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
                    Icon(Icons.bolt_rounded, color: context.surface, size: 80)
                      .animate()
                      .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut),
                    const SizedBox(height: 16),
                    Text('${storage.currentStreak}', style: GoogleFonts.outfit(fontSize: 72, fontWeight: FontWeight.w900, height: 1, color: context.surface)),
                    Text('DAY STREAK', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3, color: context.surface.withOpacity(0.9))),
                    const SizedBox(height: 32),
                    _buildWeeklyTrack(context),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
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
                child: Text('HIGHEST SCORES', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: context.textFaint)),
              ),
              const SizedBox(height: 16),
              _buildHighScoreList(context),
              
              const SizedBox(height: 40),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text('KEY METRICS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: context.textFaint)),
              ),
              const SizedBox(height: 16),
              _buildMetricsTable(context),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighScoreList(BuildContext context) {
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
            margin: const EdgeInsets.only(right: 16, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.border, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: context.shadow,
                  blurRadius: 0,
                  offset: Offset(4, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Text(game['name'] as String, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: context.onSurface)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: game['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.border, width: 2),
                  ),
                  child: Text('$score', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: context.onSurface)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyTrack(BuildContext context) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.asMap().entries.map((e) {
        final date = e.value;
        final isCompleted = storage.anyDailyCompleted(date);
        
        return Expanded(
          child: Column(
            children: [
              FittedBox(child: Text(labels[date.weekday % 7], style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: context.onSurface.withOpacity(0.6)))),
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 46,
                decoration: BoxDecoration(
                  color: isCompleted ? NumbersColors.green : context.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.border, width: 2),
                  boxShadow: [
                    BoxShadow(color: context.shadow, blurRadius: 0, offset: Offset(2, 2))
                  ],
                ),
                child: isCompleted 
                  ? Icon(Icons.check_rounded, color: context.onSurface, size: 24) 
                  : Center(child: Text('${date.day}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: context.onSurface))),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsTable(BuildContext context) {
    final totalPlays = storage.gamesPlayed;
    final totalTime = storage.getTotalPlayTime();
    final avgSession = totalPlays > 0 ? (totalTime / totalPlays).round() : 0;
    final favorite = storage.getFavoriteGame();

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border, width: 2.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.shadow,
            blurRadius: 0,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _metricRow(context, "TOTAL PLAY TIME", StorageService.formatDuration(totalTime), NumbersColors.purple),
          Divider(height: 32, color: context.border, thickness: 2.5),
          _metricRow(context, "AVG SESSION", StorageService.formatDuration(avgSession), NumbersColors.blue),
          Divider(height: 32, color: context.border, thickness: 2.5),
          _metricRow(context, "FAVORITE GAME", favorite, NumbersColors.yellow),
        ],
      ),
    );
  }

  Widget _metricRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label, 
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.textFaint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: context.onSurface)),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.shadow,
            blurRadius: 0,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.border, width: 1.5)),
            child: Icon(icon, color: context.onSurface, size: 20),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: context.onSurface)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label, 
              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: context.textFaint),
            ),
          ),
        ],
      ),
    );
  }
}
