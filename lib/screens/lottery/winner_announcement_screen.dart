import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class WinnerAnnouncementScreen extends StatefulWidget {
  const WinnerAnnouncementScreen({
    super.key,
    this.winnerName = 'Shiva (You)',
    this.prizeAmount = 50000,
  });

  final String winnerName;
  final int prizeAmount;

  @override
  State<WinnerAnnouncementScreen> createState() => _WinnerAnnouncementScreenState();
}

class _WinnerAnnouncementScreenState extends State<WinnerAnnouncementScreen> with SingleTickerProviderStateMixin {
  late AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Custom Confetti Painter Layer
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (ctx, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(_confettiCtrl.value),
              );
            },
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Winner Cup Icon with pulse glow
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.gold, size: 76),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'CONGRATULATIONS!',
                    style: AppTypography.h1.copyWith(
                      fontSize: 32,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    widget.winnerName,
                    style: AppTypography.h2.copyWith(fontSize: 24, color: AppColors.white),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Has won the Mega Jackpot Pool!',
                    style: AppTypography.body.copyWith(color: AppColors.textMuted),
                  ),
                  
                  const SizedBox(height: 24),

                  // Prize Amount Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'GRAND PRIZE WON',
                          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${widget.prizeAmount}',
                          style: AppTypography.h1.copyWith(fontSize: 36, color: AppColors.teal, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Claim and Share buttons
                  _gradientButton('CLAIM REWARD NOW', () {
                    context.push('/reward-claim?amount=${widget.prizeAmount}');
                  }),
                  const SizedBox(height: 12),
                  
                  _outlineButton('SHARE VICTORY', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing victory link generated!')),
                    );
                  }),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _outlineButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.line, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Confetti painter generating falling rectangles with randomized properties
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.animationValue);

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // fixed seed to avoid chaotic random redraw positions
    final confettiCount = 50;

    for (int i = 0; i < confettiCount; i++) {
      final initialX = random.nextDouble() * size.width;
      final speedY = 150 + random.nextDouble() * 180;
      final speedX = -40 + random.nextDouble() * 80;
      
      // Calculate falling Y using animation value loop
      final elapsedSecs = animationValue * 4.0; // 4s loop
      double y = (speedY * elapsedSecs) % size.height;
      double x = (initialX + speedX * elapsedSecs) % size.width;

      final width = 6.0 + random.nextDouble() * 8;
      final height = 12.0 + random.nextDouble() * 10;

      final color = [
        AppColors.gold,
        AppColors.purple,
        AppColors.teal,
        AppColors.red,
        AppColors.blue,
      ][random.nextInt(5)];

      final angle = random.nextDouble() * pi * 2 + (elapsedSecs * 2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromLTWH(-width / 2, -height / 2, width, height),
        Paint()..color = color.withOpacity(0.85),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
