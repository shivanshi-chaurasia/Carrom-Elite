import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PageController _pageController = PageController();
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  int _resendCountdown = 60;
  Timer? _timer;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isResettingPassword = false;

  @override
  void dispose() {
    _pageController.dispose();
    _phoneCtrl.dispose();
    for (var ctrl in _otpCtrls) {
      ctrl.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _sendOtp() {
    if (_phoneCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }
    setState(() => _isSendingOtp = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      _startResendTimer();
    });
  }

  void _verifyOtp() {
    var otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }
    setState(() => _isVerifyingOtp = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isVerifyingOtp = false);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  void _resetPassword() {
    var p1 = _newPassCtrl.text;
    var p2 = _confirmPassCtrl.text;
    if (p1.isEmpty || p1.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isResettingPassword = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isResettingPassword = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.teal,
          content: Text(
            'Password reset successful! Please login.',
            style: AppTypography.body.copyWith(color: AppColors.surface, fontWeight: FontWeight.bold),
          ),
        ),
      );
      context.go('/login');
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
          onPressed: () {
            if (_pageController.page == 0) {
              context.pop();
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
        ),
        title: Text(
          'RESET PASSWORD',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStep1PhoneInput(),
            _buildStep2OtpVerify(),
            _buildStep3PasswordReset(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1PhoneInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.lock_reset_rounded, size: 54, color: AppColors.gold),
          const SizedBox(height: 16),
          const Text('Verification Required', style: AppTypography.h1),
          const SizedBox(height: 8),
          Text(
            'Enter your registered phone number to receive a one-time verification password (OTP).',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          Text(
            'PHONE NUMBER',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter 10-digit mobile number',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              prefixText: '+91 ',
              prefixStyle: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            label: _isSendingOtp ? 'SENDING OTP...' : 'SEND OTP',
            onPressed: _isSendingOtp ? null : _sendOtp,
            isLoading: _isSendingOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2OtpVerify() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.security_rounded, size: 54, color: AppColors.teal),
          const SizedBox(height: 16),
          const Text('Enter Code', style: AppTypography.h1),
          const SizedBox(height: 8),
          Text(
            'We sent a 6-digit OTP verification code to +91 ${_phoneCtrl.text}.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (idx) {
              return SizedBox(
                width: 46,
                height: 54,
                child: TextField(
                  controller: _otpCtrls[idx],
                  focusNode: _otpFocusNodes[idx],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: AppTypography.h2.copyWith(color: AppColors.gold),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && idx < 5) {
                      _otpFocusNodes[idx + 1].requestFocus();
                    } else if (val.isEmpty && idx > 0) {
                      _otpFocusNodes[idx - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _resendCountdown > 0 ? 'Resend code in ${_resendCountdown}s' : 'Didn\'t receive code?',
                style: AppTypography.small.copyWith(color: AppColors.textMuted),
              ),
              if (_resendCountdown == 0)
                TextButton(
                  onPressed: () {
                    _startResendTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP code resent successfully!')),
                    );
                  },
                  child: Text(
                    'RESEND',
                    style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                )
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            label: _isVerifyingOtp ? 'VERIFYING...' : 'VERIFY OTP',
            onPressed: _isVerifyingOtp ? null : _verifyOtp,
            isLoading: _isVerifyingOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3PasswordReset() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.vpn_key_rounded, size: 54, color: AppColors.purple),
          const SizedBox(height: 16),
          const Text('New Password', style: AppTypography.h1),
          const SizedBox(height: 8),
          Text(
            'Choose a strong password with at least 6 characters.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          _buildPassField(
            label: 'NEW PASSWORD',
            controller: _newPassCtrl,
            hint: 'Enter new password',
          ),
          const SizedBox(height: 18),
          _buildPassField(
            label: 'CONFIRM NEW PASSWORD',
            controller: _confirmPassCtrl,
            hint: 'Re-enter new password',
          ),
          const SizedBox(height: 36),
          _buildActionButton(
            label: _isResettingPassword ? 'RESETTING...' : 'RESET PASSWORD',
            onPressed: _isResettingPassword ? null : _resetPassword,
            isLoading: _isResettingPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildPassField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          style: AppTypography.body.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.purple),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                colors: [AppColors.gold, AppColors.goldDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        color: onPressed == null ? AppColors.line : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.black),
              )
            : Text(
                label,
                style: AppTypography.button.copyWith(
                  color: onPressed == null ? AppColors.textSoft : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
