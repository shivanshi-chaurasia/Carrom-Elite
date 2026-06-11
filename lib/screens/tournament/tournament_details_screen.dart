import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/tournament_models.dart';
import '../../providers/service_providers.dart';
import '../../providers/tournament_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class TournamentDetailsScreen extends ConsumerStatefulWidget {
  const TournamentDetailsScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TournamentDetailsScreen> createState() => _TournamentDetailsState();
}

class _TournamentDetailsState extends ConsumerState<TournamentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabCtrl;

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentDetailsProvider(widget.id));

    return AppScaffold(
      child: state.when(
        loading: _loading,
        error: (err, stack) => AppErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(tournamentDetailsProvider(widget.id)),
        ),
        data: (data) => Column(
          children: [
            GamingAppBar(
              title: AppStrings.tournamentDetails,
              subtitle: data.title,
              onBack: context.pop,
            ),
            _buildHero(data),
            TabBar(
              controller: tabCtrl,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.gold,
              dividerColor: AppColors.line,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Schedule'),
                Tab(text: 'Leaderboard'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabCtrl,
                children: [
                  _OverviewTab(data: data),
                  _ScheduleTab(data: data),
                  _LeaderboardTab(id: widget.id),
                ],
              ),
            ),
            _buildRegisterBar(data),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(TournamentDetailModel data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRIZE POOL',
                style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  data.startsIn.toUpperCase(),
                  style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.money(data.prizePool),
            style: AppTypography.h1.copyWith(fontSize: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 12),
          Text(data.subtitle, style: AppTypography.body),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: AppColors.textSoft, size: 18),
              const SizedBox(width: 6),
              Text(
                '${data.registeredSeats}/${data.totalSeats} registered',
                style: AppTypography.small.copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push('/tournament-bracket/${widget.id}'),
                icon: const Icon(Icons.account_tree_rounded, size: 16),
                label: const Text('View Bracket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface2,
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterBar(TournamentDetailModel data) {
    // bottom register action bar
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Entry Fee', style: AppTypography.small),
                Text(
                  data.entryFee == 0 ? 'FREE' : AppFormatters.money(data.entryFee),
                  style: AppTypography.h2.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: data.isRegistered
                  ? () => context.push('/tournament-winner/${widget.id}') // demo winner declaration screen
                  : () async {
                      // register user
                      await ref.read(tournamentServiceProvider).registerForTournament(widget.id);
                      ref.invalidate(tournamentDetailsProvider(widget.id));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: data.isRegistered ? AppColors.teal : AppColors.gold,
                foregroundColor: AppColors.bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                data.isRegistered ? 'ENTER MATCH' : AppStrings.registerNow.toUpperCase(),
                style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loading() {
    return Column(
      children: [
        const GamingAppBar(title: AppStrings.tournamentDetails, subtitle: 'Loading...'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              SkeletonLine(height: 180),
              SizedBox(height: 20),
              SkeletonLine(height: 48),
              SizedBox(height: 16),
              SkeletonLine(height: 120),
              SizedBox(height: 12),
              SkeletonLine(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.data});

  final TournamentDetailModel data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(AppStrings.rules, style: AppTypography.h3),
        const SizedBox(height: 12),
        ...data.rules.map((rule) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.gold),
                  const SizedBox(width: 10),
                  Expanded(child: Text(rule, style: AppTypography.body)),
                ],
              ),
            )),
        const SizedBox(height: 24),
        Text(AppStrings.prizePool.toUpperCase(), style: AppTypography.h3),
        const SizedBox(height: 12),
        ...data.prizes.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 12),
                  Text(p.rank, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(
                    AppFormatters.money(p.prize),
                    style: AppTypography.h3.copyWith(color: AppColors.teal),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.data});

  final TournamentDetailModel data;

  @override
  Widget build(BuildContext context) {
    if (data.matches.isEmpty) {
      return const AppEmptyView(subtitle: 'No matches scheduled.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.matches.length,
      itemBuilder: (ctx, idx) {
        var m = data.matches[idx];
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.roundName, style: AppTypography.small.copyWith(color: AppColors.textSoft)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: m.status == 'live' ? AppColors.red.withValues(alpha: 0.15) : AppColors.surface2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m.status.toUpperCase(),
                        style: AppTypography.small.copyWith(
                          color: m.status == 'live' ? AppColors.red : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.line, height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.cardLight,
                            child: Icon(Icons.person, color: AppColors.textSoft),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.player1Name,
                            style: AppTypography.body.copyWith(color: AppColors.text),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        m.status == 'completed' || m.status == 'live'
                            ? '${m.player1Score} - ${m.player2Score}'
                            : 'VS',
                        style: AppTypography.h2.copyWith(color: AppColors.gold),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.cardLight,
                            child: Icon(Icons.person, color: AppColors.textSoft),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.player2Name,
                            style: AppTypography.body.copyWith(color: AppColors.text),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(m.matchTime, style: AppTypography.small),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentLeaderboardProvider(id));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (err, stack) => AppErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(tournamentLeaderboardProvider(id)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const AppEmptyView(subtitle: 'Leaderboard is not active yet.');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, idx) {
            var item = items[idx];
            var isUser = item.playerName.contains('You');
            var topRank = item.rank <= 3;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.gold.withValues(alpha: 0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isUser ? AppColors.gold : AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: topRank
                        ? Icon(
                            Icons.emoji_events_rounded,
                            color: item.rank == 1
                                ? AppColors.gold
                                : item.rank == 2
                                    ? AppColors.textMuted
                                    : AppColors.goldDark,
                            size: 22,
                          )
                        : Text(
                            '#${item.rank}',
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.cardLight,
                    child: Icon(Icons.person, size: 18, color: AppColors.textSoft),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.playerName,
                      style: AppTypography.body.copyWith(
                        color: isUser ? AppColors.gold : AppColors.text,
                        fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${item.score} pts',
                    style: AppTypography.small.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    item.prize,
                    style: AppTypography.body.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
