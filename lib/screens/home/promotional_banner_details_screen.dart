import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/home_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class PromotionalBannerDetailsScreen extends ConsumerWidget {
  const PromotionalBannerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(title: 'Offer details', subtitle: 'Terms and bonus info', onBack: context.pop),
          Expanded(
            child: state.when(
              loading: () => const Padding(padding: EdgeInsets.all(18), child: SkeletonLine(height: 260)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.read(homeDashboardProvider.notifier).reload(),
              ),
              data: (data) {
                if (data.promos.isEmpty) return const AppEmptyView(subtitle: 'No active promotions.');
                final p = data.promos.first;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: AppColors.bg, size: 44),
                          const SizedBox(height: 20),
                          Text(p.title, style: AppTypography.h1.copyWith(color: AppColors.bg)),
                          const SizedBox(height: 10),
                          Text(p.subtitle, style: AppTypography.body.copyWith(color: AppColors.surface)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _rule('Minimum deposit', '₹100'),
                    _rule('Bonus usage', 'Entry fees for Carrom and Lottery only'),
                    _rule('Expiry', '7 days from claim'),
                    _rule('Status', 'Backend rules will replace this mock content'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _rule(String label, String val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.body)),
          const SizedBox(width: 12),
          Flexible(child: Text(val, style: AppTypography.h3, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
