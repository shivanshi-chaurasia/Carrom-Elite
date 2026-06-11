import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                    const Text('Create Password', style: AppTypography.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your new password below.',
                      style: AppTypography.body.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    _field(
                      label: 'New Password',
                      controller: _passCtrl,
                      hint: 'Enter new password',
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
                    const SizedBox(height: 10),
                    _strengthBar(),
                    const SizedBox(height: 18),
                    _field(
                      label: 'Confirm Password',
                      controller: _confirmCtrl,
                      hint: 'Re-enter password',
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
                    const SizedBox(height: 24),
                    _gradientButton(
                      label: 'Continue',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.push(AppRoutes.authSuccess);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: Text(
                        '← Back to Login',
                        style: AppTypography.small.copyWith(color: AppColors.textMuted),
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

  Widget _strengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _barSegment(color: Colors.red)),
            const SizedBox(width: 4),
            Expanded(child: _barSegment(color: Colors.orange)),
            const SizedBox(width: 4),
            Expanded(child: _barSegment(color: AppColors.gold)),
            const SizedBox(width: 4),
            Expanded(child: _barSegment(color: AppColors.surface2)),
            const SizedBox(width: 8),
            Text('Fair', style: AppTypography.small.copyWith(color: AppColors.gold)),
          ],
        ),
      ],
    );
  }

  Widget _barSegment({required Color color}) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
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
        Text(label.toUpperCase(), style: AppTypography.small.copyWith(color: AppColors.textSoft)),
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

  Widget _gradientButton({required String label, required VoidCallback onPressed}) {
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
