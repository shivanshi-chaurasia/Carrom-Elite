import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/home_models.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({super.key, required this.promo, this.onTap});

  final PromoBannerModel promo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.bg, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(promo.title, style: AppTypography.h3.copyWith(color: AppColors.bg)),
                  const SizedBox(height: 4),
                  Text(promo.subtitle, style: AppTypography.small.copyWith(color: AppColors.surface)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.bg),
          ],
        ),
      ),
    );
  }
}
