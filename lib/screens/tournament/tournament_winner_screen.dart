import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';

class TournamentWinnerScreen extends StatelessWidget {
  const TournamentWinnerScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF2E1A47),
              AppColors.bg,
            ],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Trophy icon + glow animation
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.gold,
                    size: 72,
                  ),
                )
                    .animate(onPlay: (ctrl) => ctrl.repeat())
                    .shimmer(delay: 400.ms, duration: 1800.ms, color: Colors.white24)
                    .scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                // Victory Titles
                Text(
                  'VICTORY!',
                  style: AppTypography.h1.copyWith(
                    fontSize: 42,
                    color: AppColors.gold,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Tournament Champion Declared',
                  style: AppTypography.body.copyWith(color: AppColors.textMuted),
                ).animate().fade(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 32),

                // Winner Detail Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.cardLight,
                        child: Icon(Icons.person, size: 36, color: AppColors.gold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'StrikerKing',
                        style: AppTypography.h2,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'First Place Champion',
                        style: AppTypography.small.copyWith(color: AppColors.teal),
                      ),
                      const Divider(color: AppColors.line, height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statTile('PRIZE WON', '₹25,000'),
                          _statTile('SCORE', '120 pts'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fade(delay: 400.ms, duration: 500.ms).scale(curve: Curves.easeOutBack),

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'HOME',
                          style: AppTypography.button.copyWith(color: AppColors.text),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // pop and view leaderboard
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.bg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'LEADERBOARD',
                          style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(delay: 600.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statTile(String label, String val) {
    return Column(
      children: [
        Text(label, style: AppTypography.small),
        const SizedBox(height: 6),
        Text(
          val,
          style: AppTypography.h3.copyWith(
            color: AppColors.gold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
