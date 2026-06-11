import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/home_models.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, this.onTap});

  final GameCardModel game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _accent(game.accent);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap ??
          () {
            if (game.id.contains('lottery')) {
              context.push('/lottery-home'); // will build in next phase
            } else {
              context.push('/carrom-home');
            }
          },
      child: Container(
        width: 188,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_icon(game.icon), color: color),
                ),
                const Spacer(),
                Text(AppFormatters.compact(game.onlinePlayers), style: AppTypography.small),
              ],
            ),
            const SizedBox(height: 16),
            Text(game.title, style: AppTypography.h3),
            const SizedBox(height: 4),
            Text(game.subtitle, style: AppTypography.small, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                _pill(game.entryFee == 0 ? 'Free' : AppFormatters.money(game.entryFee), color),
                const SizedBox(width: 8),
                if (game.prize > 0) Expanded(child: Text('Win ${AppFormatters.money(game.prize)}', style: AppTypography.small)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _accent(String key) {
    if (key == 'teal') return AppColors.teal;
    if (key == 'purple') return AppColors.purple;
    if (key == 'blue') return AppColors.blue;
    return AppColors.gold;
  }

  IconData _icon(String name) {
    if (name == 'psychology') return Icons.psychology_rounded;
    if (name == 'confirmation_number') return Icons.confirmation_number_rounded;
    return Icons.sports_esports_rounded;
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: AppTypography.small.copyWith(color: AppColors.bg)),
    );
  }
}
