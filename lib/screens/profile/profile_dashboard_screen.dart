import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/home_providers.dart';
import '../../providers/rewards_providers.dart';
import '../../providers/social_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class ProfileDashboardScreen extends ConsumerWidget {
  const ProfileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeDashboardProvider);
    final rewardsState = ref.watch(rewardsProvider);
    final friends = ref.watch(friendsProvider);

    return AppScaffold(
      currentIndex: 4,
      child: Column(
        children: [
          const GamingAppBar(
            title: 'MY PROFILE',
            subtitle: 'Player stats & account hub',
          ),
          Expanded(
            child: homeState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => Center(child: Text('Error loading dashboard: $err')),
              data: (dashboard) {
                var p = dashboard.player;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildPlayerCard(p, rewardsState.vipPoints),
                    const SizedBox(height: 16),
                    _buildStatsRow(p.winRate.toString()),
                    const SizedBox(height: 24),
                    _buildSectionHeader('MY CAREER & SOCIAL'),
                    const SizedBox(height: 8),
                    _buildSocialGrid(context, rewardsState.coins, friends.length),
                    const SizedBox(height: 24),
                    _buildSectionHeader('SECURITY & BANKING'),
                    const SizedBox(height: 8),
                    _buildSettingsList(context),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(var player, int vipPoints) {
    // Determine VIP tier
    String vipTier = 'Bronze Star';
    Color tierColor = AppColors.textSoft;
    if (vipPoints >= 5000) {
      vipTier = 'Platinum Legend 👑';
      tierColor = AppColors.teal;
    } else if (vipPoints >= 2000) {
      vipTier = 'Gold VIP 💎';
      tierColor = AppColors.gold;
    } else if (vipPoints >= 500) {
      vipTier = 'Silver Elite 🛡️';
      tierColor = AppColors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.purple,
            child: Text(
              player.name.substring(0, 1).toUpperCase(),
              style: AppTypography.h1.copyWith(fontSize: 32, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: AppTypography.h2),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Text(
                        'Lv ${player.level}',
                        style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      vipTier,
                      style: AppTypography.small.copyWith(color: tierColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String winRate) {
    return Row(
      children: [
        Expanded(
          child: _statTile('WIN RATE', winRate, Icons.trending_up, AppColors.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile('MATCHES', '47 Played', Icons.sports_esports_rounded, AppColors.blue),
        ),
      ],
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.small.copyWith(fontSize: 10)),
              const SizedBox(height: 2),
              Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.small.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildSocialGrid(BuildContext context, int coins, int friendsCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _gridCard(
          context,
          'Rewards Center',
          '$coins Play Coins',
          Icons.emoji_events_rounded,
          AppColors.gold,
          '/rewards-center',
        ),
        _gridCard(
          context,
          'Refer & Earn',
          'Code: SHIV99A',
          Icons.people_alt_rounded,
          AppColors.purple,
          '/referral-program',
        ),
        _gridCard(
          context,
          'VIP Tiers',
          'View Rewards',
          Icons.workspace_premium_rounded,
          AppColors.teal,
          '/vip-membership',
        ),
        _gridCard(
          context,
          'Friends & Chat',
          '$friendsCount friends',
          Icons.chat_bubble_rounded,
          AppColors.blue,
          '/friends',
        ),
      ],
    );
  }

  Widget _gridCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    Color color,
    String path,
  ) {
    return InkWell(
      onTap: () => context.push(path),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                const Icon(Icons.arrow_outward_rounded, color: AppColors.textSoft, size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.small),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _menuListTile(context, 'KYC Verification', 'Verify Aadhaar & PAN card', Icons.verified_user_rounded, '/kyc-verify'),
        _menuListTile(context, 'Bank Account Details', 'Manage cash withdrawal accounts', Icons.account_balance_rounded, '/bank-details'),
        _menuListTile(context, 'Community Feed', 'Check posts, updates and strategies', Icons.feed_rounded, '/community'),
        _menuListTile(context, 'App Settings & Support', 'Audio, graphics, 2FA, live support & FAQs', Icons.settings_rounded, '/settings-dashboard'),
      ],
    );
  }

  Widget _menuListTile(BuildContext context, String title, String desc, IconData icon, String path) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      child: ListTile(
        onTap: () => context.push(path),
        leading: Icon(icon, color: AppColors.purple, size: 20),
        title: Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
        subtitle: Text(desc, style: AppTypography.small),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSoft),
        dense: true,
      ),
    );
  }
}
