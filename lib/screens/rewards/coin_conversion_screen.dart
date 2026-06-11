import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/rewards_providers.dart';
import '../../providers/wallet_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class CoinConversionScreen extends ConsumerStatefulWidget {
  const CoinConversionScreen({super.key});

  @override
  ConsumerState<CoinConversionScreen> createState() => _CoinConversionState();
}

class _CoinConversionState extends ConsumerState<CoinConversionScreen> {
  final TextEditingController _coinsController = TextEditingController(text: '100');
  bool _isConverting = false;

  @override
  void dispose() {
    _coinsController.dispose();
    super.dispose();
  }

  void _onSetMax(int maxCoins) {
    // round to nearest 100 for conversion
    int convertableMax = (maxCoins ~/ 100) * 100;
    if (convertableMax <= 0) convertableMax = maxCoins;
    setState(() {
      _coinsController.text = convertableMax.toString();
    });
  }

  Future<void> _handleConversion(int currentCoins) async {
    var coinsStr = _coinsController.text.trim();
    var coinsVal = int.tryParse(coinsStr) ?? 0;

    if (coinsVal <= 0 || coinsVal > currentCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coin amount'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _isConverting = true);
    
    var ok = await ref.read(rewardsProvider.notifier).convertCoins(coinsVal);

    if (ok) {
      ref.invalidate(transactionHistoryProvider); // update transaction ledger
      if (mounted) {
        var cashAward = coinsVal * 0.1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Converted $coinsVal Coins into ₹$cashAward Bonus Cash! 🎉'),
            backgroundColor: AppColors.teal,
          ),
        );
        context.pop();
      }
    } else {
      setState(() => _isConverting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardsProvider);
    var coinsStr = _coinsController.text.trim();
    var coinsVal = int.tryParse(coinsStr) ?? 0;
    
    // Conversion math
    double conversionRate = 0.1; // 100 coins = ₹10
    double cashOutput = coinsVal * conversionRate;
    bool hasEnough = coinsVal <= state.coins && coinsVal > 0;

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: 'COIN CONVERSION',
            subtitle: 'Redeem loyalty coins for cash',
            onBack: context.pop,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildBalanceCard(state.coins),
                const SizedBox(height: 24),
                _buildConversionForm(state.coins),
                const SizedBox(height: 24),
                if (coinsVal > 0) ...[
                  _buildCalculationRow(coinsVal, cashOutput, hasEnough),
                  const SizedBox(height: 24),
                ],
                _buildConversionRules(),
              ],
            ),
          ),
          _buildActionFooter(state.coins, hasEnough),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(int coins) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOUR COIN BALANCE', style: AppTypography.small),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 24),
                  const SizedBox(width: 8),
                  Text('$coins Coins', style: AppTypography.h1),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _onSetMax(coins),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface2,
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('USE MAX'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionForm(int currentCoins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter Coins to Convert', style: AppTypography.small),
          const SizedBox(height: 8),
          TextField(
            controller: _coinsController,
            keyboardType: TextInputType.number,
            style: AppTypography.h1.copyWith(fontSize: 28, color: AppColors.gold),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTypography.h1.copyWith(fontSize: 28, color: AppColors.textSoft),
              border: InputBorder.none,
              suffixText: 'Coins',
              suffixStyle: AppTypography.h3.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(int coins, double cash, bool hasEnough) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasEnough ? AppColors.line : AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOU WILL RECEIVE', style: AppTypography.small),
              const SizedBox(height: 4),
              Text(
                AppFormatters.money(cash),
                style: AppTypography.h1.copyWith(color: hasEnough ? AppColors.teal : AppColors.red),
              ),
              Text(
                'Credited to Bonus Wallet',
                style: AppTypography.small.copyWith(color: AppColors.textSoft),
              ),
            ],
          ),
          Icon(
            hasEnough ? Icons.swap_horizontal_circle_rounded : Icons.error_rounded,
            color: hasEnough ? AppColors.teal : AppColors.red,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildConversionRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONVERSION RULES',
            style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _ruleBullet('Minimum conversion limit is 100 play coins.'),
          _ruleBullet('Conversion rate is fixed: 10 Coins = ₹1 Bonus Cash.'),
          _ruleBullet('Converted funds are credited as Game Bonus Cash and are automatically applied towards match entries.'),
          _ruleBullet('Bonus Cash cannot be directly withdrawn to bank account.'),
        ],
      ),
    );
  }

  Widget _ruleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.gold, fontSize: 16)),
          Expanded(child: Text(text, style: AppTypography.small)),
        ],
      ),
    );
  }

  Widget _buildActionFooter(int currentCoins, bool hasEnough) {
    var disabled = !hasEnough || _isConverting;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : () => _handleConversion(currentCoins),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isConverting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg),
              )
            : Text(
                hasEnough ? 'CONVERT COINS NOW' : 'INSUFFICIENT COIN BALANCE',
                style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
