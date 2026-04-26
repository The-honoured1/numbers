import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';

class WinDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onHome;
  final VoidCallback? onNext;

  const WinDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onHome,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey.shade100, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NumbersColors.sudoku.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: Colors.orange, size: 64),
            ).animate()
             .scale(duration: 600.ms, curve: Curves.elasticOut)
             .shake(delay: 500.ms),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: NumbersColors.textBody,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: NumbersColors.textFaint,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onHome,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
                if (onNext != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NumbersColors.textBody,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Play Again'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.backOut),
    );
  }
}
