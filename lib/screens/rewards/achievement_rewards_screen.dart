import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class AchievementRewardsScreen extends StatelessWidget {
  const AchievementRewardsScreen({super.key});

  final List<Map<String, dynamic>> _achievements = const [
    {
      'id': 'a1',
      'title': 'First Victory',
      'desc': 'Won your first 1v1 online cash game.',
      'unlocked': true,
      'date': '12 May 2026',
      'reward': 100,
      'icon': Icons.emoji_events_rounded,
      'color': AppColors.gold,
    },
    {
      'id': 'a2',
      'title': 'Accuracy King',
      'desc': 'Achieved over 90% shot accuracy in a single match.',
      'unlocked': true,
      'date': '18 May 2026',
      'reward': 150,
      'icon': Icons.my_location_rounded,
      'color': AppColors.teal,
    },
    {
      'id': 'a3',
      'title': 'Tournament Master',
      'desc': 'Placed 1st in any Grand Hour Bracket tournament.',
      'unlocked': false,
      'date': '',
      'reward': 500,
      'icon': Icons.workspace_premium_rounded,
      'color': AppColors.purple,
    },
    {
      'id': 'a4',
      'title': 'Wealthy Player',
      'desc': 'Wallet deposits exceeded ₹5,000 in total.',
      'unlocked': false,
      'date': '',
      'reward': 300,
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.green,
    },
    {
      'id': 'a5',
      'title': 'Streak Legend',
      'desc': 'Maintained a win streak of 10 consecutive matches.',
      'unlocked': true,
      'date': '04 June 2026',
      'reward': 250,
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.red,
    },
    {
      'id': 'a6',
      'title': 'Social Butterfly',
      'desc': 'Referred 5 friends who completed mobile verification.',
      'unlocked': false,
      'date': '',
      'reward': 200,
      'icon': Icons.people_rounded,
      'color': AppColors.blue,
    },
  ];

  void _showAchievementDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
        title: Row(
          children: [
            Icon(item['icon'] as IconData, color: item['color'] as Color),
            const SizedBox(width: 8),
            Text(item['title'] as String, style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['desc'] as String, style: AppTypography.body),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date Earned:', style: AppTypography.small.copyWith(color: AppColors.textSoft)),
                Text(item['date'] as String, style: AppTypography.small.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reward Claimed:', style: AppTypography.small.copyWith(color: AppColors.textSoft)),
                Text('+${item['reward']} XP & Coins', style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CLOSE', style: AppTypography.body.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
          'BADGES & ACHIEVEMENTS',
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Complete special milestones to unlock elite glowing badges and claim XP rewards.',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            
            // Badges Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemCount: _achievements.length,
                itemBuilder: (ctx, idx) {
                  final item = _achievements[idx];
                  final unlocked = item['unlocked'] as bool;
                  final badgeColor = item['color'] as Color;

                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: unlocked ? badgeColor : AppColors.line,
                        width: unlocked ? 1.5 : 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: unlocked ? () => _showAchievementDialog(context, item) : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: unlocked
                              ? [
                                  BoxShadow(
                                    color: badgeColor.withOpacity(0.08),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: unlocked ? badgeColor.withOpacity(0.12) : AppColors.bg,
                              child: Icon(
                                unlocked ? (item['icon'] as IconData) : Icons.lock_outline_rounded,
                                color: unlocked ? badgeColor : AppColors.textSoft,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['title'] as String,
                              style: AppTypography.small.copyWith(
                                color: unlocked ? AppColors.white : AppColors.textSoft,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              unlocked ? 'Tap for info' : 'Locked',
                              style: AppTypography.small.copyWith(
                                color: unlocked ? AppColors.teal : AppColors.textSoft,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
