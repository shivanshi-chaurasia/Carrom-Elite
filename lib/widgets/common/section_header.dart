import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.h3)),
          if (action != null)
            TextButton(
              onPressed: onTap,
              child: Text(action!, style: AppTypography.small.copyWith(color: AppColors.gold)),
            ),
        ],
      ),
    );
  }
}
