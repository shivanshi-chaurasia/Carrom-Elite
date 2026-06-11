import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class SpectatorModeScreen extends StatefulWidget {
  const SpectatorModeScreen({super.key});

  @override
  State<SpectatorModeScreen> createState() => _SpectatorModeScreenState();
}

class _SpectatorModeScreenState extends State<SpectatorModeScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _liveMatches = [
    {
      'id': 'L-92',
      'p1': 'Rishi_OP',
      'p2': 'Ananya99',
      'score': '19 - 14',
      'time': '04:12',
      'viewers': 41,
    },
    {
      'id': 'L-44',
      'p1': 'ElitePro',
      'p2': 'PhoenixX',
      'score': '8 - 7',
      'time': '02:05',
      'viewers': 18,
    },
    {
      'id': 'L-10',
      'p1': 'StrikerKing',
      'p2': 'Yash101',
      'score': '22 - 21',
      'time': '08:44',
      'viewers': 112,
    },
  ];

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
          'SPECTATE LIVE BATTLES',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.gold,
        backgroundColor: AppColors.surface,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _liveMatches.length,
                itemBuilder: (ctx, idx) {
                  final item = _liveMatches[idx];
                  return _buildSpectateCard(item);
                },
              ),
      ),
    );
  }

  Widget _buildSpectateCard(Map<String, dynamic> match) {
    final viewers = match['viewers'] as int;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: Live Badge + Viewers counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.red, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: AppTypography.small.copyWith(
                          fontSize: 9,
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.visibility_rounded, color: AppColors.textSoft, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$viewers spectating',
                      style: AppTypography.small.copyWith(fontSize: 10, color: AppColors.textSoft),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // VS Score Board section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.purple.withOpacity(0.2),
                        child: const Icon(Icons.person_rounded, color: AppColors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match['p1']!,
                        style: AppTypography.small.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      match['score']!,
                      style: AppTypography.h1.copyWith(color: AppColors.gold, fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match['time']!,
                      style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.teal.withOpacity(0.2),
                        child: const Icon(Icons.person_rounded, color: AppColors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match['p2']!,
                        style: AppTypography.small.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(color: AppColors.line, height: 28),

            // Watch/Spectate Action button
            _actionButton('WATCH LIVE BATTLE', () {
              context.push(
                '/carrom-match?mode=spectate&matchId=${match['id']}&p1=${match['p1']}&p2=${match['p2']}',
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.play_circle_outline_rounded, color: AppColors.gold, size: 18),
        label: Text(
          label,
          style: AppTypography.button.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
