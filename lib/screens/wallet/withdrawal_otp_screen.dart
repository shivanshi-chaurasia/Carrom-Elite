import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class WithdrawalOtpScreen extends StatefulWidget {
  const WithdrawalOtpScreen({
    super.key,
    required this.withdrawAmount,
    required this.upiId,
  });

  final double withdrawAmount;
  final String upiId;

  @override
  State<WithdrawalOtpScreen> createState() => _WithdrawalOtpScreenState();
}

class _WithdrawalOtpScreenState extends State<WithdrawalOtpScreen> {
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 60;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isSuccess = false;
  late String _txnId;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Generate mock transaction ID
    _txnId = 'TXN-WDR-${100000 + Random().nextInt(900000)}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var ctrl in _otpCtrls) {
      ctrl.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
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

  void _confirmWithdrawal() {
    var otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() => _isVerifying = true);
    
    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessScreen();
    }

    var otpFilled = _otpCtrls.every((c) => c.text.isNotEmpty);
    var ready = otpFilled && !_isVerifying;

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
          'VERIFY WITHDRAWAL',
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 32),
              Text(
                'Enter the OTP sent to your registered mobile',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // OTP Digits Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (idx) {
                  return SizedBox(
                    width: 44,
                    height: 52,
                    child: TextField(
                      controller: _otpCtrls[idx],
                      focusNode: _otpFocusNodes[idx],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTypography.h2.copyWith(color: AppColors.teal),
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
                          borderSide: const BorderSide(color: AppColors.teal),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && idx < 5) {
                          _otpFocusNodes[idx + 1].requestFocus();
                        } else if (val.isEmpty && idx > 0) {
                          _otpFocusNodes[idx - 1].requestFocus();
                        }
                        setState(() {}); // refresh button state
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Countdown / Resend
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
                        _startCountdown();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP code resent successfully!')),
                        );
                      },
                      child: Text(
                        'RESEND',
                        style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 36),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: ready ? _confirmWithdrawal : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    disabledBackgroundColor: AppColors.line,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg),
                        )
                      : Text(
                          'CONFIRM WITHDRAWAL',
                          style: AppTypography.button.copyWith(
                            color: ready ? AppColors.bg : AppColors.textSoft,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Mask UPI (e.g. sh***@upi)
    String maskedUpi = widget.upiId;
    if (widget.upiId.contains('@')) {
      final parts = widget.upiId.split('@');
      if (parts[0].length > 2) {
        maskedUpi = '${parts[0].substring(0, 2)}***@${parts[1]}';
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TRANSFER SUMMARY', style: AppTypography.small.copyWith(color: AppColors.textSoft)),
              const Icon(Icons.swap_horiz_rounded, color: AppColors.gold, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Withdrawal Amount',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
              Text(
                '₹${widget.withdrawAmount.toStringAsFixed(2)}',
                style: AppTypography.h3.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destination UPI ID',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
              Text(
                maskedUpi,
                style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.teal, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.teal,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Withdrawal Initiated!', style: AppTypography.h2.copyWith(color: AppColors.teal)),
                  const SizedBox(height: 12),
                  Text(
                    'Your request to withdraw ₹${widget.withdrawAmount.toStringAsFixed(2)} has been queued. Funds should hit your account shortly.',
                    style: AppTypography.body.copyWith(color: AppColors.textMuted, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.line),
                  const SizedBox(height: 10),
                  _successRow('Transaction ID', _txnId),
                  _successRow('UPI Recipient', widget.upiId),
                  _successRow('Status', 'Processing'),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/wallet-dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'BACK TO WALLET',
                        style: AppTypography.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _successRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.small.copyWith(color: AppColors.textSoft)),
          Text(value, style: AppTypography.small.copyWith(color: AppColors.text, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
