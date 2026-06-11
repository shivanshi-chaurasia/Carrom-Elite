import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/profile_models.dart';
import '../../providers/profile_providers.dart';

class BankDetailsScreen extends ConsumerStatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  ConsumerState<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends ConsumerState<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _holderCtrl;
  late final TextEditingController _bankCtrl;
  late final TextEditingController _accCtrl;
  late final TextEditingController _confirmCtrl;
  late final TextEditingController _ifscCtrl;
  late final TextEditingController _upiCtrl;

  @override
  void initState() {
    super.initState();
    _holderCtrl = TextEditingController(text: 'Rajan Mehta');
    _bankCtrl = TextEditingController();
    _accCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
    _ifscCtrl = TextEditingController();
    _upiCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _holderCtrl.dispose();
    _bankCtrl.dispose();
    _accCtrl.dispose();
    _confirmCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bankDetailsSubmitProvider);

    ref.listen(bankDetailsSubmitProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
      if (prev?.isLoading == true && !next.isLoading && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank details saved securely!')));
        context.push(AppRoutes.kycVerify);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bank Details', style: AppTypography.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Update your withdrawal information securely.',
                      style: AppTypography.body.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _field(
                      label: 'Account Holder Name',
                      controller: _holderCtrl,
                      hint: 'Enter holder name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Bank Name',
                      controller: _bankCtrl,
                      hint: 'Your Bank Name',
                      icon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Bank Account Number',
                      controller: _accCtrl,
                      hint: '123456789012',
                      icon: Icons.credit_card_rounded,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Confirm Account Number',
                      controller: _confirmCtrl,
                      hint: '123456789012',
                      icon: Icons.credit_card_rounded,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'IFSC Code',
                      controller: _ifscCtrl,
                      hint: 'HDFC0001234',
                      icon: Icons.qr_code_rounded,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'UPI ID (Optional)',
                      controller: _upiCtrl,
                      hint: 'username@upi',
                      icon: Icons.alternate_email_rounded,
                      required: false,
                    ),
                    const SizedBox(height: 24),
                    _gradientButton(
                      label: state.isLoading ? 'SAVING...' : 'SAVE BANK DETAILS',
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final model = BankDetailsModel(
                                  holderName: _holderCtrl.text,
                                  bankName: _bankCtrl.text,
                                  accountNumber: _accCtrl.text,
                                  confirmAccountNumber: _confirmCtrl.text,
                                  ifscCode: _ifscCtrl.text,
                                  upiId: _upiCtrl.text,
                                );
                                ref.read(bankDetailsSubmitProvider.notifier).save(model);
                              }
                            },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security_rounded, color: AppColors.textSoft, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '256-BIT ENCRYPTION SECURED',
                          style: AppTypography.small.copyWith(
                            color: AppColors.textSoft,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSoft, size: 16),
            const SizedBox(width: 6),
            Text(label.toUpperCase(), style: AppTypography.small.copyWith(color: AppColors.textSoft)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: AppTypography.body.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
          validator: (val) {
            if (required && (val == null || val.isEmpty)) {
              return 'Field required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _gradientButton({required String label, required VoidCallback? onPressed}) {
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
}
