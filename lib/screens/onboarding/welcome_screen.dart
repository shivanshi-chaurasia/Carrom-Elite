import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo Top Center
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CarromElite',
                style: AppTypography.h1.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Play Carrom • Win Real Cash • Instant Transfers',
                style: AppTypography.body.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              
              // Login Button (Gradient)
              _gradientButton('LOGIN TO ACCOUNT', () => context.push('/login')),
              const SizedBox(height: 14),

              // Create Account Button (Outline style)
              _outlineButton('CREATE AN ACCOUNT', () => context.push('/signup')),
              const SizedBox(height: 24),

              // Guest Player text link
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  'Continue as Guest',
                  style: AppTypography.body.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
          backgroundColor: AppColors.surface,
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
