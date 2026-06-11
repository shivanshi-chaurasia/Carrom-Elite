import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/home_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/cards/game_card.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class FeaturedGamesScreen extends ConsumerWidget {
  const FeaturedGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featuredGamesProvider);
    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(title: 'Featured games', subtitle: 'Pick a table', onBack: context.pop),
          Expanded(
            child: state.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(18),
                child: Column(children: [SkeletonLine(height: 160), SizedBox(height: 12), SkeletonLine(height: 160)]),
              ),
              error: (err, stack) => AppErrorView(message: err.toString(), onRetry: () => ref.invalidate(featuredGamesProvider)),
              data: (items) => items.isEmpty
                  ? const AppEmptyView(subtitle: 'No games are open right now.')
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 178,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (ctx, i) => GameCard(game: items[i]),
                      itemCount: items.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
