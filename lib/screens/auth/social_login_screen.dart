import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  bool _isConnecting = false;
  String _activePlatform = '';

  void _simulateOAuth(String platform) {
    setState(() {
      _isConnecting = true;
      _activePlatform = platform;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      
      // Simulate random success/failure
      final bool isSuccess = DateTime.now().millisecond % 5 != 0; 
      
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.teal,
            content: Text(
              'Successfully connected with $platform!',
              style: AppTypography.body.copyWith(color: AppColors.surface, fontWeight: FontWeight.bold),
            ),
          ),
        );
        context.go('/'); // Pushes to home dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text(
              'OAuth connection with $platform failed. Please try again.',
              style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    });
  }

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
          'SOCIAL SIGN IN',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share_rounded, size: 58, color: AppColors.purple),
                  const SizedBox(height: 20),
                  Text(
                    'Link & Play',
                    style: AppTypography.h1.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in instantly using your existing gaming and social accounts.',
                    style: AppTypography.body.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Google button
                  _buildSocialButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    brandColor: const Color(0xFFDE4032),
                    iconColor: Colors.white,
                    onPressed: () => _simulateOAuth('Google'),
                  ),
                  const SizedBox(height: 16),

                  // Facebook button
                  _buildSocialButton(
                    label: 'Continue with Facebook',
                    icon: Icons.facebook_rounded,
                    brandColor: const Color(0xFF3B5998),
                    iconColor: Colors.white,
                    onPressed: () => _simulateOAuth('Facebook'),
                  ),
                  const SizedBox(height: 16),

                  // Apple button
                  _buildSocialButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple_rounded,
                    brandColor: Colors.black,
                    iconColor: Colors.white,
                    borderColor: AppColors.line,
                    onPressed: () => _simulateOAuth('Apple'),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'By continuing, you agree to our Terms of Service & Privacy Policy.',
                    style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (_isConnecting) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color brandColor,
    required Color iconColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const Expanded(
              child: SizedBox(),
            ),
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
            const SizedBox(width: 28), // balance space of leading icon
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              'Connecting with $_activePlatform...',
              style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Authenticating secure session keys',
              style: AppTypography.small.copyWith(color: AppColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}
