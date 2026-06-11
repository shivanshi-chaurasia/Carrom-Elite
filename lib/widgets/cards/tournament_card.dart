import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/home_models.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({super.key, required this.item, this.onTap});

  final TournamentBannerModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => context.push('/tournament-details/${item.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 304,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.42)),
          gradient: const LinearGradient(
            colors: [AppColors.cardLight, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(child: Text(item.title, style: AppTypography.h3)),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.subtitle, style: AppTypography.body),
            const Spacer(),
            Row(
              children: [
                _stat('Prize', AppFormatters.money(item.prizePool)),
                _stat('Entry', AppFormatters.money(item.entryFee)),
                _stat('Starts', item.startsIn),
              ],
            ),
            const SizedBox(height: 10),
            Text('${item.seatsLeft} seats left', style: AppTypography.small),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.small),
          const SizedBox(height: 3),
          Text(val, style: AppTypography.small.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}
