import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';

class GameResultDialog extends StatefulWidget {
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
  State<GameResultDialog> createState() => _GameResultDialogState();
}

class _GameResultDialogState extends State<GameResultDialog> {
  int _secondsRemaining = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.onRevive != null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showRevive = widget.onRevive != null && _secondsRemaining > 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: NumbersColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, widget.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 48),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: NumbersColors.textBody,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: NumbersColors.textFaint,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            if (showRevive) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _timer?.cancel();
                    widget.onRevive!();
                  },
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          value: _secondsRemaining / 5,
                          strokeWidth: 3,
                          color: NumbersColors.textBody.withOpacity(0.3),
                        ),
                      ),
                      Text('$_secondsRemaining', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: NumbersColors.textBody)),
                    ],
                  ),
                  label: Text(
                    widget.reviveButtonText.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NumbersColors.yellow,
                    foregroundColor: NumbersColors.textBody,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onButtonPressed,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: NumbersColors.border, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.buttonText.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontSize: 13,
                    color: NumbersColors.textBody,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}
