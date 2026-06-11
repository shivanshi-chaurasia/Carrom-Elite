import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/home_models.dart';
import '../../providers/home_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/cards/game_card.dart';
import '../../widgets/cards/lottery_card.dart';
import '../../widgets/cards/promo_card.dart';
import '../../widgets/cards/reward_card.dart';
import '../../widgets/cards/tournament_card.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/state_views.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    return AppScaffold(
      child: state.when(
        loading: _loading,
        error: (err, stack) => AppErrorView(
          message: err.toString(),
          onRetry: () => ref.read(homeDashboardProvider.notifier).reload(),
        ),
        data: (data) => data.featuredGames.isEmpty
            ? const AppEmptyView(subtitle: 'Games and rewards will appear here soon.')
            : RefreshIndicator(
                onRefresh: () => ref.read(homeDashboardProvider.notifier).reload(),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 22),
                  children: [
                    GamingAppBar(
                      title: AppStrings.appName,
                      subtitle: '${AppStrings.goodEvening}, ${data.player.name}',
                    ),
                    _WalletStrip(data: data),
                    _QuickEntry(onTap: () => context.push(AppRoutes.quickMatch)),
                    const SizedBox(height: 8),
                    if (data.promos.isNotEmpty)
                      PromoCard(
                        promo: data.promos.first,
                        onTap: () => context.push(AppRoutes.promoDetails),
                      ),
                    SectionHeader(
                      title: AppStrings.featuredGames,
                      action: 'View all',
                      onTap: () => context.push(AppRoutes.featuredGames),
                    ),
                    _GameList(items: data.featuredGames),
                    SectionHeader(
                      title: AppStrings.tournaments,
                      action: 'Open',
                      onTap: () => context.push(AppRoutes.tournamentBanners),
                    ),
                    _TournamentList(items: data.tournaments),
                    SectionHeader(
                      title: AppStrings.lotteryHighlights,
                      action: 'More',
                      onTap: () => context.push(AppRoutes.lotteryHighlights),
                    ),
                    _LotteryList(items: data.lotteryHighlights.take(2).toList()),
                    SectionHeader(
                      title: AppStrings.dailyRewards,
                      action: 'Claim',
                      onTap: () => context.push(AppRoutes.dailyRewards),
                    ),
                    _RewardsList(items: data.dailyRewards),
                    SectionHeader(
                      title: AppStrings.eventPopups,
                      action: 'See',
                      onTap: () => context.push(AppRoutes.eventPopup),
                    ),
                    ...data.events.map(_EventTile.new),
                    SectionHeader(title: AppStrings.news),
                    ...data.news.map((n) => _NewsTile(item: n)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _loading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      children: const [
        SkeletonLine(width: 190, height: 24),
        SizedBox(height: 22),
        SkeletonLine(height: 84),
        SizedBox(height: 18),
        SkeletonLine(height: 112),
        SizedBox(height: 18),
        SkeletonLine(width: 150, height: 20),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SkeletonLine(height: 155)),
            SizedBox(width: 12),
            Expanded(child: SkeletonLine(height: 155)),
          ],
        ),
        SizedBox(height: 18),
        SkeletonLine(height: 150),
      ],
    );
  }
}

class _WalletStrip extends StatelessWidget {
  const _WalletStrip({required this.data});

  final HomeDashboardModel data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.walletDashboard),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 6, 18, 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: AppColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppFormatters.money(data.wallet.total), style: AppTypography.h3),
                  Text('Deposit + winnings + bonus', style: AppTypography.small),
                ],
              ),
            ),
            Text('Lv ${data.player.level}', style: AppTypography.h3.copyWith(color: AppColors.teal)),
          ],
        ),
      ),
    );
  }
}

class _QuickEntry extends StatelessWidget {
  const _QuickEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.flash_on_rounded),
        label: const Text(AppStrings.quickMatch),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _GameList extends StatelessWidget {
  const _GameList({required this.items});

  final List<GameCardModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) => GameCard(
          game: items[i],
          onTap: () => context.push(AppRoutes.quickMatch),
        ),
        separatorBuilder: (ctx, idx) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _TournamentList extends StatelessWidget {
  const _TournamentList({required this.items});

  final List<TournamentBannerModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) => TournamentCard(item: items[i]),
        separatorBuilder: (ctx, idx) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _LotteryList extends StatelessWidget {
  const _LotteryList({required this.items});

  final List<LotteryHighlightModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: LotteryCard(item: item),
                ))
            .toList(),
      ),
    );
  }
}

class _RewardsList extends StatelessWidget {
  const _RewardsList({required this.items});

  final List<RewardModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 126,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) => RewardCard(reward: items[i]),
        separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile(this.item);

  final EventModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Text(item.tag, style: AppTypography.small.copyWith(color: AppColors.teal)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTypography.h3),
                Text(item.body, style: AppTypography.small),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.item});

  final NewsModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      leading: const Icon(Icons.campaign_rounded, color: AppColors.blue),
      title: Text(item.title, style: AppTypography.body.copyWith(color: AppColors.text)),
      subtitle: Text(item.time, style: AppTypography.small),
    );
  }
}
