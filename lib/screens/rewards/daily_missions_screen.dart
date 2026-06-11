import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class DailyMissionsScreen extends StatefulWidget {
  const DailyMissionsScreen({super.key});

  @override
  State<DailyMissionsScreen> createState() => _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends State<DailyMissionsScreen> {
  Timer? _timer;
  late Duration _timeRemaining;

  final List<Map<String, dynamic>> _missions = [
    {
      'id': 'm1',
      'title': 'Win 3 Matches',
      'current': 2,
      'target': 3,
      'reward': 150,
      'claimed': false,
    },
    {
      'id': 'm2',
      'title': 'Play in a Tournament',
      'current': 1,
      'target': 1,
      'reward': 200,
      'claimed': false,
    },
    {
      'id': 'm3',
      'title': 'Invite 1 Friend',
      'current': 0,
      'target': 1,
      'reward': 100,
      'claimed': false,
    },
    {
      'id': 'm4',
      'title': 'Add ₹100 or more to wallet',
      'current': 100,
      'target': 100,
      'reward': 300,
      'claimed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set mock duration to midnight reset
    _timeRemaining = const Duration(hours: 5, minutes: 22, seconds: 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String h = d.inHours.toString().padLeft(2, '0');
    String m = (d.inMinutes % 60).toString().padLeft(2, '0');
    String s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
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
          'DAILY MISSIONS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Reset countdown timer
          _buildTimerHeader(),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _missions.length,
              itemBuilder: (ctx, idx) {
                final mission = _missions[idx];
                return _buildMissionCard(mission);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alarm_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Text(
            'Missions reset in: ',
            style: AppTypography.small.copyWith(color: AppColors.textMuted),
          ),
          Text(
            _formatDuration(_timeRemaining),
            style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final cur = mission['current'] as int;
    final tar = mission['target'] as int;
    final reward = mission['reward'] as int;
    final claimed = mission['claimed'] as bool;
    final complete = cur >= tar;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mission['title'] as String,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+$reward Coins',
                      style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 14),

            // Progress Slider
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: cur / tar,
                      minHeight: 8,
                      backgroundColor: AppColors.bg,
                      color: complete ? AppColors.green : AppColors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$cur/$tar',
                  style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Claim Trigger Button
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: (!complete || claimed)
                    ? null
                    : () {
                        setState(() {
                          mission['claimed'] = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Claimed $reward coins!')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: claimed
                      ? AppColors.surface2
                      : complete
                          ? AppColors.green
                          : AppColors.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: complete && !claimed ? Colors.transparent : AppColors.line),
                  ),
                ),
                child: Text(
                  claimed
                      ? 'CLAIMED'
                      : complete
                          ? 'CLAIM REWARD'
                          : 'IN PROGRESS',
                  style: AppTypography.button.copyWith(
                    color: claimed
                        ? AppColors.textSoft
                        : complete
                            ? Colors.black
                            : AppColors.textSoft,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
