import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class MatchStatisticsScreen extends StatelessWidget {
  const MatchStatisticsScreen({
    super.key,
    this.winnerName = 'Shiva (You)',
    this.p1Name = 'Shiva (You)',
    this.p2Name = 'StrikerKing',
  });

  final String winnerName;
  final String p1Name;
  final String p2Name;

  @override
  Widget build(BuildContext context) {
    // Mock Statistics values
    const p1Coins = 9;
    const p2Coins = 5;
    const p1Fouls = 1;
    const p2Fouls = 3;
    const p1Accuracy = 84.0;
    const p2Accuracy = 62.0;
    const p1Time = '04:15';
    const p2Time = '05:02';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Winner Banner
              _buildWinnerBanner(),
              const SizedBox(height: 24),
              
              // Comparison Table Header
              _buildTableHeader(),
              const SizedBox(height: 12),

              // Stats Row List
              _buildStatRow('Coins Potted', '$p1Coins', '$p2Coins', p1Coins / (p1Coins + p2Coins)),
              _buildStatRow('Fouls Committed', '$p1Fouls', '$p2Fouls', p2Fouls / (p1Fouls + p2Fouls + 1)), // invert ratio comparison
              _buildStatRow('Shot Accuracy', '${p1Accuracy.toInt()}%', '${p2Accuracy.toInt()}%', p1Accuracy / (p1Accuracy + p2Accuracy)),
              _buildStatRow('Avg Shot Time', p1Time, p2Time, 0.55), // mock middle ratio

              const SizedBox(height: 28),
              
              // Chart Section
              _buildChartSection(p1Coins, p2Coins, p1Accuracy, p2Accuracy),
              
              const SizedBox(height: 36),

              // Action Buttons
              _buildActionRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 56),
          const SizedBox(height: 12),
          Text(
            'VICTORY!',
            style: AppTypography.h1.copyWith(color: AppColors.gold, letterSpacing: 2, fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            '$winnerName won the battle',
            style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '+180 Coins Credited',
            style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            p1Name.toUpperCase(),
            style: AppTypography.small.copyWith(color: AppColors.purple, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          'MATCH STATS',
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            p2Name.toUpperCase(),
            style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String title, String val1, String val2, double ratio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(val1, style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
              Text(title, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
              Text(val2, style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          
          // Custom progress bar chart built using Containers
          Row(
            children: [
              Expanded(
                flex: (ratio * 100).toInt().clamp(1, 99),
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)),
                  ),
                ),
              ),
              Expanded(
                flex: ((1 - ratio) * 100).toInt().clamp(1, 99),
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(2), bottomRight: Radius.circular(2)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(int c1, int c2, double a1, double a2) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE ACCURACY',
            style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Player 1 bar
          Text(p1Name, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          _horizontalChartBar(a1 / 100, AppColors.purple),
          
          const SizedBox(height: 14),

          // Player 2 bar
          Text(p2Name, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          _horizontalChartBar(a2 / 100, AppColors.teal),
        ],
      ),
    );
  }

  Widget _horizontalChartBar(double value, Color color) {
    return Row(
      children: [
        Expanded(
          flex: (value * 100).toInt(),
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        Expanded(
          flex: ((1 - value) * 100).toInt().clamp(1, 100),
          child: const SizedBox(),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: AppTypography.small.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'BACK TO HOME',
                style: AppTypography.button.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
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
              onPressed: () {
                // Mock request rematch
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rematch request sent to opponent!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'PLAY REMATCH',
                style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
