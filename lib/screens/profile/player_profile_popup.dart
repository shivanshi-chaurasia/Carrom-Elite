import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class PlayerProfilePopupScreen extends StatelessWidget {
  const PlayerProfilePopupScreen({
    super.key,
    required this.name,
    required this.level,
    required this.winRate,
    required this.matches,
    required this.countryFlag,
  });

  final String name;
  final int level;
  final double winRate;
  final int matches;
  final String countryFlag;

  // Helper static function to display popup
  static void show(
    BuildContext context, {
    required String name,
    required int level,
    required double winRate,
    required int matches,
    required String countryFlag,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlayerProfilePopupScreen(
        name: name,
        level: level,
        winRate: winRate,
        matches: matches,
        countryFlag: countryFlag,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Player Avatar & Basic Info
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.purple,
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: AppTypography.h1.copyWith(fontSize: 32, color: AppColors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: AppTypography.h2),
                        const SizedBox(width: 8),
                        Text(countryFlag, style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Text(
                        'LEVEL $level',
                        style: AppTypography.small.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),

          // Player Statistics row
          Row(
            children: [
              Expanded(
                child: _statCard('WIN RATE', '${winRate.toInt()}%', Icons.trending_up_rounded, AppColors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('TOTAL BATTLES', '$matches matches', Icons.sports_esports_rounded, AppColors.blue),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Invite Button
          _gradientButton(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.small.copyWith(fontSize: 10)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradientButton(BuildContext context) {
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
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sent match invitation to $name!')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'INVITE TO MATCH',
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
