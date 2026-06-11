import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/typography.dart';
import '../../models/tournament_models.dart';
import '../../providers/tournament_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class TournamentBracketScreen extends ConsumerWidget {
  const TournamentBracketScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentBracketProvider(id));

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(
            title: AppStrings.bracket,
            subtitle: 'Knockout Stage',
            onBack: context.pop,
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(tournamentBracketProvider(id)),
              ),
              data: (nodes) {
                if (nodes.isEmpty) {
                  return const AppEmptyView(subtitle: 'Bracket is not generated yet.');
                }

                // filter nodes by rounds
                var qf = nodes.where((n) => n.round == 'Quarterfinals').toList();
                var sf = nodes.where((n) => n.round == 'Semifinals').toList();
                var fn = nodes.where((n) => n.round == 'Finals').toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RoundColumn(title: 'QUARTERFINALS', nodes: qf, cardHeight: 110, spacing: 32),
                        _buildConnector(),
                        _RoundColumn(title: 'SEMIFINALS', nodes: sf, cardHeight: 110, spacing: 174),
                        _buildConnector(),
                        _RoundColumn(title: 'FINALS', nodes: fn, cardHeight: 110, spacing: 460),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 28,
      height: 600,
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size(28, double.infinity),
        painter: _BracketLinePainter(),
      ),
    );
  }
}

class _RoundColumn extends StatelessWidget {
  const _RoundColumn({
    required this.title,
    required this.nodes,
    required this.cardHeight,
    required this.spacing,
  });

  final String title;
  final List<TournamentBracketNodeModel> nodes;
  final double cardHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.small.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          ...nodes.map((n) {
            var isFirst = nodes.first == n;
            return Container(
              margin: EdgeInsets.only(top: isFirst ? 0 : spacing),
              child: _MatchNodeCard(node: n, cardHeight: cardHeight),
            );
          }),
        ],
      ),
    );
  }
}

class _MatchNodeCard extends StatelessWidget {
  const _MatchNodeCard({required this.node, required this.cardHeight});

  final TournamentBracketNodeModel node;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: cardHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: node.isLive ? AppColors.gold : AppColors.line,
          width: node.isLive ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlayerRow(node.player1Name, node.player1Score, node.winnerName == node.player1Name, node.isLive),
          const Divider(color: AppColors.line, height: 12),
          _buildPlayerRow(node.player2Name, node.player2Score, node.winnerName == node.player2Name, node.isLive),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(String name, int score, bool isWinner, bool isLive) {
    var isEmpty = name.isEmpty;
    var nameText = isEmpty ? 'TBD' : name;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            nameText,
            style: AppTypography.body.copyWith(
              color: isEmpty
                  ? AppColors.textSoft
                  : isWinner
                      ? AppColors.gold
                      : AppColors.text,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isEmpty && !isLive)
          Text(
            score.toString(),
            style: AppTypography.body.copyWith(
              color: isWinner ? AppColors.gold : AppColors.textMuted,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              'LIVE',
              style: AppTypography.small.copyWith(
                color: AppColors.red,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _BracketLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // simple connecting lines drawn across rounds
    var y1 = size.height * 0.15;
    var y2 = size.height * 0.85;

    // left branch (exiting from QF nodes)
    canvas.drawLine(Offset(0, y1), Offset(size.width / 2, y1), paint);
    canvas.drawLine(Offset(0, y2), Offset(size.width / 2, y2), paint);

    // vertical bridge
    canvas.drawLine(Offset(size.width / 2, y1), Offset(size.width / 2, y2), paint);

    // right stem (entering SF node)
    canvas.drawLine(Offset(size.width / 2, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
