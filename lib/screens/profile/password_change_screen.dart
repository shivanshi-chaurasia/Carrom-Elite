import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/profile_providers.dart';

class PasswordChangeScreen extends ConsumerStatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  ConsumerState<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends ConsumerState<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _obscure3 = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordUpdateProvider);

    ref.listen(passwordUpdateProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
      if (prev?.isLoading == true && !next.isLoading && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
        context.push(AppRoutes.bankDetails);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
      ),
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
                    const Text('Security Settings', style: AppTypography.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Update your password to ensure account safety.',
                      style: AppTypography.body.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _field(
                      label: 'Current Password',
                      controller: _currentCtrl,
                      hint: 'Enter current password',
                      obscure: _obscure1,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSoft,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'New Password',
                      controller: _newCtrl,
                      hint: 'Enter new password',
                      obscure: _obscure2,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSoft,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Confirm Password',
                      controller: _confirmCtrl,
                      hint: 'Confirm new password',
                      obscure: _obscure3,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure3 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSoft,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure3 = !_obscure3),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _gradientButton(
                      label: state.isLoading ? 'UPDATING...' : 'UPDATE PASSWORD',
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                ref.read(passwordUpdateProvider.notifier).changePassword(
                                      currentPassword: _currentCtrl.text,
                                      newPassword: _newCtrl.text,
                                    );
                              }
                            },
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot current password?',
                        style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
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
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.textSoft, size: 16),
            const SizedBox(width: 6),
            Text(label.toUpperCase(), style: AppTypography.small.copyWith(color: AppColors.textSoft)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: AppTypography.body.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
            filled: true,
            fillColor: AppColors.bg,
            suffixIcon: suffix,
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
          validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
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
