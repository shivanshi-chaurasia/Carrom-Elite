import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/home_models.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({super.key, required this.reward});

  final RewardModel reward;

  @override
  Widget build(BuildContext context) {
    final active = !reward.claimed;
    return Container(
      width: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppColors.cardLight : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppColors.gold : AppColors.line),
      ),
      child: Column(
        children: [
          Text('Day ${reward.day}', style: AppTypography.small),
          const SizedBox(height: 10),
          Icon(
            reward.claimed ? Icons.check_circle_rounded : Icons.card_giftcard_rounded,
            color: active ? AppColors.gold : AppColors.green,
          ),
          const SizedBox(height: 10),
          Text(reward.value, style: AppTypography.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(reward.title, style: AppTypography.small, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
