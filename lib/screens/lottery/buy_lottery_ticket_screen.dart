import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class BuyLotteryTicketScreen extends StatefulWidget {
  const BuyLotteryTicketScreen({
    super.key,
    this.lotteryName = 'Mega Jackpot Sweepstakes',
    this.jackpotAmount = 50000,
  });

  final String lotteryName;
  final int jackpotAmount;

  @override
  State<BuyLotteryTicketScreen> createState() => _BuyLotteryTicketScreenState();
}

class _BuyLotteryTicketScreenState extends State<BuyLotteryTicketScreen> {
  final List<int> _selectedNumbers = [];
  int _walletBalance = 2450;
  final int _ticketPrice = 50;

  void _navigateToNumberSelect() async {
    final result = await context.push<dynamic>('/lottery-number-select');
    if (result != null && result is List) {
      setState(() {
        _selectedNumbers.clear();
        _selectedNumbers.addAll(result.cast<int>());
      });
    }
  }

  void _purchaseTicket() {
    if (_selectedNumbers.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly 6 numbers.')),
      );
      return;
    }
    
    if (_walletBalance < _ticketPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient wallet balance.')),
      );
      return;
    }

    setState(() {
      _walletBalance -= _ticketPrice;
    });

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.green),
            SizedBox(width: 8),
            Text('Ticket Purchased!', style: AppTypography.h3),
          ],
        ),
        content: Text(
          'Your ticket with numbers ${_selectedNumbers.join(', ')} has been successfully booked.\n\nNew balance: ₹$_walletBalance',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(
              'OK',
              style: AppTypography.body.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var ready = _selectedNumbers.length == 6;

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
          'BUY TICKET',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildJackpotHeader(),
            const SizedBox(height: 24),

            // Visual Card Selector
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: InkWell(
                    onTap: _navigateToNumberSelect,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedNumbers.isEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.casino_rounded,
                                color: AppColors.gold,
                                size: 54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Choose Your Lucky Numbers',
                              style: AppTypography.h2.copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pick 6 numbers to purchase your jackpot ticket. Tap here to open the selection board.',
                              style: AppTypography.body.copyWith(color: AppColors.textSoft),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            ElevatedButton(
                              onPressed: _navigateToNumberSelect,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: Text(
                                'OPEN SELECTOR',
                                style: AppTypography.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ] else ...[
                            Text(
                              'YOUR SELECTED NUMBERS',
                              style: AppTypography.small.copyWith(
                                color: AppColors.teal,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _selectedNumbers.map((n) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.purple, AppColors.gold],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$n',
                                    style: AppTypography.body.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Tap here to change numbers',
                              style: AppTypography.small.copyWith(color: AppColors.textSoft),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Purchase Actions panel
            _buildPurchasePanel(ready),
          ],
        ),
      ),
    );
  }

  Widget _buildJackpotHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.lotteryName, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'Jackpot: ₹${widget.jackpotAmount}',
                  style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('WALLET BALANCE', style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 9)),
              Text('₹$_walletBalance', style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasePanel(bool ready) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ticket Price:', style: AppTypography.body),
              Text('₹$_ticketPrice', style: AppTypography.body.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: AppColors.line, height: 20),
          _gradientButton('BUY NOW', ready ? _purchaseTicket : null),
        ],
      ),
    );
  }

  Widget _gradientButton(String label, VoidCallback? onPressed) {
    final enabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [AppColors.gold, AppColors.goldDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: enabled ? null : AppColors.line,
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
          style: AppTypography.button.copyWith(
            color: enabled ? Colors.black : AppColors.textSoft,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
