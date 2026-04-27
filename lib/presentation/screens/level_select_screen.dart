import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/core/game_model.dart';
import 'package:numbers/services/storage_service.dart';

class LevelSelectScreen extends StatelessWidget {
  final GameModel game;
  final Widget Function(int level) screenBuilder;
  final int Function(StorageService) maxUnlockedResolver;
  final int totalLevels;

  const LevelSelectScreen({
    super.key,
    required this.game,
    required this.screenBuilder,
    required this.maxUnlockedResolver,
    required this.totalLevels,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final maxUnlocked = maxUnlockedResolver(storage).clamp(0, totalLevels - 1);

    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text(game.title.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Text(
              'SELECT A LEVEL',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: context.textFaint,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: totalLevels,
                itemBuilder: (context, index) {
                  final unlocked = index <= maxUnlocked;
                  return GestureDetector(
                    onTap: unlocked 
                        ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screenBuilder(index)))
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: unlocked ? game.accentColor : context.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: unlocked ? context.border : context.textFaint.withOpacity(0.3),
                          width: 2.5,
                        ),
                        boxShadow: unlocked ? [
                          BoxShadow(
                            color: context.shadow,
                            blurRadius: 0,
                            offset: const Offset(3, 3),
                          )
                        ] : [],
                      ),
                      alignment: Alignment.center,
                      child: unlocked
                        ? Text('${index + 1}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: context.onSurface))
                        : Icon(Icons.lock_rounded, color: context.textFaint.withOpacity(0.5), size: 20),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
