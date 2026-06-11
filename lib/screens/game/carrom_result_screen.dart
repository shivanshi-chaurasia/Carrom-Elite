import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';

class CarromResultScreen extends StatelessWidget {
  const CarromResultScreen({super.key, this.winner, this.mode});

  final String? winner;
  final String? mode;

  @override
  Widget build(BuildContext context) {
    var isWin = winner == 'player1';
    var isBotMode = mode == 'bot';

    return AppScaffold(
      showBottomNav: false,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              isWin ? const Color(0xFF143026) : const Color(0xFF38141C),
              AppColors.bg,
            ],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  isWin ? Icons.stars_rounded : Icons.gpp_bad_rounded,
                  color: isWin ? AppColors.gold : AppColors.red,
                  size: 84,
                ),
                const SizedBox(height: 24),
                Text(
                  isWin ? 'YOU WON!' : 'YOU LOST!',
                  style: AppTypography.h1.copyWith(
                    fontSize: 42,
                    color: isWin ? AppColors.gold : AppColors.red,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isWin
                      ? 'Incredible accuracy and striker control!'
                      : 'Good try! Practice makes perfect.',
                  style: AppTypography.body.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 38),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      _row('Game Mode', isBotMode ? 'Offline Practice' : '1v1 Online Lobby'),
                      const Divider(color: AppColors.line, height: 20),
                      _row('Reward Gained', isWin ? (isBotMode ? '+15 XP' : '₹90.00 Winnings') : '+5 XP'),
                      const Divider(color: AppColors.line, height: 20),
                      _row('Accuracy', isWin ? '88%' : '64%'),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.go('/carrom-home'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'MODES',
                          style: AppTypography.button.copyWith(color: AppColors.text),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.bg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'DASHBOARD',
                          style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body),
        Text(val, style: AppTypography.body.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
