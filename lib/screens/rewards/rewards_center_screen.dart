import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/rewards_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class RewardsCenterScreen extends ConsumerWidget {
  const RewardsCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rewardsProvider);
    final notifier = ref.read(rewardsProvider.notifier);

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: 'REWARDS CENTER',
            subtitle: 'Claim points and bonuses',
            onBack: context.pop,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildHeaderStats(context, state),
                const SizedBox(height: 24),
                _buildDailyStreak(context, state, notifier),
                const SizedBox(height: 24),
                _buildMilestonesSection(state, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context, RewardsState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 6),
                    Text('MY COINS', style: AppTypography.small.copyWith(color: AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.coins} Coins',
                  style: AppTypography.h1.copyWith(fontSize: 28, color: AppColors.text),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/coin-conversion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'CONVERT TO CASH',
                    style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, color: AppColors.bg),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 80, color: AppColors.line),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.teal, size: 20),
                    const SizedBox(width: 6),
                    Text('VIP POINTS', style: AppTypography.small.copyWith(color: AppColors.teal)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.vipPoints} pts',
                  style: AppTypography.h1.copyWith(fontSize: 28, color: AppColors.text),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/vip-membership'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.line),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'VIEW VIP TIERS',
                    style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, color: AppColors.teal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStreak(BuildContext context, RewardsState state, RewardsNotifier notifier) {
    // 7 days checklist
    final List<Map<String, dynamic>> dailyRewards = [
      {'day': 1, 'coins': 10, 'cash': 0},
      {'day': 2, 'coins': 20, 'cash': 0},
      {'day': 3, 'coins': 30, 'cash': 0},
      {'day': 4, 'coins': 50, 'cash': 2},
      {'day': 5, 'coins': 70, 'cash': 0},
      {'day': 6, 'coins': 100, 'cash': 0},
      {'day': 7, 'coins': 200, 'cash': 10},
    ];

    // Next claim day is first day not in claimedDays
    int nextClaimDay = 1;
    for (int i = 1; i <= 7; i++) {
      if (!state.claimedDays.contains(i)) {
        nextClaimDay = i;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DAILY STREAK BONUS',
              style: AppTypography.small.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              'Streak: ${state.claimedDays.length}/7 Days',
              style: AppTypography.small,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dailyRewards.map((item) {
              int day = item['day'];
              int coins = item['coins'];
              num cash = item['cash'];
              bool isClaimed = state.claimedDays.contains(day);
              bool isCurrent = day == nextClaimDay;

              Color borderCol = AppColors.line;
              Color bgCol = AppColors.card;
              if (isClaimed) {
                borderCol = AppColors.teal.withValues(alpha: 0.4);
                bgCol = AppColors.teal.withValues(alpha: 0.05);
              } else if (isCurrent) {
                borderCol = AppColors.gold;
                bgCol = AppColors.gold.withValues(alpha: 0.1);
              }

              return GestureDetector(
                onTap: isCurrent
                    ? () async {
                        var ok = await notifier.claimDailyBonus(day, coins, cash);
                        if (ok && context.mounted) {
                          var msg = 'Claimed $coins Coins!';
                          if (cash > 0) msg += ' and ₹$cash Bonus Cash!';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: AppColors.teal),
                          );
                        }
                      }
                    : null,
                child: Container(
                  width: 76,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: bgCol,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text('Day $day', style: AppTypography.small.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Icon(
                        isClaimed
                            ? Icons.check_circle_rounded
                            : (cash > 0 ? Icons.monetization_on_rounded : Icons.circle_notifications_rounded),
                        color: isClaimed ? AppColors.teal : (isCurrent ? AppColors.gold : AppColors.textSoft),
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+$coins',
                        style: AppTypography.small.copyWith(
                          color: isClaimed ? AppColors.teal : (isCurrent ? AppColors.gold : AppColors.text),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (cash > 0)
                        Text(
                          '+₹$cash',
                          style: AppTypography.small.copyWith(
                            color: AppColors.teal,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesSection(RewardsState state, RewardsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MILESTONES & CHALLENGES',
          style: AppTypography.small.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        ...state.milestones.map((m) {
          double progressVal = m.target > 0 ? m.progress / m.target : 0.0;
          if (progressVal > 1.0) progressVal = 1.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: m.isClaimed ? AppColors.line : (m.isCompleted ? AppColors.teal.withValues(alpha: 0.3) : AppColors.line),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
                          const SizedBox(height: 2),
                          Text(m.description, style: AppTypography.small),
                        ],
                      ),
                    ),
                    if (m.isClaimed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CLAIMED',
                          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
                        ),
                      )
                    else if (m.isCompleted)
                      ElevatedButton(
                        onPressed: () => notifier.claimMilestone(m.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: AppColors.bg,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text('CLAIM', style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, color: AppColors.bg)),
                      )
                    else
                      Text(
                        '${m.progress}/${m.target}',
                        style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSoft),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressVal,
                    minHeight: 6,
                    backgroundColor: AppColors.surface2,
                    color: m.isClaimed ? AppColors.line : (m.isCompleted ? AppColors.teal : AppColors.purple),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Reward: ', style: AppTypography.small),
                    if (m.rewardCoins > 0) ...[
                      const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text('${m.rewardCoins} coins', style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                    if (m.rewardCoins > 0 && m.rewardCash > 0)
                      Text(' + ', style: AppTypography.small),
                    if (m.rewardCash > 0) ...[
                      const Icon(Icons.account_balance_wallet_rounded, color: AppColors.teal, size: 14),
                      const SizedBox(width: 4),
                      Text(AppFormatters.money(m.rewardCash), style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
