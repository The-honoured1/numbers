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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          // System request to exit
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.surface,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _TodayView(dailyGame: _dailyGame, storage: _storage, date: _formattedDate),
            _HubView(games: _games, storage: _storage),
            _StatsView(games: _games, storage: _storage),
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
    ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.border, width: 2),
        ),
        title: Text('Leave so soon?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: context.onSurface)),
        content: Text('Are you sure you want to exit the game? Your daily streak is waiting!', style: GoogleFonts.outfit(color: context.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('STAY', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: NumbersColors.green)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('EXIT', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: context.textFaint)),
          ),
        ],
      ),
    ) ?? false;
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
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('The Numbers Games', style: GoogleFonts.unifrakturMaguntia(fontSize: 26, fontWeight: FontWeight.w700, color: context.onSurface)),
                    ),
                  ),
                  const SizedBox(width: 32),
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
                    const SizedBox(height: 100),
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
  final List<GameModel> games;
  final StorageService storage;
  const _StatsView({required this.games, required this.storage});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('The Archives', style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: context.onSurface, height: 1)),
              const SizedBox(height: 8),
              Text('YOUR JOURNEY THROUGH THE NUMBERS', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: context.textFaint)),
              
              const SizedBox(height: 32),
              
              // Hero Stats Dashboard
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.border, width: 3),
                  boxShadow: [
                    BoxShadow(color: context.shadow, offset: const Offset(6, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: context.onSurface, size: 48),
                    const SizedBox(height: 16),
                    Text('${storage.getTotalWins()}', style: GoogleFonts.playfairDisplay(fontSize: 64, fontWeight: FontWeight.w900, height: 1, color: context.onSurface)),
                    const SizedBox(height: 4),
                    Text('PUZZLES SOLVED', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: context.textFaint, letterSpacing: 2)),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _heroMiniStat('PLAY TIME', StorageService.formatDuration(storage.getTotalPlayTime()), context),
                        Container(width: 2, height: 30, color: context.border.withOpacity(0.2)),
                        _heroMiniStat('BEST STREAK', '${storage.maxStreak} DAYS', context),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              
              // Activity Section
              _SectionHeader(title: 'LAST 7 DAYS', subtitle: 'DAILY CHALLENGE COMPLETION'),
              const SizedBox(height: 16),
              _buildWeeklyTrack(context),
              
              const SizedBox(height: 48),

              _SectionHeader(title: 'GAME BREAKDOWN', subtitle: 'TAPPING INTO YOUR DATA'),
              const SizedBox(height: 16),
              _buildDetailedGameList(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyTrack(BuildContext context) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final labels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border, width: 2.5),
        boxShadow: [
          BoxShadow(color: context.shadow, offset: const Offset(4, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.asMap().entries.map((e) {
          final date = e.value;
          final isCompleted = storage.anyDailyCompleted(date);
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
          
          return Column(
            children: [
              Text(
                labels[date.weekday % 7], 
                style: GoogleFonts.outfit(
                  fontSize: 9, 
                  fontWeight: FontWeight.w800, 
                  color: isToday ? NumbersColors.blue : context.textFaint,
                  letterSpacing: 0.5,
                )
              ),
              const SizedBox(height: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? NumbersColors.green : (isToday ? context.surface : context.surface.withOpacity(0.5)),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.border, width: 2),
                ),
                child: isCompleted 
                  ? Icon(Icons.check_rounded, color: context.onSurface, size: 18) 
                  : Center(
                      child: Text(
                        '${date.day}', 
                        style: GoogleFonts.outfit(
                          fontSize: 10, 
                          fontWeight: FontWeight.w900, 
                          color: isToday ? NumbersColors.blue : context.textFaint.withOpacity(0.5)
                        )
                      )
                    ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _heroMiniStat(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: context.onSurface)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint)),
      ],
    );
  }

  Widget _buildDetailedGameList(BuildContext context) {
    return Column(
      children: games.map((game) {
        final score = storage.getHighScore(game.id);
        final wins = storage.getWins(game.id);
        final time = storage.getPlayTime(game.id);
        final plays = storage.getPlayCount(game.id);

        if (plays == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border, width: 2.5),
            boxShadow: [
              BoxShadow(color: context.shadow, offset: const Offset(4, 4))
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: game.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: game.accentColor.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(game.icon, color: game.accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: game.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('WINS: $wins', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: game.accentColor)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat(context, 'BEST SCORE', score == 0 ? '-' : '$score', game.accentColor),
                  _miniStat(context, 'TOTAL PLAYS', '$plays', context.onSurface),
                  _miniStat(context, 'PLAY TIME', StorageService.formatDuration(time), context.onSurface),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _miniStat(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: context.onSurface)),
        const SizedBox(height: 2),
        Text(subtitle, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 1)),
      ],
    );
  }
}

class _StatDashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;

  const _StatDashboardCard({
    required this.label, 
    required this.value, 
    required this.subValue, 
    required this.icon, 
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border, width: 2.5),
        boxShadow: [
          BoxShadow(color: context.shadow, offset: const Offset(4, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: context.textFaint, letterSpacing: 1)),
               Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 4),
          Text(subValue, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
        ],
      ),
    );
  }
}
