import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class MatchSelectionScreen extends StatelessWidget {
  const MatchSelectionScreen({super.key});

  final List<Map<String, dynamic>> _cashGames = const [
    {'fee': 10, 'prize': 18, 'waiting': 14},
    {'fee': 25, 'prize': 45, 'waiting': 29},
    {'fee': 50, 'prize': 90, 'waiting': 41},
    {'fee': 100, 'prize': 180, 'waiting': 22},
    {'fee': 500, 'prize': 900, 'waiting': 8},
  ];

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
          'SELECT BATTLE',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section 1: Cash Games
          _buildHeading('CASH GAMES', 'Compete and win real cash deposits instantly'),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _cashGames.length,
              itemBuilder: (ctx, idx) {
                final game = _cashGames[idx];
                return _buildCashCard(context, game);
              },
            ),
          ),
          
          const SizedBox(height: 32),

          // Section 2: Free Games
          _buildHeading('FREE PRACTICE GAMES', 'Zero entry fees, perfect for hone skills'),
          const SizedBox(height: 12),
          _buildFreeGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.small.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.small.copyWith(color: AppColors.textSoft),
        ),
      ],
    );
  }

  Widget _buildCashCard(BuildContext context, Map<String, dynamic> game) {
    final entry = game['fee'] as int;
    final prize = game['prize'] as int;
    final waiting = game['waiting'] as int;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(right: 14, bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: () => context.push('/carrom-lobby?fee=$entry&mode=1v1'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 130,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ENTRY FEE', style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text('₹$entry', style: AppTypography.h1.copyWith(color: AppColors.gold, fontSize: 24)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRIZE POOL', style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 9)),
                  Text('₹$prize', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.teal)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text('$waiting waiting', style: AppTypography.small.copyWith(fontSize: 9, color: AppColors.textSoft)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeGrid(BuildContext context) {
    return Column(
      children: [
        _freeCard(
          title: 'Offline Bot Practice',
          desc: 'Play offline against AI bots to sharpen aim.',
          icon: Icons.smart_toy_rounded,
          color: AppColors.purple,
          onTap: () => context.push('/sound-graphics'), // Will update route mappings later to navigate to practice difficulty screen
        ),
        const SizedBox(height: 12),
        _freeCard(
          title: 'Daily Free Match',
          desc: '₹0 entry fee, ₹5 prize pool. Play once a day.',
          icon: Icons.card_giftcard_rounded,
          color: AppColors.gold,
          onTap: () => context.push('/carrom-lobby?fee=0&mode=free'),
        ),
      ],
    );
  }

  Widget _freeCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.bg, shape: BoxShape.circle, border: Border.all(color: AppColors.line)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
        subtitle: Text(desc, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSoft),
      ),
    );
  }
}
