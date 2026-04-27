import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/core/game_model.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: game.accentColor, // NYT uses solid block colors
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: context.shadow, // Hard text/border matching shadow
              blurRadius: 0,
              offset: const Offset(4, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surface, // Container to pop out icon
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.border, width: 2), // Thick inner border
                    ),
                    child: Icon(game.icon, color: context.onSurface, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    game.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: context.onSurface,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.description,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: context.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isDailyDone)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: NumbersColors.crossCorrect,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.border, width: 2),
                  ),
                  child: Icon(Icons.check, color: context.onSurface, size: 12),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
