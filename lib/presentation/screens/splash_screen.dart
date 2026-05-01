import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/screens/home_screen.dart';
import 'package:numbers/services/ad_service.dart';
import 'package:numbers/services/notification_service.dart';
import 'package:numbers/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    unawaited(_initializeService('ads', () => AdService().init()));
    unawaited(
      _initializeService('notifications', () => NotificationService().init()),
    );

    await Future.wait<void>([
      StorageService().init(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<void> _initializeService(
    String name,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize $name: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NumbersColors.blue,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'numbers',
                  style: GoogleFonts.unifrakturMaguntia(
                    fontSize: 64,
                    color: Colors.white,
                  ),
                ).animate().slideY(begin: 0.1, end: 0, duration: 800.ms),

                const SizedBox(height: 16),

                Text(
                  'MADE BY JIGGY GAMES',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                const SizedBox(height: 48),

                // Loading indicator
                SizedBox(
                      width: 40,
                      height: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1.seconds)
                    .scaleX(begin: 0.5, end: 1, delay: 1.seconds),
              ],
            ),
          ),

          // Version info at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'stay jiggy',
                style: GoogleFonts.unifrakturMaguntia(
                  fontSize: 24,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ).animate().fadeIn(delay: 1.5.seconds),
            ),
          ),
        ],
      ),
    );
  }
}
