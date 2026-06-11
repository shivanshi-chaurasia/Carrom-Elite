import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_models.dart';
import '../../providers/wallet_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class WalletDashboardScreen extends ConsumerWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletDetailsProvider);
    final referralState = ref.watch(referralInfoProvider);

    return AppScaffold(
      currentIndex: 3,
      child: Column(
        children: [
          GamingAppBar(
            title: 'PLAY WALLET',
            subtitle: 'Manage your funds',
            onBack: () => context.go('/'),
          ),
          Expanded(
            child: walletState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(walletDetailsProvider),
              ),
              data: (wallet) {
                final refInfo = referralState.value;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildTotalBalanceCard(context, wallet),
                    const SizedBox(height: 16),
                    _buildSubAccountsCard(wallet, refInfo),
                    const SizedBox(height: 24),
                    _buildQuickMenu(context),
                    const SizedBox(height: 24),
                    referralState.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                      error: (err, stack) => Container(),
                      data: (refInfo) => _buildReferralCard(context, refInfo),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, WalletDetailsModel wallet) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Text('TOTAL BALANCE', style: AppTypography.small),
          const SizedBox(height: 6),
          Text(
            AppFormatters.money(wallet.total),
            style: AppTypography.h1.copyWith(
              fontSize: 36,
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/add-money'),
                  icon: const Icon(Icons.add_circle_rounded, size: 18),
                  label: const Text('ADD MONEY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/withdraw'),
                  icon: const Icon(Icons.account_balance_rounded, size: 18),
                  label: const Text('WITHDRAW'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.line),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubAccountsCard(WalletDetailsModel wallet, ReferralModel? refInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _subAccountRow('Deposited cash', wallet.deposit, 'Used to play games'),
          const Divider(color: AppColors.line, height: 16),
          _subAccountRow('Winnings', wallet.winnings, 'Fully withdrawable'),
          const Divider(color: AppColors.line, height: 16),
          _subAccountRow('Bonus money', wallet.bonus, 'Used automatically on entry'),
          if (refInfo != null && refInfo.totalEarned > 0) ...[
            const Divider(color: AppColors.line, height: 16),
            _subAccountRow('Referral earnings', refInfo.totalEarned, 'Rewards from inviting friends'),
          ],
        ],
      ),
    );
  }

  Widget _subAccountRow(String title, num amount, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.small),
            ],
          ),
          Text(
            AppFormatters.money(amount),
            style: AppTypography.h3.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT SUMMARY',
          style: AppTypography.small.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          tileColor: AppColors.card,
          leading: const Icon(Icons.history_rounded, color: AppColors.blue),
          title: const Text('Transaction History', style: AppTypography.body),
          subtitle: const Text('Check invoices, withdrawals, and game entries', style: AppTypography.small),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSoft),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.line),
          ),
          onTap: () => context.push('/transaction-history'),
        ),
      ],
    );
  }

  Widget _buildReferralCard(BuildContext context, ReferralModel refInfo) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.purple, size: 24),
              const SizedBox(width: 8),
              Text(
                'REFER & EARN CASH',
                style: AppTypography.h3.copyWith(color: AppColors.purple),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Earn ₹100 bonus cash for every friend that joins and verifies KYC! Your friend gets ₹50 free.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    refInfo.code,
                    style: AppTypography.h3.copyWith(letterSpacing: 1.5, color: AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: refInfo.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Referral code copied!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface2,
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('COPY'),
              ),
            ],
          ),
          const Divider(color: AppColors.line, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Referrals: ${refInfo.referralsCount}',
                style: AppTypography.small,
              ),
              Text(
                'Total Earned: ${AppFormatters.money(refInfo.totalEarned)}',
                style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
