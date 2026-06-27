import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _globalPlayers = [
    {'rank': 1, 'name': 'StrikerKing', 'xp': 48200, 'streak': 12, 'isMe': false},
    {'rank': 2, 'name': 'ElitePro_X', 'xp': 41500, 'streak': 8, 'isMe': false},
    {'rank': 3, 'name': 'CarromQueen', 'xp': 39100, 'streak': 5, 'isMe': false},
    {'rank': 4, 'name': 'Shiva (You)', 'xp': 32400, 'streak': 4, 'isMe': true},
    {'rank': 5, 'name': 'Yash_Master', 'xp': 28600, 'streak': 2, 'isMe': false},
    {'rank': 6, 'name': 'Ananya_9', 'xp': 24100, 'streak': 0, 'isMe': false},
    {'rank': 7, 'name': 'BoardGod', 'xp': 19900, 'streak': 1, 'isMe': false},
  ];

  final List<Map<String, dynamic>> _weeklyPlayers = [
    {'rank': 1, 'name': 'ElitePro_X', 'xp': 8900, 'streak': 8, 'isMe': false},
    {'rank': 2, 'name': 'Shiva (You)', 'xp': 7200, 'streak': 4, 'isMe': true},
    {'rank': 3, 'name': 'StrikerKing', 'xp': 6800, 'streak': 12, 'isMe': false},
    {'rank': 4, 'name': 'Yash_Master', 'xp': 5400, 'streak': 2, 'isMe': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'LEADERBOARDS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textSoft,
          labelStyle: AppTypography.small.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'GLOBAL'),
            Tab(text: 'WEEKLY'),
            Tab(text: 'FRIENDS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardTab(_globalPlayers),
          _buildLeaderboardTab(_weeklyPlayers),
          _buildLeaderboardTab(_weeklyPlayers), // friends mock same structure
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(List<Map<String, dynamic>> players) {
    // Separate Top 3 from scroll list
    final top3 = players.where((p) => p['rank'] <= 3).toList();
    top3.sort((a, b) => a['rank'].compareTo(b['rank']));
    final rest = players.where((p) => p['rank'] > 3).toList();

    return Column(
      children: [
        const SizedBox(height: 20),
        // Top 3 Podium
        if (top3.isNotEmpty) _buildPodium(top3),
        const SizedBox(height: 20),
        
        // Scroll List
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: rest.length,
              itemBuilder: (ctx, idx) {
                final item = rest[idx];
                return _buildRankRow(item);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    // Rearrange visually: Rank 2, Rank 1, Rank 3
    final Map<String, dynamic> r1 = top3.firstWhere((p) => p['rank'] == 1, orElse: () => top3[0]);
    final Map<String, dynamic>? r2 = top3.length > 1 ? top3.firstWhere((p) => p['rank'] == 2) : null;
    final Map<String, dynamic>? r3 = top3.length > 2 ? top3.firstWhere((p) => p['rank'] == 3) : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2
        if (r2 != null) ...[
          _podiumItem(r2, height: 110, color: AppColors.teal, avatarRadius: 28),
          const SizedBox(width: 16),
        ],

        // Rank 1
        _podiumItem(r1, height: 135, color: AppColors.gold, avatarRadius: 36),
        const SizedBox(width: 16),

        // Rank 3
        if (r3 != null) ...[
          _podiumItem(r3, height: 95, color: AppColors.purple, avatarRadius: 24),
        ],
      ],
    );
  }

  Widget _podiumItem(Map<String, dynamic> player, {required double height, required Color color, required double avatarRadius}) {
    final name = player['name'] as String;
    final rank = player['rank'] as int;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.surface2,
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: AppTypography.h3.copyWith(color: AppColors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '#$rank',
                style: AppTypography.small.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(name, style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
        Text('${player['xp']} XP', style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10)),
      ],
    );
  }

  Widget _buildRankRow(Map<String, dynamic> player) {
    final isMe = player['isMe'] == true;
    final rank = player['rank'] as int;
    final name = player['name'] as String;
    final streak = player['streak'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.purple.withOpacity(0.12) : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMe ? AppColors.purple.withOpacity(0.4) : AppColors.line),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSoft),
            ),
          ),
          
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surface,
            child: Text(name.substring(0, 1).toUpperCase(), style: AppTypography.small.copyWith(fontSize: 11)),
          ),
          
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: Text(
              name,
              style: AppTypography.body.copyWith(
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                color: isMe ? AppColors.gold : AppColors.text,
              ),
            ),
          ),

          // Streak indicator
          if (streak > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(
                '$streak 🔥',
                style: AppTypography.small.copyWith(color: AppColors.red, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // XP Points
          Text(
            '${player['xp']} XP',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
