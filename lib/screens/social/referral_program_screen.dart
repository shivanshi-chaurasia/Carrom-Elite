import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class ReferralProgramScreen extends ConsumerWidget {
  const ReferralProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralState = ref.watch(referralInfoProvider);

    // Mock referral ledger data
    final List<Map<String, String>> inviteHistory = [
      {'name': 'Rahul Sharma', 'status': 'KYC Verified', 'reward': '₹100 Cash Credited', 'date': 'Today'},
      {'name': 'Preeti Verma', 'status': 'Joined, KYC Pending', 'reward': 'Pending Verification', 'date': 'Yesterday'},
      {'name': 'Vikram Rathore', 'status': 'KYC Verified', 'reward': '₹100 Cash Credited', 'date': '08 June'},
      {'name': 'Anil Gupta', 'status': 'Joined, KYC Pending', 'reward': 'Pending Verification', 'date': '06 June'},
      {'name': 'Sneha Patil', 'status': 'KYC Verified', 'reward': '₹100 Cash Credited', 'date': '01 June'},
    ];

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: 'REFERRAL PROGRAM',
            subtitle: 'Invite friends, earn cash',
            onBack: context.pop,
          ),
          Expanded(
            child: referralState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (refInfo) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildInviteCard(context, refInfo),
                  const SizedBox(height: 24),
                  _buildSectionHeader('INVITE HISTORY & STATUS'),
                  const SizedBox(height: 10),
                  _buildInviteLedger(inviteHistory),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, var refInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.1),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.purple, size: 24),
              const SizedBox(width: 8),
              Text(
                'SHARE & EARN REAL CASH',
                style: AppTypography.h3.copyWith(color: AppColors.purple),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get ₹100 bonus cash for every friend who joins and completes KYC verification. Your friends get ₹50 free instantly on signup!',
            style: AppTypography.body,
          ),
          const Divider(color: AppColors.line, height: 28),
          const Text('YOUR REFERRAL CODE', style: AppTypography.small),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    refInfo.code,
                    style: AppTypography.h2.copyWith(letterSpacing: 2, color: AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: refInfo.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Referral code copied!'), backgroundColor: AppColors.teal),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface2,
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.line),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('COPY'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite link shared!'), backgroundColor: AppColors.teal),
              );
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('SHARE INVITE LINK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.text,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryCol('TOTAL INVITES', refInfo.referralsCount.toString(), AppColors.text),
              Container(width: 1, height: 32, color: AppColors.line),
              _summaryCol('TOTAL EARNED', AppFormatters.money(refInfo.totalEarned), AppColors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(String label, String val, Color valCol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.small),
        const SizedBox(height: 2),
        Text(val, style: AppTypography.h3.copyWith(color: valCol, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.small.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildInviteLedger(List<Map<String, String>> history) {
    return Column(
      children: history.map((item) {
        var isVerified = item['status'] == 'KYC Verified';
        return Card(
          color: AppColors.card,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.line),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surface,
              child: Icon(
                isVerified ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                color: isVerified ? AppColors.teal : AppColors.gold,
                size: 20,
              ),
            ),
            title: Text(item['name'] ?? '', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
            subtitle: Text('${item['status']} • ${item['date']}', style: AppTypography.small),
            trailing: Text(
              item['reward'] ?? '',
              style: AppTypography.small.copyWith(
                color: isVerified ? AppColors.teal : AppColors.textSoft,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
