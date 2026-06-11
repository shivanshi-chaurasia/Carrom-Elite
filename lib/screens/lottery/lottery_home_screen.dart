import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/lottery_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class LotteryHomeScreen extends ConsumerWidget {
  const LotteryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeLotteriesProvider);

    return AppScaffold(
      currentIndex: 2,
      child: Column(
        children: [
          GamingAppBar(
            title: 'MEGA LOTTERY',
            subtitle: 'Try your luck today',
            onBack: () => context.go('/'),
          ),
          _buildQuickActions(context),
          _buildWinnerBanner(context),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(activeLotteriesProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const AppEmptyView(subtitle: 'No active lotteries at the moment.');
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  itemBuilder: (ctx, i) => _buildLotteryCard(context, items[i]),
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
                  itemCount: items.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'StrikerKing won ₹1,00,000 Jackpot! 🎉',
              style: AppTypography.small.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => _showWinnerDialog(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'VIEW',
              style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showWinnerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 28),
            const SizedBox(width: 8),
            Text('JACKPOT WINNER!', style: AppTypography.h2.copyWith(color: AppColors.gold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_people_rounded, size: 54, color: AppColors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              'StrikerKing',
              style: AppTypography.h1.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              'Won the Mega Jackpot Pool',
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            Text(
              '₹1,00,000',
              style: AppTypography.h1.copyWith(fontSize: 36, color: AppColors.teal),
            ),
            const SizedBox(height: 16),
            Text(
              'Winning Numbers:',
              style: AppTypography.small.copyWith(color: AppColors.textSoft),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [2, 11, 15, 22, 28, 33]
                  .map((n) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surface,
                          child: Text(
                            n.toString(),
                            style: AppTypography.small.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CONGRATS!', style: AppTypography.body.copyWith(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _actionCard(
              context,
              label: 'My Tickets',
              icon: Icons.confirmation_number_rounded,
              color: AppColors.gold,
              path: '/lottery-tickets',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionCard(
              context,
              label: 'Results',
              icon: Icons.assignment_turned_in_rounded,
              color: AppColors.teal,
              path: '/lottery-results',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionCard(
              context,
              label: 'Winners',
              icon: Icons.emoji_events_rounded,
              color: AppColors.purple,
              path: '/previous-winners',
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String path,
  }) {
    return InkWell(
      onTap: () => context.push(path),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLotteryCard(BuildContext context, var item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.15),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              _DrawCountdown(drawTime: item.drawTime),
            ],
          ),
          const SizedBox(height: 12),
          const Text('JACKPOT POOL', style: AppTypography.small),
          const SizedBox(height: 4),
          Text(
            AppFormatters.money(item.jackpot),
            style: AppTypography.h1.copyWith(
              fontSize: 32,
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ticket Price', style: AppTypography.small),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.money(item.ticketPrice),
                    style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/lottery-detail/${item.id}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: AppColors.text,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'BUY TICKET',
                  style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawCountdown extends StatefulWidget {
  const _DrawCountdown({required this.drawTime});

  final String drawTime;

  @override
  State<_DrawCountdown> createState() => _DrawCountdownState();
}

class _DrawCountdownState extends State<_DrawCountdown> {
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _parseTimeToSeconds(widget.drawTime);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _parseTimeToSeconds(String timeStr) {
    var parts = timeStr.trim().split(' ');
    var totalSec = 0;
    for (var part in parts) {
      if (part.endsWith('d')) {
        var days = int.tryParse(part.replaceAll('d', '')) ?? 0;
        totalSec += days * 86400;
      } else if (part.endsWith('h')) {
        var hours = int.tryParse(part.replaceAll('h', '')) ?? 0;
        totalSec += hours * 3600;
      } else if (part.endsWith('m')) {
        var minutes = int.tryParse(part.replaceAll('m', '')) ?? 0;
        totalSec += minutes * 60;
      } else if (part.endsWith('s')) {
        var seconds = int.tryParse(part.replaceAll('s', '')) ?? 0;
        totalSec += seconds;
      }
    }
    return totalSec > 0 ? totalSec : 3600; // default 1 hr
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatDuration() {
    if (_secondsRemaining <= 0) return 'Drawing Now';
    var d = _secondsRemaining ~/ 86400;
    var h = (_secondsRemaining % 86400) ~/ 3600;
    var m = (_secondsRemaining % 3600) ~/ 60;
    var s = _secondsRemaining % 60;

    var res = '';
    if (d > 0) res += '${d}d ';
    if (h > 0 || d > 0) res += '${h.toString().padLeft(2, '0')}h ';
    res += '${m.toString().padLeft(2, '0')}m ';
    res += '${s.toString().padLeft(2, '0')}s';
    return res.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_filled_rounded, color: AppColors.gold, size: 12),
          const SizedBox(width: 4),
          Text(
            _formatDuration(),
            style: AppTypography.small.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
