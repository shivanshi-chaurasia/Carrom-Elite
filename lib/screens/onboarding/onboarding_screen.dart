import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => context.go('/welcome'),
                  child: Text(
                    'SKIP',
                    style: AppTypography.button.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            // Onboarding Slides
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildSlide(
                    illustration: CustomPaint(
                      size: const Size(200, 200),
                      painter: _CarromBoardPainter(),
                    ),
                    title: 'Play & Win Real Cash',
                    subtitle: 'Join lakhs of players in daily carrom battles',
                  ),
                  _buildSlide(
                    illustration: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 76),
                    ),
                    title: 'Tournaments Every Hour',
                    subtitle: 'Compete in brackets and take home the prize pool',
                  ),
                  _buildSlide(
                    illustration: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.teal, size: 76),
                    ),
                    title: 'Instant Withdrawals',
                    subtitle: 'Winnings go straight to your UPI in minutes',
                  ),
                ],
              ),
            ),

            // Bottom Navigation Indicators & Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (idx) => _buildDot(idx)),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Button
                  _currentPage == 2
                      ? _gradientButton('GET STARTED', () => context.go('/welcome'))
                      : _actionButton('NEXT', () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required Widget illustration, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration,
          const SizedBox(height: 40),
          Text(
            title,
            style: AppTypography.h1.copyWith(fontSize: 26, color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final active = _currentPage == index;
    return Container(
      width: active ? 18 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.gold : AppColors.line,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.line),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: AppColors.white),
        ),
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
}

// Simple Carrom Board Painter for onboarding illustration
class _CarromBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Board outline
    final boardPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)),
      boardPaint,
    );

    // Frame border
    final framePaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)),
      framePaint,
    );

    // Center Circle
    final circlePaint = Paint()
      ..color = AppColors.purple.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 40, circlePaint);
    canvas.drawCircle(center, 10, Paint()..color = AppColors.gold);

    // Some mock coins
    final coinPaint = Paint()..style = PaintingStyle.fill;
    
    // Red Queen
    coinPaint.color = AppColors.red;
    canvas.drawCircle(center, 6, coinPaint);

    // White coins
    coinPaint.color = AppColors.white;
    canvas.drawCircle(Offset(center.dx - 18, center.dy - 12), 6, coinPaint);
    canvas.drawCircle(Offset(center.dx + 20, center.dy + 8), 6, coinPaint);

    // Black coins
    coinPaint.color = Colors.black;
    canvas.drawCircle(Offset(center.dx + 16, center.dy - 16), 6, coinPaint);
    canvas.drawCircle(Offset(center.dx - 12, center.dy + 18), 6, coinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
