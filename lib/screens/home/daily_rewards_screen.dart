import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/home_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/cards/reward_card.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class DailyRewardsScreen extends ConsumerWidget {
  const DailyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyRewardsProvider);
    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(title: 'Daily rewards', subtitle: 'Come back each day', onBack: context.pop),
          Expanded(
            child: state.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(18),
                child: Column(children: [SkeletonLine(height: 132), SizedBox(height: 12), SkeletonLine(height: 132)]),
              ),
              error: (err, stack) => AppErrorView(message: err.toString(), onRetry: () => ref.invalidate(dailyRewardsProvider)),
              data: (items) => items.isEmpty
                  ? const AppEmptyView(subtitle: 'Rewards refresh every morning.')
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text('Claim streak rewards before midnight.', style: AppTypography.h3),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: items.map((e) => RewardCard(reward: e)).toList(),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
