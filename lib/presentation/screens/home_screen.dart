import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import '../../core/game_model.dart';
import '../../services/storage_service.dart';
import '../widgets/game_card.dart';

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
        accentColor: NumeriaColors.sudoku,
      ),
      GameModel(
        id: '2048',
        title: '2048',
        description: 'Slide tiles to reach 2048.',
        icon: Icons.apps,
        accentColor: NumeriaColors.game2048,
      ),
      GameModel(
        id: 'math_puzzle',
        title: 'Math Puzzle',
        description: 'Quick math equations.',
        icon: Icons.calculate,
        accentColor: NumeriaColors.mathPuzzle,
      ),
      GameModel(
        id: 'sequence',
        title: 'Sequence',
        description: 'Find the missing number.',
        icon: Icons.trending_up,
        accentColor: NumeriaColors.sequence,
      ),
      GameModel(
        id: 'countdown',
        title: 'Countdown',
        description: 'Reach the target number.',
        icon: Icons.timer,
        accentColor: NumeriaColors.countdown,
      ),
      GameModel(
        id: 'crossword',
        title: 'Math Cross',
        description: '2D equation challenge.',
        icon: Icons.grid_on,
        accentColor: NumeriaColors.crossword,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Numeria',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${_storage.getStreak()} Day Streak',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sharpen your mind daily.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = _games[index];
                    return GameCard(
                      game: game,
                      isDailyDone: _storage.isDailyDone(game.id),
                      onTap: () {
                        // Navigation will be added as games are implemented
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${game.title} coming soon!')),
                        );
                      },
                    );
                  },
                  childCount: _games.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
