import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/services/storage_service.dart';

class TutorialDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const TutorialDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: context.shadow,
              blurRadius: 0,
              offset: const Offset(8, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: context.onSurface),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: context.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              description,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textFaint,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.onSurface,
                foregroundColor: context.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.surface, width: 2),
                ),
                elevation: 0,
              ),
              child: Text(
                'PLAY NOW',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> checkAndShow({
    required BuildContext context, 
    required String gameId, 
    required String title, 
    required String description, 
    required IconData icon,
  }) async {
    final storage = StorageService();
    if (!storage.hasSeenTutorial(gameId)) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TutorialDialog(title: title, description: description, icon: icon),
      );
      await storage.setTutorialSeen(gameId);
    }
  }
}
