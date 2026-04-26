import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;
  final bool isDailyDone;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.isDailyDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(color: game.accentColor, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: game.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(game.icon, color: game.accentColor, size: 32),
                  ),
                  if (isDailyDone)
                    const Icon(Icons.check_circle, color: NumeriaColors.crossCorrect, size: 24)
                        .animate()
                        .scale(duration: 300.ms),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                game.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  game.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 100.ms).moveY(begin: 20, end: 0),
    );
  }
}
