import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Show splash for 3 seconds as requested
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Deep Navy
      body: Stack(
        children: [
          // Subtle background texture or gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'JG',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                )
                .animate()
                .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 800.ms)
                .shimmer(delay: 1.seconds, duration: 2.seconds, color: Colors.blue.shade100),

                const SizedBox(height: 32),

                // Branding Text
                Text(
                  'MADE BY',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                    color: Colors.blue.shade400,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms),

                const SizedBox(height: 8),

                Text(
                  'JIGGY GAMES',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.1, end: 0, delay: 600.ms, duration: 800.ms),

                const SizedBox(height: 48),
                
                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
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
                'NUMBERS COLLECTION',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.white.withOpacity(0.3),
                ),
              )
              .animate()
              .fadeIn(delay: 1.5.seconds),
            ),
          ),
        ],
      ),
    );
  }
}
