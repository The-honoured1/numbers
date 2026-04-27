import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/services/storage_service.dart';

class TutorialScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const TutorialScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: context.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadow,
                        offset: const Offset(8, 8),
                      )
                    ],
                  ),
                  child: Icon(icon, size: 80, color: context.onSurface),
                ),
              ),
              const SizedBox(height: 60),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: context.onSurface,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textFaint,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.onSurface,
                  foregroundColor: context.surface,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'START PLAYING',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
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
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TutorialScreen(title: title, description: description, icon: icon),
        ),
      );
      await storage.setTutorialSeen(gameId);
    }
  }
}
