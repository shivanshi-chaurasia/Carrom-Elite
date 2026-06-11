import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class RewardClaimScreen extends StatefulWidget {
  const RewardClaimScreen({super.key, this.amount = 50000});

  final int amount;

  @override
  State<RewardClaimScreen> createState() => _RewardClaimScreenState();
}

class _RewardClaimScreenState extends State<RewardClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiCtrl = TextEditingController(text: 'shiva@okaxis');
  bool _isClaiming = false;

  @override
  void dispose() {
    _upiCtrl.dispose();
    super.dispose();
  }

  void _processClaim(String destination) {
    if (destination == 'UPI' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isClaiming = true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isClaiming = false);
      
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.line),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: AppColors.green),
              SizedBox(width: 8),
              Text('Transfer Initiated!', style: AppTypography.h3),
            ],
          ),
          content: Text(
            destination == 'UPI'
                ? 'Your final reward amount has been dispatched to UPI ID: ${_upiCtrl.text}. It will reflect in your bank account shortly.'
                : 'Your reward amount has been successfully added to your Carrom Pro wallet balance.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/');
              },
              child: Text('GREAT', style: AppTypography.body.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Taxation math
    final double platformFee = widget.amount * 0.04; // 4% platform fee
    final double tdsTax = (widget.amount - platformFee) * 0.28; // 28% flat tax
    final double finalWinnings = widget.amount - platformFee - tdsTax;

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
          'CLAIM REWARDS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: _isClaiming
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reward summary breakdown card
                      _buildBreakdownCard(platformFee, tdsTax, finalWinnings),
                      const SizedBox(height: 24),
                      
                      // Payment credentials form
                      _buildPaymentDetailsForm(),
                      
                      const SizedBox(height: 36),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBreakdownCard(double platformFee, double tdsTax, double finalWinnings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WINNINGS STATEMENT',
            style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 16),
          _statementRow('Gross Winnings', '₹${widget.amount}'),
          _statementRow('Platform commission (4%)', '- ₹${platformFee.toInt()}', isDeduction: true),
          _statementRow('Flat TDS Tax (28%)', '- ₹${tdsTax.toInt()}', isDeduction: true),
          const Divider(color: AppColors.line, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NET PAYABLE AMOUNT', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
              Text('₹${finalWinnings.toInt()}', style: AppTypography.h2.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statementRow(String label, String value, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: isDeduction ? AppColors.red : AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CLAIM TO EXTERNAL BANK UPI',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _upiCtrl,
            style: AppTypography.body.copyWith(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Enter UPI ID (e.g. name@upi)',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              filled: true,
              fillColor: AppColors.bg,
              prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.textSoft, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.gold),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'UPI ID is required';
              if (!v.contains('@')) return 'Enter a valid UPI ID format';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _gradientButton('WITHDRAW TO BANK UPI', () => _processClaim('UPI')),
        const SizedBox(height: 12),
        _outlineButton('CLAIM TO APP CASH WALLET', () => _processClaim('WALLET')),
      ],
    );
  }

  Widget _gradientButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _outlineButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.line, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
