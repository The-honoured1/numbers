import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';

class GameResultDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback? onRevive;
  final String reviveButtonText;
  final IconData icon;
  final Color color;

  const GameResultDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'CONTINUE',
    required this.onButtonPressed,
    this.onRevive,
    this.reviveButtonText = 'WATCH AD TO REVIVE',
    this.icon = Icons.check_circle_outline,
    this.color = NumbersColors.crossCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: NumbersColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 48),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: NumbersColors.textBody,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: NumbersColors.textFaint,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (onRevive != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRevive,
                  icon: const Icon(Icons.play_circle_fill, size: 20),
                  label: Text(
                    reviveButtonText,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NumbersColors.textBody,
                    side: const BorderSide(color: NumbersColors.border, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NumbersColors.textBody,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutQuad);
  }
}
