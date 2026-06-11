import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/rewards_models.dart';
import '../../providers/rewards_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class VipMembershipScreen extends ConsumerStatefulWidget {
  const VipMembershipScreen({super.key});

  @override
  ConsumerState<VipMembershipScreen> createState() => _VipMembershipState();
}

class _VipMembershipState extends ConsumerState<VipMembershipScreen> {
  int selectedTierIdx = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardsProvider);
    final tiers = VipTierModel.mockTiers();

    // Determine current level and progress
    int currentLevelIdx = 0;
    int nextLevelIdx = 1;
    for (int i = 0; i < tiers.length; i++) {
      if (state.vipPoints >= tiers[i].pointsRequired) {
        currentLevelIdx = i;
        nextLevelIdx = (i + 1 < tiers.length) ? i + 1 : i;
      }
    }

    var currentTier = tiers[currentLevelIdx];
    var nextTier = tiers[nextLevelIdx];
    var pointsToNext = nextTier.pointsRequired - state.vipPoints;
    var progressPct = 1.0;
    if (nextLevelIdx != currentLevelIdx) {
      var range = nextTier.pointsRequired - currentTier.pointsRequired;
      var currentRelative = state.vipPoints - currentTier.pointsRequired;
      progressPct = range > 0 ? currentRelative / range : 1.0;
    }

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: 'VIP MEMBERSHIP',
            subtitle: 'Exclusive perks & loyalty club',
            onBack: context.pop,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildProgressCard(state.vipPoints, currentTier.title, nextTier.title, pointsToNext.toInt(), progressPct),
                const SizedBox(height: 24),
                _buildCarouselHeader(),
                const SizedBox(height: 12),
                _buildTiersCarousel(tiers, currentLevelIdx),
                const SizedBox(height: 24),
                _buildPerksList(tiers[selectedTierIdx]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int points, String currentTitle, String nextTitle, int needed, double progress) {
    bool isMax = needed <= 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT TIER', style: AppTypography.small),
                  const SizedBox(height: 2),
                  Text(currentTitle, style: AppTypography.h2.copyWith(color: AppColors.gold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('VIP POINTS', style: AppTypography.small),
                  const SizedBox(height: 2),
                  Text('$points pts', style: AppTypography.h2.copyWith(color: AppColors.teal)),
                ],
              ),
            ],
          ),
          const Divider(color: AppColors.line, height: 24),
          if (!isMax) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Next: $nextTitle', style: AppTypography.small.copyWith(color: AppColors.text)),
                Text('$needed pts needed', style: AppTypography.small.copyWith(color: AppColors.gold)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surface2,
                color: AppColors.gold,
              ),
            ),
          ] else ...[
            const Center(
              child: Text(
                '🎉 MAXIMUM VIP TIER ACHIEVED! 🎉',
                style: AppTypography.body,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCarouselHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'VIP TIER BENEFITS',
        style: AppTypography.small.copyWith(
          color: AppColors.teal,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTiersCarousel(List<VipTierModel> tiers, int userLevelIdx) {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _pageController,
        itemCount: tiers.length,
        onPageChanged: (idx) {
          setState(() {
            selectedTierIdx = idx;
          });
        },
        itemBuilder: (ctx, idx) {
          var tier = tiers[idx];
          bool isUserTier = idx == userLevelIdx;
          bool isLocked = idx > userLevelIdx;

          Color borderCol = isUserTier ? AppColors.gold : AppColors.line;
          Color titleCol = isLocked ? AppColors.textSoft : AppColors.text;

          Gradient cardGrad;
          if (idx == 3) {
            cardGrad = const LinearGradient(colors: [Color(0xFF2C1952), Color(0xFF1E3A52)]);
          } else if (idx == 2) {
            cardGrad = const LinearGradient(colors: [Color(0xFF332014), Color(0xFF1A112C)]);
          } else {
            cardGrad = const LinearGradient(colors: [AppColors.surface2, AppColors.card]);
          }

          return AnimatedScale(
            scale: idx == selectedTierIdx ? 1.0 : 0.94,
            duration: const Duration(milliseconds: 180),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: cardGrad,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol, width: isUserTier ? 2 : 1),
                boxShadow: [
                  if (idx == selectedTierIdx)
                    const BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tier.title.toUpperCase(),
                        style: AppTypography.h3.copyWith(color: titleCol, fontWeight: FontWeight.bold),
                      ),
                      if (isUserTier)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                          child: const Text('YOUR TIER', style: TextStyle(fontSize: 8, color: AppColors.bg, fontWeight: FontWeight.bold)),
                        )
                      else if (isLocked)
                        const Icon(Icons.lock_rounded, color: AppColors.textSoft, size: 16),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.cashbackPct > 0 ? '${tier.cashbackPct}% CashBack on Deposits' : 'Standard Tier benefits',
                        style: AppTypography.body.copyWith(color: isLocked ? AppColors.textSoft : AppColors.teal, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLocked ? '${tier.pointsRequired} pts required' : 'Perks unlocked!',
                        style: AppTypography.small,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerksList(VipTierModel tier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                '${tier.title} Perks Details',
                style: AppTypography.h3.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const Divider(color: AppColors.line, height: 24),
          ...tier.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.teal, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        benefit,
                        style: AppTypography.body.copyWith(color: AppColors.text),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
