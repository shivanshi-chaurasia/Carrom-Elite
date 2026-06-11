import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/home_models.dart';

class LotteryCard extends StatelessWidget {
  const LotteryCard({super.key, required this.item});

  final LotteryHighlightModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.confirmation_number_rounded, color: AppColors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTypography.h3),
                const SizedBox(height: 4),
                Text('Draw ${item.drawTime} • Ticket ${AppFormatters.money(item.ticketPrice)}', style: AppTypography.small),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.soldPercent,
                    minHeight: 5,
                    backgroundColor: AppColors.surface2,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(AppFormatters.money(item.jackpot), style: AppTypography.h3.copyWith(color: AppColors.gold)),
        ],
      ),
    );
  }
}
