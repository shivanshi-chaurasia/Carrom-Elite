import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawState();
}

class _WithdrawState extends ConsumerState<WithdrawScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController upiController = TextEditingController();
  bool isWithdrawing = false;

  @override
  void dispose() {
    amountController.dispose();
    upiController.dispose();
    super.dispose();
  }

  void _goToOtpVerify() {
    var amt = amountController.text.trim();
    var upi = upiController.text.trim();
    context.push('/withdrawal-otp?amount=$amt&upi=$upi');
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletDetailsProvider);

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(
            title: 'WITHDRAW WINNINGS',
            subtitle: 'Direct bank transfer',
            onBack: context.pop,
          ),
          Expanded(
            child: walletState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => Center(child: Text(err.toString())),
              data: (wallet) {
                var maxWinnings = wallet.winnings;
                var enteredAmt = num.tryParse(amountController.text.trim()) ?? 0;
                var ready = enteredAmt > 0 && enteredAmt <= maxWinnings && upiController.text.trim().isNotEmpty;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildWinningsCard(maxWinnings),
                    const SizedBox(height: 16),
                    _buildAmountInput(maxWinnings),
                    const SizedBox(height: 16),
                    _buildUPIInput(),
                    const SizedBox(height: 24),
                    _buildWarningCard(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: ready ? _goToOtpVerify : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.bg,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'WITHDRAW MONEY',
                        style: AppTypography.button,
                      ),
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

  Widget _buildWinningsCard(num maxWinnings) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Withdrawable Winnings', style: AppTypography.small),
              const SizedBox(height: 4),
              Text(
                AppFormatters.money(maxWinnings),
                style: AppTypography.h2.copyWith(color: AppColors.teal),
              ),
            ],
          ),
          const Icon(Icons.stars_rounded, color: AppColors.teal, size: 28),
        ],
      ),
    );
  }

  Widget _buildAmountInput(num maxWinnings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Withdrawal Amount (₹)', style: AppTypography.small),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: AppTypography.h3.copyWith(color: AppColors.text),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Enter amount to withdraw',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              border: InputBorder.none,
              prefixText: '₹ ',
              prefixStyle: AppTypography.h3.copyWith(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUPIInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recipient UPI ID', style: AppTypography.small),
          const SizedBox(height: 8),
          TextField(
            controller: upiController,
            keyboardType: TextInputType.emailAddress,
            style: AppTypography.body.copyWith(color: AppColors.text),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'e.g. username@upi',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Transactions are processed instantly. Please ensure your UPI ID is correct. We cannot reverse payments sent to the wrong address.',
              style: AppTypography.small.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
