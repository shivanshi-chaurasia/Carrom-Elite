import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                    const Text('Create Account', style: AppTypography.h1),
                    const SizedBox(height: 24),
                    _field(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      hint: 'Alexander Voss',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Email Address',
                      controller: _emailCtrl,
                      hint: 'alexander@example.com',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      hint: '+91 00000-00000',
                      icon: Icons.phone_android_rounded,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Password',
                      controller: _passCtrl,
                      hint: 'Enter password',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      label: 'Confirm Password',
                      controller: _confirmCtrl,
                      hint: 'Re-enter password',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agree,
                          onChanged: (val) => setState(() => _agree = val ?? false),
                          activeColor: AppColors.gold,
                          checkColor: AppColors.bg,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: AppTypography.small.copyWith(color: AppColors.textMuted),
                                children: const [
                                  TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.gold)),
                                  TextSpan(text: ' and '),
                                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.gold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _gradientButton(
                      label: 'Create Account',
                      onPressed: () {
                        if ((_formKey.currentState?.validate() ?? false) && _agree) {
                          context.push(AppRoutes.otpVerify);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.login),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already a member? ',
                          style: AppTypography.small.copyWith(color: AppColors.textMuted),
                          children: const [
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
    required IconData icon,
    bool obscure = false,
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
            prefixIcon: Icon(icon, color: AppColors.textSoft, size: 20),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
