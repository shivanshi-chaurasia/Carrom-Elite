import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class BonusWalletScreen extends StatelessWidget {
  const BonusWalletScreen({super.key});

  final List<Map<String, dynamic>> _transactions = const [
    {
      'title': 'Referral Credit - SHIV99A',
      'amount': 100,
      'date': '10 June 2026',
      'status': 'credited',
    },
    {
      'title': 'Daily Mission Completion Bonus',
      'amount': 50,
      'date': '08 June 2026',
      'status': 'credited',
    },
    {
      'title': 'Deposit Cashback Match',
      'amount': 200,
      'date': '01 June 2026',
      'status': 'credited',
    },
    {
      'title': 'Expired Signup Bonus',
      'amount': 50,
      'date': '24 May 2026',
      'status': 'expired',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'BONUS CASH WALLET',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 16),
            _buildUsageInfoChip(),
            const SizedBox(height: 24),
            _buildSectionHeader('HOW TO EARN BONUS CASH'),
            const SizedBox(height: 10),
            _buildEarningGuide(),
            const SizedBox(height: 24),
            _buildSectionHeader('BONUS TRANSACTION HISTORY'),
            const SizedBox(height: 10),
            _buildTransactionList(),
          ],
        ),
      ),
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

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.purple.withOpacity(0.1), blurRadius: 16, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL BONUS BALANCE',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '₹350',
            style: AppTypography.h1.copyWith(fontSize: 38, color: AppColors.gold, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            '₹50 expiring in 3 days',
            style: AppTypography.small.copyWith(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfoChip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.purple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.purple, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bonus cash can only be used to pay entry fees for cash tournaments and battles. It is non-withdrawable.',
              style: AppTypography.small.copyWith(color: AppColors.textMuted, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _guideRow(Icons.share_rounded, 'Refer Friends', 'Earn ₹100 bonus for every verified sign-up.'),
          const Divider(color: AppColors.line, height: 20),
          _guideRow(Icons.add_card_rounded, 'First Deposits', 'Claim up to 10% cashback bonus on additions.'),
          const Divider(color: AppColors.line, height: 20),
          _guideRow(Icons.check_circle_outline_rounded, 'Daily Tasks', 'Complete missions to claim cash vouchers.'),
        ],
      ),
    );
  }

  Widget _guideRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
              Text(desc, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      children: _transactions.map((tx) {
        final amount = tx['amount'] as int;
        final isExpired = tx['status'] == 'expired';
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.line),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(
              isExpired ? Icons.cancel_outlined : Icons.add_circle_outline_rounded,
              color: isExpired ? AppColors.textSoft : AppColors.teal,
            ),
            title: Text(
              tx['title'] as String,
              style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(tx['date'] as String, style: AppTypography.small),
            trailing: Text(
              isExpired ? '- ₹$amount' : '+ ₹$amount',
              style: AppTypography.body.copyWith(
                color: isExpired ? AppColors.textSoft : AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
