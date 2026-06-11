import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/home_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/cards/tournament_card.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class TournamentBannerScreen extends ConsumerWidget {
  const TournamentBannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentBannersProvider);
    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(title: 'Tournament banners', subtitle: 'Live and upcoming', onBack: context.pop),
          Expanded(
            child: state.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(18),
                child: Column(children: [SkeletonLine(height: 154), SizedBox(height: 12), SkeletonLine(height: 154)]),
              ),
              error: (err, stack) => AppErrorView(message: err.toString(), onRetry: () => ref.invalidate(tournamentBannersProvider)),
              data: (items) => items.isEmpty
                  ? const AppEmptyView(subtitle: 'Tournament banners will show here.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      itemBuilder: (ctx, i) => SizedBox(height: 172, child: TournamentCard(item: items[i])),
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                      itemCount: items.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
