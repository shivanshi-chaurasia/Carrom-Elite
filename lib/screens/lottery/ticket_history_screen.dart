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

class TicketHistoryScreen extends ConsumerWidget {
  const TicketHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketHistoryProvider);

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(
            title: 'MY TICKETS',
            subtitle: 'Ticket purchase history',
            onBack: context.pop,
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(ticketHistoryProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const AppEmptyView(subtitle: 'You haven\'t bought any tickets yet.');
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemBuilder: (ctx, i) => _buildTicketTile(items[i]),
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                  itemCount: items.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTile(LotteryTicketModel t) {
    var isWon = t.status == 'won';
    var isActive = t.status == 'active';

    Color statusColor;
    String statusText;

    if (isActive) {
      statusColor = AppColors.gold;
      statusText = 'ACTIVE DRAW';
    } else if (isWon) {
      statusColor = AppColors.teal;
      statusText = 'WON';
    } else {
      statusColor = AppColors.textSoft;
      statusText = 'NO WIN';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWon ? AppColors.teal.withValues(alpha: 0.5) : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.lotteryTitle, style: AppTypography.h3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: AppTypography.small.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: t.selectedNumbers
                .map((n) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          n.toString(),
                          style: AppTypography.small.copyWith(
                            color: isWon ? AppColors.teal : AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
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
                'Purchased: ${t.purchaseTime}',
                style: AppTypography.small.copyWith(color: AppColors.textSoft),
              ),
              if (isWon)
                Text(
                  'Prize: ${AppFormatters.money(t.prizeWon)}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
