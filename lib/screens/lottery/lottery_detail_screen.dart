import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/lottery_providers.dart';
import '../../providers/service_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class LotteryDetailScreen extends ConsumerStatefulWidget {
  const LotteryDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<LotteryDetailScreen> createState() => _LotteryDetailState();
}

class _LotteryDetailState extends ConsumerState<LotteryDetailScreen> {
  final List<int> selectedNumbers = [];
  final int maxNumbers = 6;
  final int totalPool = 36;
  bool isPurchasing = false;

  void _toggleNumber(int number) {
    if (selectedNumbers.contains(number)) {
      setState(() => selectedNumbers.remove(number));
    } else {
      if (selectedNumbers.length < maxNumbers) {
        setState(() => selectedNumbers.add(number));
      }
    }
  }

  void _quickPick() {
    var rng = Random();
    var picks = <int>{};
    while (picks.length < maxNumbers) {
      picks.add(1 + rng.nextInt(totalPool));
    }
    setState(() {
      selectedNumbers.clear();
      selectedNumbers.addAll(picks);
    });
  }

  Future<void> _buyTicket() async {
    if (selectedNumbers.length != maxNumbers) return;

    setState(() => isPurchasing = true);
    var success = await ref.read(lotteryServiceProvider).buyTicket(
          lotteryId: widget.id,
          numbers: selectedNumbers,
        );

    if (success) {
      ref.invalidate(ticketHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket purchased successfully!'),
            backgroundColor: AppColors.teal,
          ),
        );
        context.pop();
      }
    } else {
      setState(() => isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var ready = selectedNumbers.length == maxNumbers;

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(
            title: 'NUMBER SELECTION',
            subtitle: 'Pick $maxNumbers numbers to enter',
            onBack: context.pop,
          ),
          _buildSelectionStatus(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: totalPool,
              itemBuilder: (ctx, i) {
                var numVal = i + 1;
                var isSel = selectedNumbers.contains(numVal);
                return GestureDetector(
                  onTap: () => _toggleNumber(numVal),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.purple : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSel ? AppColors.purple : AppColors.line,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        numVal.toString(),
                        style: AppTypography.h3.copyWith(
                          color: isSel ? AppColors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildActionFooter(ready),
        ],
      ),
    );
  }

  Widget _buildSelectionStatus() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Selected: ${selectedNumbers.length} / $maxNumbers',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: _quickPick,
            icon: const Icon(Icons.flash_on_rounded, color: AppColors.gold, size: 18),
            label: Text(
              'QUICK PICK',
              style: AppTypography.small.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(bool ready) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ready) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: selectedNumbers
                    .map((n) => CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.purple.withValues(alpha: 0.15),
                          child: Text(
                            n.toString(),
                            style: AppTypography.small.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          ElevatedButton(
            onPressed: ready && !isPurchasing ? _buyTicket : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.text,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: isPurchasing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  )
                : Text(
                    ready ? 'BUY TICKET NOW' : 'SELECT 6 NUMBERS',
                    style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
