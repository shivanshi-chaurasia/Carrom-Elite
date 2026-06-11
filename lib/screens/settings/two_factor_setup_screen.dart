import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class TwoFactorSetupScreen extends ConsumerStatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  ConsumerState<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends ConsumerState<TwoFactorSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final String _secretKey = 'JBSWY3DPEHPK3PXP';

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);

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
          'TWO-FACTOR AUTH (2FA)',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: prefs.twoFactorEnabled ? _buildEnabledState() : _buildSetupState(),
        ),
      ),
    );
  }

  Widget _buildEnabledState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal, width: 2),
            ),
            child: const Icon(Icons.shield_rounded, color: AppColors.teal, size: 64),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Two-Factor Authentication is Enabled', style: AppTypography.h2, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Your account cash wallet and personal details are protected by an additional validation layer.',
          style: AppTypography.body.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.red.withOpacity(0.5)),
          ),
          child: TextButton.icon(
            onPressed: () {
              ref.read(userPreferencesProvider.notifier).setTwoFactorEnabled(false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Two-factor authentication has been disabled.')),
              );
            },
            icon: const Icon(Icons.gpp_bad_rounded, color: AppColors.red, size: 18),
            label: Text(
              'DISABLE 2FA PROTECTION',
              style: AppTypography.button.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetupState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Secure Your Wallet', style: AppTypography.h2),
          const SizedBox(height: 6),
          Text(
            'Follow these simple steps to bind an authenticator app (like Google Authenticator or Authy) to your Carrom Pro account.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _stepHeader('STEP 1: DOWNLOAD AUTHENTICATOR'),
          const SizedBox(height: 6),
          Text(
            'Download Google Authenticator or Authy from your device app store.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _stepHeader('STEP 2: SCAN QR OR COPY SECRET KEY'),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: CustomPaint(
                painter: _QrCodePainter(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Cannot scan? Copy this secret key manually:',
              style: AppTypography.small.copyWith(color: AppColors.textSoft),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _secretKey,
                    style: AppTypography.body.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppColors.gold, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _secretKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Secret key copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _stepHeader('STEP 3: ENTER VALIDATION CODE'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: AppTypography.body.copyWith(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Enter 6-digit OTP code',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              filled: true,
              fillColor: AppColors.surface,
              counterText: '',
              prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.textSoft, size: 18),
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
              if (val == null || val.isEmpty) return 'Code is required';
              if (val.length != 6 || int.tryParse(val) == null) {
                return 'Enter a valid 6-digit numeric code';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _gradientButton(
            label: 'ENABLE 2FA PROTECTION',
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                ref.read(userPreferencesProvider.notifier).setTwoFactorEnabled(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2FA Enabled successfully!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _stepHeader(String title) {
    return Text(
      title,
      style: AppTypography.small.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
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

// Custom Painter to draw a mock QR Code graphic
class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Corner Finder Patterns
    canvas.drawRect(const Rect.fromLTWH(12, 12, 36, 36), paint);
    canvas.drawRect(const Rect.fromLTWH(18, 18, 24, 24), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(24, 24, 12, 12), paint);

    canvas.drawRect(Rect.fromLTWH(size.width - 48, 12, 36, 36), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 42, 18, 24, 24), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - 36, 24, 12, 12), paint);

    canvas.drawRect(Rect.fromLTWH(12, size.height - 48, 36, 36), paint);
    canvas.drawRect(Rect.fromLTWH(18, size.height - 42, 24, 24), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(24, size.height - 36, 12, 12), paint);

    // Mocking some internal bits/codes
    final randColors = [
      true, false, true, true, false, true, false, false, true,
      false, true, false, true, true, false, false, true, false,
      true, true, false, true, false, true, true, false, true,
      false, false, true, true, false, true, false, true, false,
    ];

    int idx = 0;
    for (double x = 60; x < size.width - 48; x += 12) {
      for (double y = 12; y < size.height - 12; y += 12) {
        if (randColors[idx % randColors.length]) {
          canvas.drawRect(Rect.fromLTWH(x, y, 8, 8), paint);
        }
        idx++;
      }
    }
    for (double x = 12; x < 60; x += 12) {
      for (double y = 60; y < size.height - 48; y += 12) {
        if (randColors[idx % randColors.length]) {
          canvas.drawRect(Rect.fromLTWH(x, y, 8, 8), paint);
        }
        idx++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
