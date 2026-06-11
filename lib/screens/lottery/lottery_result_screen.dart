import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/lottery_models.dart';
import '../../providers/lottery_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class LotteryResultScreen extends ConsumerWidget {
  const LotteryResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lotteryResultsProvider);

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(
            title: 'DRAW RESULTS',
            subtitle: 'Past draws and winners',
            onBack: context.pop,
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(lotteryResultsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const AppEmptyView(subtitle: 'No draw results available.');
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildAnnouncementsCard(),
                    const SizedBox(height: 24),
                    Text(
                      'PAST DRAWS',
                      style: AppTypography.small.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...items.map((item) => _buildDrawResultTile(item)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
    // mock major announcement
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              Text(
                'WINNER ANNOUNCEMENT',
                style: AppTypography.h3.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Congratulations to player "StrikerKing" for hitting the ₹1,00,000 jackpot in yesterday\'s draw! 🏆',
            style: AppTypography.body,
          ),
          const SizedBox(height: 8),
          Text(
            'Draw date: 09 June, 08:00 PM',
            style: AppTypography.small.copyWith(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawResultTile(LotteryDrawResultModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.lotteryTitle, style: AppTypography.h3),
              Text(item.drawDate, style: AppTypography.small),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: (item.winningNumbers)
                .map((n) => CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surface,
                      child: Text(
                        n.toString(),
                        style: AppTypography.body.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const Divider(color: AppColors.line, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jackpot Won: ${AppFormatters.money(item.jackpotWon)}',
                style: AppTypography.small.copyWith(color: AppColors.textMuted),
              ),
              Text(
                'Winners: ${item.winnersCount}',
                style: AppTypography.small.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
