import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'dart:io';

class FullScreenResult extends StatelessWidget {
  final bool won;
  final String title;
  final String message;
  final String score;
  final VoidCallback onAction;
  final String actionLabel;
  final String gameId;

  const FullScreenResult({
    super.key,
    required this.won,
    required this.title,
    required this.message,
    required this.score,
    required this.onAction,
    required this.actionLabel,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // We use the generated image path. In a real app, this would be an asset.
    // For this environment, we'll try to find the generated image or use a placeholder styled container.
    final accentColor = won ? NumbersColors.green : NumbersColors.coral;

    return Scaffold(
      backgroundColor: context.surface,
      body: Stack(
        children: [
          // Background Celebration Design (Styled container as fallback for image)
          Positioned.fill(
            child: Opacity(
              opacity: won ? 0.3 : 0.1,
              child: _buildBackground(context),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Visual Trophy / Failure Icon
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.border, width: 3),
                      boxShadow: [
                        BoxShadow(color: context.shadow, offset: const Offset(8, 8))
                      ],
                    ),
                    child: Icon(
                      won ? Icons.emoji_events_rounded : Icons.timer_off_rounded,
                      color: Colors.white,
                      size: 80,
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 48),
                  
                  Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: context.onSurface,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.border, width: 1.5),
                    ),
                    child: Text(
                      'SCORE: $score',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 32),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: context.textFaint,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const Spacer(),
                  
                  // Primary Action Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: context.shadow, offset: const Offset(6, 6))
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: context.border, width: 2.5),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        actionLabel.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).moveY(begin: 40, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CLOSE ARCHIVE',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: context.textFaint,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    if (won) {
       return Center(
         child: Wrap(
           spacing: 40,
           runSpacing: 40,
           children: List.generate(20, (i) => Icon(
             i % 2 == 0 ? Icons.star_rounded : Icons.circle,
             size: 40 + (i % 5) * 10.0,
             color: i % 3 == 0 ? NumbersColors.yellow : (i % 3 == 1 ? NumbersColors.blue : NumbersColors.purple),
           ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 20, duration: (1000 + i * 100).ms, curve: Curves.easeInOut)),
         ),
       );
    } else {
       return Container(
         decoration: BoxDecoration(
           color: NumbersColors.coral.withOpacity(0.05),
         ),
         child: GridView.builder(
           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
           itemCount: 50,
           itemBuilder: (c, i) => Icon(
             Icons.close,
             color: context.border.withOpacity(0.05),
             size: 40,
           ).animate(onPlay: (c) => c.repeat()).shake(duration: 2000.ms),
         ),
       );
    }
  }
}
