import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class ActiveLotteryScreen extends StatefulWidget {
  const ActiveLotteryScreen({super.key});

  @override
  State<ActiveLotteryScreen> createState() => _ActiveLotteryScreenState();
}

class _ActiveLotteryScreenState extends State<ActiveLotteryScreen> {
  Timer? _timer;
  int _secondsRemaining = 12400; // ~3.5 hours mock countdown
  bool _isLoading = false;

  final List<Map<String, dynamic>> _lotteries = [
    {
      'name': 'Gold Mega Draw',
      'jackpot': 50000,
      'sold': 282,
      'total': 500,
    },
    {
      'name': 'Super Sunday Sweep',
      'jackpot': 100000,
      'sold': 641,
      'total': 1000,
    },
    {
      'name': 'Mini Fast Pick',
      'jackpot': 15000,
      'sold': 94,
      'total': 150,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    int h = totalSecs ~/ 3600;
    int m = (totalSecs % 3600) ~/ 60;
    int s = totalSecs % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
          'ACTIVE LOTTERIES',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.gold,
        backgroundColor: AppColors.surface,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _lotteries.length,
                itemBuilder: (ctx, idx) {
                  final item = _lotteries[idx];
                  return _buildLotteryCard(item);
                },
              ),
      ),
    );
  }

  Widget _buildLotteryCard(Map<String, dynamic> item) {
    final sold = item['sold'] as int;
    final total = item['total'] as int;
    final name = item['name'] as String;
    final jackpot = item['jackpot'] as int;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: AppTypography.h3.copyWith(color: AppColors.white)),
                Text(
                  _formatTime(_secondsRemaining),
                  style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Jackpot value display
            Row(
              children: [
                Text('JACKPOT:', style: AppTypography.small.copyWith(color: AppColors.textSoft)),
                const SizedBox(width: 6),
                Text('₹$jackpot', style: AppTypography.body.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            
            // Capacity / Tickets progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: sold / total,
                      minHeight: 6,
                      backgroundColor: AppColors.bg,
                      color: AppColors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$sold/$total',
                  style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const Divider(color: AppColors.line, height: 28),

            // Buy Tickets Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/buy-lottery-ticket?name=${Uri.encodeComponent(name)}&jackpot=$jackpot');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'BUY LOTTERY TICKET',
                  style: AppTypography.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
