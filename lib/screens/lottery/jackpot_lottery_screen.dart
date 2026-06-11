import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class JackpotLotteryScreen extends StatefulWidget {
  const JackpotLotteryScreen({super.key});

  @override
  State<JackpotLotteryScreen> createState() => _JackpotLotteryScreenState();
}

class _JackpotLotteryScreenState extends State<JackpotLotteryScreen> {
  Timer? _accumulatorTimer;
  Timer? _countdownTimer;
  int _jackpotAmount = 502450;
  int _secondsRemaining = 24800; // ~6.8 hours mock countdown
  final int _ownedTickets = 4;

  @override
  void initState() {
    super.initState();
    
    // Increment jackpot amount slowly to simulate accumulator
    _accumulatorTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      setState(() {
        _jackpotAmount += 15; // increment jackpot by ₹15
      });
    });

    // Countdown draw timer ticks
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        }
      });
    });
  }

  @override
  void dispose() {
    _accumulatorTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    int h = totalSecs ~/ 3600;
    int m = (totalSecs % 3600) ~/ 60;
    int s = totalSecs % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
          'MEGA BUMPER JACKPOT',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            children: [
              _buildJackpotCard(),
              const SizedBox(height: 24),
              _buildTicketsStatusCard(),
              const Spacer(),
              _buildDetailsGrid(),
              const Spacer(),
              
              // Action Button
              _gradientButton('BUY MORE TICKETS', () {
                context.push(
                  '/buy-lottery-ticket?name=${Uri.encodeComponent("Mega Bumper Jackpot")}&jackpot=$_jackpotAmount',
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJackpotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'LIVE JACKPOT ACCUMULATOR',
            style: AppTypography.small.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '₹$_jackpotAmount',
            style: AppTypography.h1.copyWith(
              fontSize: 42,
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_rounded, color: AppColors.red, size: 16),
              const SizedBox(width: 6),
              Text(
                'Draw starts in: ',
                style: AppTypography.small.copyWith(color: AppColors.textSoft),
              ),
              Text(
                _formatTime(_secondsRemaining),
                style: AppTypography.small.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.confirmation_number_rounded, color: AppColors.purple, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR ACTIVE TICKETS',
                  style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'You own $_ownedTickets tickets for this draw.',
                  style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        _detailsRow('Draw Date', '14 June 2026, 08:00 PM'),
        const SizedBox(height: 12),
        _detailsRow('Ticket Entry Cost', '₹100 per Ticket'),
        const SizedBox(height: 12),
        _detailsRow('TDS Deduction', '28% flat tax on winnings'),
      ],
    );
  }

  Widget _detailsRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTypography.small.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
        ],
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
}
